@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Adding Windows Firewall rules for Homebody...

netsh advfirewall firewall delete rule name="Homebody Discovery" >nul 2>&1
netsh advfirewall firewall add rule name="Homebody Discovery" dir=in action=allow protocol=UDP localport=41234

netsh advfirewall firewall delete rule name="Homebody Server" >nul 2>&1
netsh advfirewall firewall add rule name="Homebody Server" dir=in action=allow protocol=TCP localport=9393

netsh advfirewall firewall delete rule name="Homebody LiveKit TCP" >nul 2>&1
netsh advfirewall firewall add rule name="Homebody LiveKit TCP" dir=in action=allow protocol=TCP localport=7880-7881

netsh advfirewall firewall delete rule name="Homebody LiveKit UDP" >nul 2>&1
netsh advfirewall firewall add rule name="Homebody LiveKit UDP" dir=in action=allow protocol=UDP localport=7882

echo.
echo Done. If your headset still can't find the server, check that
echo homebody-server.exe is allowed through the firewall for both
echo Private and Public networks (Windows Security -^> Firewall ^&
echo network protection -^> Allow an app through firewall).
pause
