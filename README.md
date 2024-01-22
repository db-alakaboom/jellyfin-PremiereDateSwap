# jellyfin-PremiereDateSwap
Uses sqlite and PowerShell to modify the "Date Added" of an Episode or Movie to the "Release Date"/"Premiere Date", so when you add older Movies or TV-Shows, it would not clutter up the "Latest Movies" and "Latest TV-Shows" section.

## DESIGNED FOR WINDOWS USERS
### Must run script in ADMIN PowerShell console!!!

## Requires the use of sql command line shell program and can be found here: 
### https://www.sqlite.org/download.html


## Useage:
#### 1. Via Shortcut (Manually):
Run this script via creating a new shortcut. Enter the code below for the shortcuts target and make the changes to the path as needed:

```C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""C:\path\to\organise.ps1""' -Verb RunAs}"```

#### 2. Task Schedular (Recommended):

Press Win + S, type "Task Scheduler," and press Enter.

Create a Basic Task: In the right-hand pane, click on "Create Basic Task..." to open the wizard.

Name and Description: Provide a name and description for your task, then click "Next."

Trigger: Choose the trigger that suits your needs (e.g., daily, weekly, at logon, etc.), and click "Next."

Start a Program: Select "Start a Program" as the action and click "Next."

Program/Script: Browse and select ```C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe``` as the program/script.

Add Arguments: In the "Add arguments" field, enter the following: ```-NoProfile -ExecutionPolicy Bypass -File "C:\path\to\organise.ps1"```
*Replace "C:\path\to\organise.ps1" with the actual path to your PowerShell script.*

Finish: Review your settings and click "Finish."
Now, your task is scheduled to run the PowerShell script based on the trigger you specified. 

In Task Scheduler, find your task in the middle pane.

Right-click on the task and select "Properties."

In the "General" tab, check the option "Run with highest privileges."

Click "OK" to save the changes.
