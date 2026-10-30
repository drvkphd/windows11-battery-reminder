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
5. To activate it right away without restarting, right-click your new task in the list and click **Run**. Or double click your taks to open a new window to find hte run command in the right pane.
<img width="2508" height="1016" alt="image" src="https://github.com/user-attachments/assets/9a0923d2-2730-48a7-ac4f-58e90ea00d6d" />
6. In the properties tab make sure to select to **Configure for:** Windows 10
<img width="1262" height="952" alt="image" src="https://github.com/user-attachments/assets/1e17ba25-1e47-44d7-b4ce-62dd2d6cd35b" />
