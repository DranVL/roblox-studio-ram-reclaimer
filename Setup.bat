@echo off
title Roblox Studio Memory Optimizer Setup
color 0B
echo ==========================================================
echo  ROBLOX STUDIO MEMORY OPTIMIZER INSTALLER / UPDATER
echo ==========================================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "TASK_NAME=RobloxStudioMemoryOptimizer"
set "DEV_TASK=RobloxStudioMemoryOptimizerDev"
set "SCRIPT_PATH=%~dp0MemoryOptimizer.ps1"

echo [*] Checking for previous versions and running services...

schtasks /query /tn "%DEV_TASK%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [*] Stopping and Deleting Dev version task...
    schtasks /end /tn "%DEV_TASK%" >nul 2>&1
    schtasks /delete /tn "%DEV_TASK%" /f >nul 2>&1
)

schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [*] Stopping previous version task...
    schtasks /end /tn "%TASK_NAME%" >nul 2>&1
    timeout /t 2 /nobreak >nul
)

for /f "tokens=5" %%a in ('netstat -aon ^| findstr :9088 ^| findstr LISTENING') do (
    echo [*] Port 9088 is still in use by PID %%a. Force terminating...
    taskkill /F /PID %%a >nul 2>&1
    timeout /t 1 /nobreak >nul
)

echo [*] Registering Windows Scheduled Task (On Logon)...
schtasks /create /tn "%TASK_NAME%" /tr "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File '%SCRIPT_PATH%'" /sc onlogon /f >nul 2>&1

if %errorLevel% neq 0 (
    echo.
    echo [!] ERROR: Failed to register the scheduled task.
    goto :End
)

echo [*] Launching background optimizer service...
schtasks /run /tn "%TASK_NAME%" >nul 2>&1

echo [*] Verifying service initialization (waiting for port 9088)...
set /a attempts=0

:VerifyLoop
set /a attempts+=1
netstat -aon | findstr :9088 | findstr LISTENING >nul 2>&1
if %errorLevel% equ 0 (
    echo.
    echo [+] SUCCESS: Optimizer service is updated and running properly!
    goto :Success
)
if %attempts% geq 10 (
    echo.
    echo [!] ERROR: Service started but failed to open port 9088.
    goto :End
)
timeout /t 1 /nobreak >nul
goto :VerifyLoop

:Success
echo.
echo ==========================================================
echo  INSTALLATION / UPDATE COMPLETE!
echo ==========================================================
echo.
pause
exit /b

:End
echo.
pause
exit /b
