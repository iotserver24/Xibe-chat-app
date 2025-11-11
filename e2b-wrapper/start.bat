@echo off
REM Quick start script for E2B Code Executor backend (Windows)

echo 🚀 Starting E2B Code Executor backend...

REM Check if .env exists
if not exist .env (
    echo ⚠️  .env file not found. Creating from .env.example...
    copy .env.example .env
    echo 📝 Please edit .env and add your E2B_API_KEY
    pause
    exit /b 1
)

REM Check if node_modules exists
if not exist node_modules (
    echo 📦 Installing dependencies...
    call npm install
)

REM Start the server
echo ✅ Starting server...
call npm start
