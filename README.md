# Windows 11 Full-Screen Battery Unplug Reminder 🔋

A lightweight, completely native Windows 11 utility that monitors your laptop's battery status. The exact moment your battery hits 100% (or 99% depending on hardware calibration) while plugged in, it forces a persistent, full-screen crimson warning ordering you to unplug your charger to protect battery health.

## ✨ Features
* **Zero Third-Party Apps:** Uses 100% native Windows tools (PowerShell & Task Scheduler).
* **Aggressive Full-Screen Overlay:** Locks over all windows so you never miss it.
* **Auto-Dismiss:** Closes itself within 2 seconds of physically pulling out the charging cord.
* **Sleep/Lid Wake-Up Proof:** Keeps running seamlessly even if you never shut down or reboot your laptop.
* **Persistent:** Re-triggers every 5 minutes if ignored.

---

## 🚀 Setup Instructions

### Step 1: Save the Script
1. Create a folder on your computer named `C:\Scripts\`.
2. Save the `BatteryNotifier.ps1` file from this repository inside that folder.

### Step 2: Configure Task Scheduler (Automated Startup)
Because modern laptops utilize Sleep and Hibernate instead of full shutdowns, we use Windows Task Scheduler to ensure the script triggers every time you open your laptop lid.

1. Open the Start Menu, search for **Task Scheduler**, and open it.
2. In the right-hand panel, click **Create Task...**
3. Configure the following tabs:

#### 📋 General Tab
* **Name:** `Battery Full Notifier`
* **Security options:** Check **Run with highest privileges**.
* **Configure for:** Select **Windows 10** (this ensures Windows 11 handles execution policies correctly).
*(You can paste a screenshot here)*

#### ⚡ Triggers Tab
Click **New...** and add these two separate triggers:
1. *Begin the task:* **At log on** -> Click OK.
2. *Begin the task:* **On workstation unlock** (This is crucial for when you open your laptop lid) -> Click OK.

#### 🛠️ Actions Tab
Click **New...** and configure a program launch:
* **Action:** `Start a program`
* **Program/script:** `powershell`
* **Add arguments (optional):** 
  ```text
  -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File C:\Scripts\BatteryNotifier.ps1
  ```

#### 🔋 Conditions Tab
* **Crucial:** Uncheck the box that says *"Start the task only if the computer is on AC power"*. (Otherwise, the script won't start tracking if you unlock your laptop while running on battery).

4. Click **OK** to save the task. 
5. To activate it right away without restarting, right-click your new task in the list and click **Run**.
