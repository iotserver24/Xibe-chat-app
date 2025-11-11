# Comprehensive test script for E2B Code Executor API
# Tests all languages and various code patterns

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "E2B Code Executor - Comprehensive Test Suite" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:3000"
$results = @()

function Test-CodeExecution {
    param(
        [string]$Language,
        [string]$Code,
        [string]$Description
    )
    
    Write-Host "`n[TEST] $Description" -ForegroundColor Yellow
    Write-Host "Language: $Language" -ForegroundColor Gray
    Write-Host "Code:" -ForegroundColor Gray
    Write-Host $Code -ForegroundColor DarkGray
    Write-Host ""
    
    $body = @{
        code = $Code
        language = $Language
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/execute" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 90
        
        if ($response.success) {
            Write-Host "✅ Success" -ForegroundColor Green
            
            # Show stdout
            if ($response.execution.logs.stdout -and $response.execution.logs.stdout.Count -gt 0) {
                Write-Host "Output:" -ForegroundColor Cyan
                $response.execution.logs.stdout | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            }
            
            # Show stderr
            if ($response.execution.logs.stderr -and $response.execution.logs.stderr.Count -gt 0) {
                Write-Host "Stderr:" -ForegroundColor Yellow
                $response.execution.logs.stderr | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            }
            
            # Show results (charts, images, etc.)
            if ($response.execution.results -and $response.execution.results.Count -gt 0) {
                Write-Host "Results:" -ForegroundColor Magenta
                Write-Host ($response.execution.results | ConvertTo-Json -Depth 5) -ForegroundColor DarkGray
            }
            
            # Show error if any
            if ($response.execution.error) {
                Write-Host "Error:" -ForegroundColor Red
                Write-Host ($response.execution.error | ConvertTo-Json -Depth 3) -ForegroundColor Red
            }
            
            $script:results += [PSCustomObject]@{
                Test = $Description
                Language = $Language
                Status = "✅ PASSED"
            }
        } else {
            Write-Host "❌ Failed: $($response.error)" -ForegroundColor Red
            $script:results += [PSCustomObject]@{
                Test = $Description
                Language = $Language
                Status = "❌ FAILED"
            }
        }
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails.Message) {
            Write-Host $_.ErrorDetails.Message -ForegroundColor Red
        }
        $script:results += [PSCustomObject]@{
            Test = $Description
            Language = $Language
            Status = "❌ ERROR"
        }
    }
    
    Start-Sleep -Seconds 1
}

# Test 1: Python - Simple Print
Test-CodeExecution -Language "python" -Code @"
print('Hello from Python!')
print('Python test successful!')
"@ -Description "Python - Simple Print Statements"

# Test 2: Python - Calculations
Test-CodeExecution -Language "python" -Code @"
x = 10
y = 20
result = x + y * 2
print(f'Result: {result}')
print(f'Sum: {x + y}')
"@ -Description "Python - Mathematical Calculations"

# Test 3: Python - List Operations
Test-CodeExecution -Language "python" -Code @"
numbers = [1, 2, 3, 4, 5]
squared = [x**2 for x in numbers]
print(f'Original: {numbers}')
print(f'Squared: {squared}')
print(f'Sum: {sum(numbers)}')
"@ -Description "Python - List Operations"

# Test 4: Python - Code with input() (will work if input provided via variables)
Test-CodeExecution -Language "python" -Code @"
# Simulating user input by using variables instead
user_name = "TestUser"
user_age = 25
print(f'Hello, {user_name}!')
print(f'You are {user_age} years old.')
print(f'In 10 years, you will be {user_age + 10}')
"@ -Description "Python - Simulated User Input (via variables)"

# Test 5: Python - Matplotlib Chart (if available)
Test-CodeExecution -Language "python" -Code @"
try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    import numpy as np
    
    x = np.linspace(0, 10, 100)
    y = np.sin(x)
    
    plt.figure(figsize=(8, 6))
    plt.plot(x, y)
    plt.title('Sine Wave')
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.savefig('/tmp/chart.png')
    print('Chart generated successfully!')
    print('Chart saved to /tmp/chart.png')
except ImportError:
    print('Matplotlib not available, skipping chart generation')
except Exception as e:
    print(f'Error generating chart: {e}')
"@ -Description "Python - Matplotlib Chart Generation"

# Test 6: Python - Error Handling
Test-CodeExecution -Language "python" -Code @"
try:
    result = 10 / 0
except ZeroDivisionError as e:
    print(f'Caught error: {e}')
    print('Error handling works correctly!')
"@ -Description "Python - Error Handling"

# Test 7: JavaScript - Simple Console Log
Test-CodeExecution -Language "js" -Code @"
console.log('Hello from JavaScript!');
console.log('JavaScript test successful!');
"@ -Description "JavaScript - Simple Console Log"

# Test 8: JavaScript - Variables and Functions
Test-CodeExecution -Language "js" -Code @"
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);
const sum = numbers.reduce((a, b) => a + b, 0);

console.log('Original:', numbers);
console.log('Doubled:', doubled);
console.log('Sum:', sum);
"@ -Description "JavaScript - Arrays and Functions"

# Test 9: JavaScript - Async/Await
Test-CodeExecution -Language "js" -Code @"
async function test() {
    return new Promise(resolve => {
        setTimeout(() => {
            console.log('Async function executed!');
            resolve('Done');
        }, 100);
    });
}

test().then(result => {
    console.log('Promise resolved:', result);
});
"@ -Description "JavaScript - Async/Await"

# Test 10: TypeScript (JavaScript subset)
Test-CodeExecution -Language "ts" -Code @"
interface User {
    name: string;
    age: number;
}

const user: User = {
    name: "TypeScript User",
    age: 30
};

console.log(`Hello, ${user.name}!`);
console.log(`You are ${user.age} years old.`);
"@ -Description "TypeScript - TypeScript Code"

# Test 11: R - Simple Print
Test-CodeExecution -Language "r" -Code @"
print("Hello from R!")
print("R test successful!")
"@ -Description "R - Simple Print Statements"

# Test 12: R - Data Operations
Test-CodeExecution -Language "r" -Code @"
# Create a vector
numbers <- c(1, 2, 3, 4, 5)
print(paste("Original:", paste(numbers, collapse=", ")))

# Calculate statistics
print(paste("Sum:", sum(numbers)))
print(paste("Mean:", mean(numbers)))
print(paste("Max:", max(numbers)))
"@ -Description "R - Data Operations"

# Test 13: Java - Simple Program
Test-CodeExecution -Language "java" -Code @"
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello from Java!");
        System.out.println("Java test successful!");
        
        int x = 10;
        int y = 20;
        System.out.println("Sum: " + (x + y));
    }
}
"@ -Description "Java - Simple Java Program"

# Test 14: Bash - Simple Commands
Test-CodeExecution -Language "bash" -Code @"
echo "Hello from Bash!"
echo "Bash test successful!"
echo "Current date: $(date)"
echo "Current user: $(whoami)"
"@ -Description "Bash - Simple Shell Commands"

# Test 15: Bash - Script Logic
Test-CodeExecution -Language "bash" -Code @"
#!/bin/bash

numbers=(1 2 3 4 5)
sum=0

for num in "${numbers[@]}"; do
    sum=$((sum + num))
    echo "Number: $num"
done

echo "Sum: $sum"
"@ -Description "Bash - Script with Loops"

# Test 16: Python - Code requiring multiple inputs (simulated)
Test-CodeExecution -Language "python" -Code @"
# Simulating multiple user inputs
users = [
    {"name": "Alice", "score": 95},
    {"name": "Bob", "score": 87},
    {"name": "Charlie", "score": 92}
]

print("Student Scores:")
for user in users:
    print(f"{user['name']}: {user['score']}")

average = sum(u['score'] for u in users) / len(users)
print(f"\nAverage Score: {average:.2f}")
"@ -Description "Python - Multiple Inputs Simulation"

# Test 17: Python - Real-time calculation loop
Test-CodeExecution -Language "python" -Code @"
import time

print("Starting calculations...")
for i in range(5):
    result = i ** 2
    print(f"i={i}, i²={result}")
    time.sleep(0.1)  # Simulate processing time

print("Calculations complete!")
"@ -Description "Python - Real-time Loop with Delays"

# Summary
Write-Host "`n" -NoNewline
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

$results | Format-Table -AutoSize

$passed = ($results | Where-Object { $_.Status -like "*PASSED*" }).Count
$failed = ($results | Where-Object { $_.Status -like "*FAILED*" }).Count
$errors = ($results | Where-Object { $_.Status -like "*ERROR*" }).Count
$total = $results.Count

Write-Host ""
Write-Host "Total Tests: $total" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host "Errors: $errors" -ForegroundColor Red
Write-Host ""

if ($failed -eq 0 -and $errors -eq 0) {
    Write-Host "🎉 All tests passed!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some tests failed or had errors" -ForegroundColor Yellow
}
