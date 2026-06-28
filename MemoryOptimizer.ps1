try {
    $Signature = @"
    using System;
    using System.Runtime.InteropServices;

    public class Win32Utils {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool SetProcessWorkingSetSize(IntPtr proc, int min, int max);
    }
"@
    Add-Type -TypeDefinition $Signature -ErrorAction SilentlyContinue
}
catch {

}

$port = 9088
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$logPath = Join-Path $scriptDir "optimizer_log.txt"
$startTime = Get-Date
$global:totalSavedMB = 0.0

$enableFileLogging = $false

function Write-Log($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $message"
    Write-Output $logLine
    if ($enableFileLogging) {
        try {
            Add-Content -Path $logPath -Value $logLine -ErrorAction SilentlyContinue
        }
        catch {}
    }
}

function Trim-ProcessWorkingSet {
    param($proc)
    try {
        $pName = $proc.ProcessName
        $before = $proc.WorkingSet64
        
        $result = [Win32Utils]::SetProcessWorkingSetSize($proc.Handle, -1, -1)
        if ($result) {
            $after = $proc.WorkingSet64
            $saved = ($before - $after) / 1MB
            if ($saved -gt 0) {
                $global:totalSavedMB += $saved
                Write-Log "Optimized: $($pName) (PID: $($proc.Id)) - Reclaimed $($saved.ToString('F1')) MB."
            }
        }
    }
    catch {
        Write-Log "Error optimizing process $($proc.ProcessName): $_"
    }
}

function Handle-HttpRequest($context) {
    $request = $context.Request
    $response = $context.Response
    $path = $request.Url.LocalPath
    $method = $request.HttpMethod

    try {
        if ($path -eq "/clean" -and ($method -eq "POST" -or $method -eq "GET")) {
            Write-Log "Received clear memory trigger from Roblox Studio."
            
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("Cleaning Roblox Studio RAM")
            $response.ContentType = "text/plain; charset=utf-8"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()

            Start-Sleep -Milliseconds 1500

            $targetProcesses = @("RobloxStudioBeta", "RobloxStudio")
            foreach ($name in $targetProcesses) {
                $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
                foreach ($p in $procs) {
                    Trim-ProcessWorkingSet -proc $p
                }
            }
            return
        }

        $response.StatusCode = 404
        $response.Close()
    }
    catch {
        Write-Log "Error handling request: $_"
        try {
            $response.StatusCode = 500
            $response.Close()
        }
        catch {}
    }
}

Write-Log "Roblox Studio Memory Optimizer Service starting on port $port..."

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$port/")
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
    Write-Log "Server is listening on port: $port"
}
catch {
    Write-Log "FATAL ERROR: Failed to start HttpListener: $_"
    exit 1
}

$asyncResult = $listener.BeginGetContext($null, $null)

while ($listener.IsListening) {
    try {
        if ($asyncResult.IsCompleted) {
            $context = $listener.EndGetContext($asyncResult)
            $asyncResult = $listener.BeginGetContext($null, $null)
            Handle-HttpRequest $context
        }
    }
    catch {
        Write-Log "Error inside main loop: $_"
        try {
            if ($null -eq $asyncResult -or $asyncResult.IsCompleted) {
                $asyncResult = $listener.BeginGetContext($null, $null)
            }
        }
        catch {}
    }

    Start-Sleep -Milliseconds 300
}

try {
    $listener.Stop()
    $listener.Close()
}
catch {}
Write-Log "Service Stopped."
