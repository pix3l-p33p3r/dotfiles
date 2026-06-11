@echo off
REM WinApps RDP application support — run as Administrator inside RDPWindows.
setlocal
cd /d "%USERPROFILE%\Downloads"
echo Downloading WinApps OEM files...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/winapps-org/winapps/main/oem/RDPApps.reg' -OutFile 'RDPApps.reg';" ^
  "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/winapps-org/winapps/main/oem/TimeSync.ps1' -OutFile 'TimeSync.ps1';" ^
  "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/winapps-org/winapps/main/oem/NetProfileCleanup.ps1' -OutFile 'NetProfileCleanup.ps1';" ^
  "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/winapps-org/winapps/main/oem/install.bat' -OutFile 'install.bat'"
if errorlevel 1 (
  echo Download failed.
  pause
  exit /b 1
)
echo Running install.bat...
call install.bat
echo Done. Reboot Windows, then install Comet and run winapps-setup on Linux.
pause
