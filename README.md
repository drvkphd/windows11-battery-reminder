# Windows 11 Full-Screen Battery Unplug Reminder 🔋

A lightweight, completely native Windows 11 utility that monitors your laptop's battery status. The moment your battery hits 100% while plugged in, it forces a persistent, full-screen crimson warning telling you to unplug your charger to protect battery health.

> **Branches**
> * `main` – the original reminder, with no bypass.
> * `bypass-mode` – the same reminder plus a **manual bypass**. Use it when you need the charger to stay plugged in, for example to run CPU-heavy automation tests without the CPU underclocking on battery, or to keep the laptop running on mains after its battery has died.

## ✨ Features
* **Zero Third-Party Apps:** Uses 100% native Windows tools (PowerShell & Task Scheduler).
* **Aggressive Full-Screen Overlay:** Locks over all windows so you never miss it.
* **Auto-Dismiss:** Closes itself within 2 seconds of physically pulling out the charging cord.
* **Sleep/Lid Wake-Up Proof:** Keeps running seamlessly even if you never shut down or reboot your laptop.
* **Persistent:** Re-triggers every 5 minutes if ignored.
* **Manual Bypass *(bypass-mode branch)*:** Silences the alert for 2 hours or until you resume it, without stopping the monitor.

---

## 🚀 Setup Instructions

### Step 1: Save the Script
1. Create a folder on your computer named `C:\Scripts\`.

2. Save the `BatteryNotifier.ps1` file from this repository inside that folder.
<img width="1610" height="574" alt="image" src="https://github.com/user-attachments/assets/46ef8ed7-73aa-486e-bd35-9582f33e7697" />


### Step 2: Configure Task Scheduler (Automated Startup)
Because modern laptops utilize Sleep and Hibernate instead of full shutdowns, we use Windows Task Scheduler to ensure the script triggers every time you open your laptop lid.

1. Open the Start Menu, search for **Task Scheduler**, and open it.
<img width="716" height="580" alt="image" src="https://github.com/user-attachments/assets/a5b911b2-b8e8-4431-aba7-7a567a95c472" />

2. In the right-hand panel, click **Create Task...**
<img width="862" height="770" alt="image" src="https://github.com/user-attachments/assets/df1394bb-72dc-4c2b-b48a-7b855362a230" />

3. Configure the following tabs:


#### 📋 General Tab
* **Name:** `Battery Full Notifier`
* **Security options:** Check **Run with highest privileges**.
* **Configure for:** Select **Windows 10** (this ensures Windows 11 handles execution policies correctly).
<img width="1272" height="962" alt="image" src="https://github.com/user-attachments/assets/f9b1664b-f2e1-4eaf-a77d-171e4753e458" />


#### ⚡ Triggers Tab
Click **New...** and add these two separate triggers:
1. *Begin the task:* **At log on** -> Click OK.
2. *Begin the task:* **On workstation unlock** (This is crucial for when you open your laptop lid) -> Click OK.
<img width="1534" height="1278" alt="image" src="https://github.com/user-attachments/assets/64390c40-e879-42b3-ac12-7959de61bcbd" />


#### 🛠️ Actions Tab
Click **New...** and configure a program launch:
* **Action:** `Start a program`
* **Program/script:** `powershell`
* **Add arguments (optional):** 
  ```text
  -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\BatteryNotifier.ps1
  ```
<img width="1388" height="1220" alt="image" src="https://github.com/user-attachments/assets/00f7ab3b-3344-4596-8e51-0db99e56ad26" />

#### 🔋 Conditions Tab
* **Crucial:** Uncheck the box that says *"Start the task only if the computer is on AC power"*. (Otherwise, the script won't start tracking if you unlock your laptop while running on battery).
<img width="1280" height="980" alt="image" src="https://github.com/user-attachments/assets/5fee6848-7e7b-4974-a741-5cf6b2e5f214" />

4. Click **OK** to save the task. 
5. To activate it right away without restarting, right-click your new task in the list and click **Run**. Or double-click your task to open a new window and find the **Run** command in the right pane.
<img width="2508" height="1016" alt="image" src="https://github.com/user-attachments/assets/9a0923d2-2730-48a7-ac4f-58e90ea00d6d" />
6. In the Properties window, make sure **Configure for:** is set to **Windows 10**.
<img width="1262" height="952" alt="image" src="https://github.com/user-attachments/assets/1e17ba25-1e47-44d7-b4ce-62dd2d6cd35b" />

---

## ⏸️ Manual Bypass *(bypass-mode branch only)*

Sometimes the charger **has** to stay plugged in, for example:
* **Automation / performance testing:** on battery, Windows underclocks the CPU, so tests must run on mains power.
* **Dead or removed battery:** the laptop runs on the charger alone until you replace the battery.

The bypass silences the full-screen alert while the monitor keeps running in the background. You don't need to stop or edit the scheduled task.

### Option 1: From the alert screen
When the red alert appears, two buttons are shown at the bottom:

| Button | What it does |
|---|---|
| **Testing: bypass 2 hours** | Silences alerts for 2 hours, then switches itself off automatically. |
| **Testing: bypass until resumed** | Silences alerts until you run `-Resume` (see below). |

### Option 2: From PowerShell (best before starting automation)
Open PowerShell (or type `powershell` in the File Explorer address bar of `C:\Scripts` and press Enter), then run:

```powershell
cd C:\Scripts
.\BatteryNotifier.ps1 -Bypass 120   # silence for 120 minutes (recommended for test runs)
```

You should see: `Battery alerts BYPASSED for 120 minutes (until HH:mm).`

If PowerShell says running scripts is disabled, use this instead:
```powershell
powershell -ExecutionPolicy Bypass -File C:\Scripts\BatteryNotifier.ps1 -Bypass 120
```

### All bypass commands

| Command | Effect |
|---|---|
| `.\BatteryNotifier.ps1 -Bypass 120` | Bypass for 120 minutes (any number of minutes works). |
| `.\BatteryNotifier.ps1 -Bypass 0` | Bypass **until resumed**. Use this for the dead-battery case. |
| `.\BatteryNotifier.ps1 -Resume` | Turn alerts back on immediately. |
| `.\BatteryNotifier.ps1 -Status` | Show whether a bypass is active and until when. |

These commands only set or clear the bypass and then exit. They do **not** start a second copy of the monitor. The running monitor picks up the change within 15 seconds, and if the alert is already on screen, it closes within 2 seconds.

### Tips
* **Prefer the 2-hour bypass for testing.** It expires on its own, so you can't forget to turn alerts back on. Run it again if your test needs longer.
* **Use "until resumed" only for the dead-battery case**, and run `-Resume` after you fit the new battery.
* An "until resumed" bypass **stays on after a reboot**. A timed bypass simply expires.
* To use it inside an automation script, put `-Bypass 120` at the start of your test script and `-Resume` at the end.

### How it works
The bypass is a small flag file at `%LOCALAPPDATA%\BatteryNotifier.bypass`:
* contains a date and time → bypass active until then, after which the file deletes itself
* contains `indefinite` → bypass active until you run `-Resume`

Deleting that file manually has the same effect as `-Resume`.
