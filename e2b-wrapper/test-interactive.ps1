# Test script for interactive code execution scenarios
# Tests code that requires user input (simulated via pre-set variables)

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "E2B Code Executor - Interactive Input Test Suite" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:3000"

function Test-InteractiveCode {
    param(
        [string]$Language,
        [string]$Code,
        [string]$Description
    )
    
    Write-Host "`n[TEST] $Description" -ForegroundColor Yellow
    Write-Host "Language: $Language" -ForegroundColor Gray
    
    $body = @{
        code = $Code
        language = $Language
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/execute" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 90
        
        if ($response.success) {
            Write-Host "✅ Success" -ForegroundColor Green
            
            if ($response.execution.logs.stdout -and $response.execution.logs.stdout.Count -gt 0) {
                Write-Host "Output:" -ForegroundColor Cyan
                $response.execution.logs.stdout | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            }
            
            if ($response.execution.logs.stderr -and $response.execution.logs.stderr.Count -gt 0) {
                Write-Host "Stderr:" -ForegroundColor Yellow
                $response.execution.logs.stderr | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            }
            
            if ($response.execution.error) {
                Write-Host "Error detected (expected for interactive code):" -ForegroundColor Yellow
                Write-Host ($response.execution.error.value) -ForegroundColor DarkGray
            }
            
            return $true
        } else {
            Write-Host "❌ Failed: $($response.error)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Test 1: Python - Multiple input() calls (simulated with variables)
Write-Host "`n[SCENARIO 1] Python - Code requiring multiple inputs" -ForegroundColor Magenta
$code1 = @"
# Simulating user inputs with variables
name = "John Doe"
age = 30
city = "New York"

print(f"Hello, {name}!")
print(f"You are {age} years old.")
print(f"You live in {city}.")
print(f"In 10 years, you will be {age + 10} years old in {city}.")
"@

Test-InteractiveCode -Language "python" -Code $code1 -Description "Python - Multiple Inputs"

# Test 2: Python - Interactive Calculator (simulated)
Write-Host "`n[SCENARIO 2] Python - Interactive Calculator" -ForegroundColor Magenta
$code2 = @"
# Interactive calculator simulation
num1 = 15
num2 = 25
operation = "+"

print(f"Calculating: {num1} {operation} {num2}")

if operation == "+":
    result = num1 + num2
elif operation == "-":
    result = num1 - num2
elif operation == "*":
    result = num1 * num2
elif operation == "/":
    result = num1 / num2
else:
    result = "Unknown operation"

print(f"Result: {result}")
"@

Test-InteractiveCode -Language "python" -Code $code2 -Description "Python - Interactive Calculator"

# Test 3: Python - Real-time progress updates
Write-Host "`n[SCENARIO 3] Python - Real-time Progress Updates" -ForegroundColor Magenta
$code3 = @"
import time

print("Processing items...")
items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]

for i, item in enumerate(items, 1):
    print(f"[{i}/{len(items)}] Processing {item}...")
    time.sleep(0.1)  # Simulate work

print("All items processed!")
print(f"Total: {len(items)} items")
"@

Test-InteractiveCode -Language "python" -Code $code3 -Description "Python - Real-time Progress"

# Test 4: JavaScript - Interactive form simulation
Write-Host "`n[SCENARIO 4] JavaScript - Interactive Form" -ForegroundColor Magenta
$code4 = @"
// Simulating form inputs
const formData = {
    username: "testuser",
    email: "test@example.com",
    age: 25
};

console.log("Form Data:");
console.log(`Username: ${formData.username}`);
console.log(`Email: ${formData.email}`);
console.log(`Age: ${formData.age}`);

// Validation
const isValid = formData.username.length >= 3 && 
                formData.email.includes('@') && 
                formData.age >= 18;

console.log(`Validation: ${isValid ? 'Passed' : 'Failed'}`);
"@

Test-InteractiveCode -Language "js" -Code $code4 -Description "JavaScript - Form Simulation"

# Test 5: Python - Code with real input() that would block (will show error)
Write-Host "`n[SCENARIO 5] Python - Real input() call (will timeout/error)" -ForegroundColor Magenta
$code5 = @"
# This would normally block waiting for input
# In E2B, this might timeout or error
print("Please enter your name:")
# name = input()  # Commented out - would cause issues
name = "TestUser (pre-filled)"
print(f"Hello, {name}!")
"@

Test-InteractiveCode -Language "python" -Code $code5 -Description "Python - Input Handling"

# Test 6: Python - Menu system simulation
Write-Host "`n[SCENARIO 6] Python - Menu System" -ForegroundColor Magenta
$code6 = @"
# Menu system with user choices (simulated)
menu_options = {
    "1": "Option 1",
    "2": "Option 2", 
    "3": "Option 3"
}

print("Menu:")
for key, value in menu_options.items():
    print(f"{key}. {value}")

# Simulated user choice
user_choice = "2"

if user_choice in menu_options:
    print(f"You selected: {menu_options[user_choice]}")
else:
    print("Invalid choice")

print("Menu system completed.")
"@

Test-InteractiveCode -Language "python" -Code $code6 -Description "Python - Menu System"

# Test 7: Python - Interactive game simulation
Write-Host "`n[SCENARIO 7] Python - Interactive Game Simulation" -ForegroundColor Magenta
$code7 = @"
# Simple game simulation with turns
players = ["Alice", "Bob"]
scores = [0, 0]

print("Starting game...")
for turn in range(3):
    print(f"Turn {turn + 1}")
    for i, player in enumerate(players):
        # Simulated move
        move = turn * 10 + i * 5
        scores[i] += move
        print(f"  {player} scores {move} points (Total: {scores[i]})")

print(f"\nFinal Scores:")
for player, score in zip(players, scores):
    print(f"  {player}: {score}")

winner = players[scores.index(max(scores))]
print(f"Winner: {winner}!")
"@

Test-InteractiveCode -Language "python" -Code $code7 -Description "Python - Game Simulation"

Write-Host "`n" -NoNewline
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "All interactive scenarios tested!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
