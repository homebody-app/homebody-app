@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Removing Homebody firewall rules...

netsh advfirewall firewall delete rule name="Homebody Discovery"
netsh advfirewall firewall delete rule name="Homebody Server"
netsh advfirewall firewall delete rule name="Homebody LiveKit TCP"
netsh advfirewall firewall delete rule name="Homebody LiveKit UDP"

echo.
echo Done.
pause
