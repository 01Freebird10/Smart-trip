# Smart Trip Planner - Unified Startup Script
# Run this script using: .\run_app.ps1

Write-Host "--- Preparing Smart Trip Planner Suite ---" -ForegroundColor Cyan

# Function to clear a port
function Clear-Port($port) {
    Write-Host "Releasing port $port..." -ForegroundColor Gray
    Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | ForEach-Object {
        $procId = $_.OwningProcess
        if ($procId -gt 0) {
            Write-Host "Stopping process $procId..." -ForegroundColor Gray
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        }
    }
    # Wait a moment for OS to release the port
    Start-Sleep -Seconds 1
}

# 0. Cleanup existing sessions
Write-Host "Checking for existing sessions..." -ForegroundColor Gray
Clear-Port 5000
Clear-Port 8000

# 1. Start Django Backend
Write-Host "[1/2] Launching Backend (Django)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'backend'; if (Test-Path 'venv\Scripts\Activate.ps1') { .\venv\Scripts\Activate.ps1 }; python manage.py runserver"

# 2. Start Flutter Frontend
Write-Host "[2/2] Launching Frontend (Flutter Web)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'frontend'; flutter run -d chrome --web-port 5000"

Write-Host "SUCCESS: Both services are launching in fresh windows!" -ForegroundColor Yellow
Write-Host "Backend: http://127.0.0.1:8000"
Write-Host "Frontend: http://localhost:5000"
