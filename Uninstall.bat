@echo off
title Roblox Studio Memory Optimizer Uninstaller
echo ==========================================================
echo  ROBLOX STUDIO MEMORY OPTIMIZER UNINSTALLER
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

schtasks /query /tn "%DEV_TASK%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [*] Found task '%DEV_TASK%'. Uninstalling...
    schtasks /end /tn "%DEV_TASK%" >nul 2>&1
    schtasks /delete /tn "%DEV_TASK%" /f >nul 2>&1
)

schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [*] Found task '%TASK_NAME%'. Uninstalling...
    schtasks /end /tn "%TASK_NAME%" >nul 2>&1
    schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
    echo [+] Successfully removed the background optimizer service!
) else (
    echo [*] The task is not registered on this system.
)

echo.
echo ==========================================================
echo  UNINSTALLATION COMPLETE!
echo ==========================================================
echo.
pause
