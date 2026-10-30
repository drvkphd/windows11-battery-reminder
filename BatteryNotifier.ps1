<#
.SYNOPSIS
    Windows 11 Full-Screen Battery Charge Reminder.
.DESCRIPTION
    Monitors battery status natively. Launches a full-screen alert when battery 
    hits 99%-100% on AC power. Auto-dismisses within 2 seconds of unplugging.
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

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

    $form.Controls.Add($label)

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 2000
    $timer.Add_Tick({
        $battery = Get-CimInstance -ClassName Win32_Battery
        $status = $battery.BatteryStatus
        if ($status -eq 1 -or $battery.EstimatedChargeRemaining -lt 99) {
            $form.Close()
        }
    })
    $timer.Start()

    [System.Windows.Forms.Application]::Run($form)
}

while ($true) {
    try {
        $battery = Get-CimInstance -ClassName Win32_Battery
        $percent = $battery.EstimatedChargeRemaining
        $status = $battery.BatteryStatus 

        if ($percent -ge 100 -and $status -ne 1) {
            Show-FullScreenAlert
            Start-Sleep -Seconds 300
        } else {
            Start-Sleep -Seconds 15
        }
    } catch {
        Start-Sleep -Seconds 15
    }
}
