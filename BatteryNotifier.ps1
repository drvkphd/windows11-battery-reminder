<#
    BatteryNotifier.ps1
    Full-screen "unplug the charger" alert, with a manual BYPASS for testing
    sessions where the charger must stay plugged in (e.g. to keep the CPU
    from being underclocked on battery).

    Normal run (background monitor):
        powershell -WindowStyle Hidden -File BatteryNotifier.ps1

    Bypass control (run from any terminal / automation script while the
    monitor is running):
        BatteryNotifier.ps1 -Bypass 120   # silence alerts for 120 minutes
        BatteryNotifier.ps1 -Bypass 0     # silence until you resume
        BatteryNotifier.ps1 -Resume       # turn alerts back on
        BatteryNotifier.ps1 -Status       # show current bypass state

    The bypass is a small flag file:  %LOCALAPPDATA%\BatteryNotifier.bypass
    (empty or "indefinite" = bypass until removed; an ISO date = bypass until then)
#>
param(
    [int]$Bypass = -1,     # minutes; 0 = until resumed; -1 = not used
    [switch]$Resume,
    [switch]$Status
)

$BypassFile = Join-Path $env:LOCALAPPDATA 'BatteryNotifier.bypass'

function Set-Bypass([int]$Minutes) {
    if ($Minutes -gt 0) {
        $value = (Get-Date).AddMinutes($Minutes).ToString('o')
    } else {
        $value = 'indefinite'
    }
    Set-Content -Path $BypassFile -Value $value -Encoding ASCII
}

function Clear-Bypass {
    Remove-Item -Path $BypassFile -ErrorAction SilentlyContinue
}

# Returns $true while bypass is active; clears an expired timed bypass.
function Test-Bypass {
    if (-not (Test-Path $BypassFile)) { return $false }
    $value = Get-Content -Path $BypassFile -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($value)) { return $true }
    $value = $value.Trim()
    if ($value -eq 'indefinite') { return $true }
    try {
        $until = [datetime]::Parse($value, [Globalization.CultureInfo]::InvariantCulture,
                                   [Globalization.DateTimeStyles]::RoundtripKind)
    } catch {
        return $true   # unreadable content -> treat as manual bypass
    }
    if ((Get-Date) -lt $until) { return $true }
    Clear-Bypass
    return $false
}

# ---------- Command-line control mode (does not start the monitor) ----------
if ($Resume) {
    Clear-Bypass
    Write-Host "Battery alerts RESUMED."
    return
}
if ($Bypass -ge 0) {
    Set-Bypass $Bypass
    if ($Bypass -eq 0) { Write-Host "Battery alerts BYPASSED until you run -Resume." }
    else { Write-Host "Battery alerts BYPASSED for $Bypass minutes (until $((Get-Date).AddMinutes($Bypass).ToString('HH:mm')))." }
    return
}
if ($Status) {
    if (Test-Bypass) { Write-Host "Bypass ACTIVE: $((Get-Content $BypassFile -Raw).Trim())" }
    else { Write-Host "Bypass OFF - alerts are active." }
    return
}

# ---------- Monitor mode ----------
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-FullScreenAlert {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Battery Full Alert"
    $form.WindowState = "Maximized"
    $form.FormBorderStyle = "None"
    $form.BackColor = "Crimson"
    $form.TopMost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "BATTERY IS FULL`n`nPlease Unplug the Charger!"
    $label.Font = New-Object System.Drawing.Font("Arial", 36, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = [System.Drawing.Color]::White
    $label.Dock = "Fill"
    $label.TextAlign = "MiddleCenter"

    # Bottom bar with bypass buttons
    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.Dock = "Bottom"
    $panel.Height = 90
    $panel.FlowDirection = "LeftToRight"
    $panel.Padding = New-Object System.Windows.Forms.Padding(40, 15, 40, 15)
    $panel.BackColor = [System.Drawing.Color]::FromArgb(120, 0, 20)

    $btnFont = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)

    $btnTimed = New-Object System.Windows.Forms.Button
    $btnTimed.Text = "Testing: bypass 2 hours"
    $btnTimed.Font = $btnFont
    $btnTimed.Size = New-Object System.Drawing.Size(320, 55)
    $btnTimed.BackColor = [System.Drawing.Color]::White
    $btnTimed.Add_Click({ Set-Bypass 120; $form.Close() })

    $btnIndef = New-Object System.Windows.Forms.Button
    $btnIndef.Text = "Testing: bypass until resumed"
    $btnIndef.Font = $btnFont
    $btnIndef.Size = New-Object System.Drawing.Size(380, 55)
    $btnIndef.BackColor = [System.Drawing.Color]::White
    $btnIndef.Add_Click({ Set-Bypass 0; $form.Close() })

    $panel.Controls.Add($btnTimed)
    $panel.Controls.Add($btnIndef)

    $form.Controls.Add($label)
    $form.Controls.Add($panel)
    $label.BringToFront()   # so Fill takes the space left above the bottom bar

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 2000
    $timer.Add_Tick({
        $battery = Get-CimInstance -ClassName Win32_Battery
        $status = $battery.BatteryStatus
        # Close if unplugged (status 1), charge drops below 99%, or a bypass was set externally
        if ($status -eq 1 -or $battery.EstimatedChargeRemaining -lt 99 -or (Test-Bypass)) {
            $timer.Stop()
            $form.Close()
        }
    })
    $timer.Start()

    [System.Windows.Forms.Application]::Run($form)
    $timer.Dispose()
    $form.Dispose()
}

while ($true) {
    try {
        # Manual bypass for testing: keep monitoring quietly, no alert
        if (Test-Bypass) {
            Start-Sleep -Seconds 15
            continue
        }

        $battery = Get-CimInstance -ClassName Win32_Battery
        $percent = $battery.EstimatedChargeRemaining
        $status = $battery.BatteryStatus

        # Triggers at 100% while plugged in (status is not 1 = discharging)
        if ($percent -ge 100 -and $status -ne 1) {
            Show-FullScreenAlert
            if (-not (Test-Bypass)) { Start-Sleep -Seconds 300 }
        } else {
            Start-Sleep -Seconds 15
        }
    } catch {
        # Fallback interval if a query fails momentarily
        Start-Sleep -Seconds 15
    }
}
