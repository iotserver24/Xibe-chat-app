# Test script for E2B Code Executor API

Write-Host "Testing E2B Code Executor API..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Health check
Write-Host "1. Testing health endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method Get
    Write-Host "✅ Health check passed: $($health.status)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Simple code execution
Write-Host "2. Testing code execution..." -ForegroundColor Yellow
$uri = "http://localhost:3000/execute"
$body = @{
    code = "print('Hello from E2B!'); print('Test successful!')"
    language = "python"
} | ConvertTo-Json

Write-Host "Request Body:" -ForegroundColor Gray
Write-Host $body -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json" -TimeoutSec 60
    
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
    
    # Show output if available
    if ($response.execution.logs.stdout) {
        Write-Host ""
        Write-Host "Output:" -ForegroundColor Green
        $response.execution.logs.stdout | ForEach-Object { Write-Host $_ -ForegroundColor White }
    }
} catch {
    Write-Host "❌ Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response body:" -ForegroundColor Yellow
        Write-Host $responseBody -ForegroundColor Red
    }
    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Red
    }
}
