# Kill any running xibe_chat processes to unlock files
Write-Host "Killing xibe_chat processes..."

$processes = Get-Process -Name "xibe_chat" -ErrorAction SilentlyContinue
if ($processes) {
    $processes | ForEach-Object {
        Write-Host "Killing process ID: $($_.Id)"
        Stop-Process -Id $_.Id -Force
    }
    Write-Host "✅ All xibe_chat processes killed"
} else {
    Write-Host "No xibe_chat processes found"
}

# Also kill any Flutter processes that might be locking files
$flutterProcesses = Get-Process | Where-Object { $_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*dart*" } | Where-Object { $_.Path -like "*Xibe-chat-app*" }
if ($flutterProcesses) {
    Write-Host "Killing Flutter/Dart processes..."
    $flutterProcesses | ForEach-Object {
        Write-Host "Killing process: $($_.ProcessName) (ID: $($_.Id))"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Done! You can now rebuild the app."

