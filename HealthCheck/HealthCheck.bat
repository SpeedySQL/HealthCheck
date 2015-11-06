@echo off
color 1F
echo.
echo Starting database health check. Please wait...
for /f "tokens=1,2 delims=; " %%A in (%~d0%~p0DBList.txt) do (
echo Processing %%B on %%A
C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command "./HealthCheck.ps1" %%A %%B)

