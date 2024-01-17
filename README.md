# jellyfin-PremiereDateSwap
Uses sqlite and Powershell to modify the "Date Added" of an Episode or Movie to the "Release Date"/"Premiere Date", so when you add older Movies or TV-Shows, it would not clutter up the "Latest Movies" and "Latest TV-Shows" section.

DESIGNED FOR WINDOWS ONLY (modify for your system as you want)

Requires the use of sql command line shell program and can be found here: https://www.sqlite.org/download.html

Must run script in admin powershell console!!!

Here is the shortcut I use to run it: 
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""C:\path\to\organise.ps1""' -Verb RunAs}"
