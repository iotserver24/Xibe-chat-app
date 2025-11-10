# E2B Code Execution Guide

Complete guide to using E2B sandbox for code execution in Xibe Chat.

## Overview

E2B provides secure, isolated sandbox environments for executing code in multiple programming languages. Xibe Chat integrates E2B to allow users to run code directly in chat messages.

## Features

- **Multiple Languages**: Python, JavaScript, TypeScript, Java, R, Bash
- **Secure Execution**: Isolated sandbox environment
- **No API Key Required**: Uses backend wrapper (optional custom backend)
- **Automatic Cleanup**: Sandboxes are automatically cleaned up
- **Rich Output**: Supports stdout, stderr, images, charts, and more

---

## How It Works

### Architecture

```
User Code → E2B Backend → E2B Sandbox → Results → Display
```

The app uses a backend wrapper that:
1. Creates sandbox automatically
2. Executes code
3. Returns results
4. Cleans up sandbox

### Supported Languages

| Language | Code Tag | E2B Code |
|----------|----------|----------|
| Python | `python` or `py` | `python` |
| JavaScript | `javascript` or `js` | `js` |
| TypeScript | `typescript` or `ts` | `ts` |
| Java | `java` | `java` |
| R | `r` | `r` |
| Bash | `bash` or `sh` | `bash` |

---

## Usage

### Basic Execution

Simply write code in a code block with the appropriate language tag:

````markdown
```python
print("Hello, World!")
```
````

The app will show a "Run" button. Click it to execute the code.

### Example: Python

````markdown
```python
import math

def calculate_circle_area(radius):
    return math.pi * radius ** 2

radius = 5
area = calculate_circle_area(radius)
print(f"Area of circle with radius {radius}: {area:.2f}")
```
````

### Example: JavaScript

````markdown
```javascript
function fibonacci(n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

for (let i = 0; i < 10; i++) {
    console.log(`F(${i}) = ${fibonacci(i)}`);
}
```
````

### Example: Data Processing

````markdown
```python
import json

data = {
    "users": [
        {"name": "Alice", "age": 30},
        {"name": "Bob", "age": 25},
        {"name": "Charlie", "age": 35}
    ]
}

# Calculate average age
ages = [user["age"] for user in data["users"]]
avg_age = sum(ages) / len(ages)
print(f"Average age: {avg_age:.1f}")
```
````

---

## Output Types

E2B supports multiple output types:

### Text Output (stdout)

Standard output from print/console.log statements:

```python
print("Hello from Python!")
```

### Error Output (stderr)

Error messages and tracebacks:

```python
def divide(a, b):
    return a / b

result = divide(10, 0)  # Will show error
```

### Images

Generate and display images:

```python
from PIL import Image
import io

# Create a simple image
img = Image.new('RGB', (200, 200), color='blue')
# Display the image
```

### Charts

Create data visualizations:

```python
import matplotlib.pyplot as plt

x = [1, 2, 3, 4, 5]
y = [2, 4, 6, 8, 10]
plt.plot(x, y)
plt.show()
```

---

## Configuration

### Backend URL

The app uses a default backend URL, but you can configure a custom one:

**Via Environment Variable** (build time):
```bash
flutter run --dart-define=E2B_BACKEND_URL=https://your-backend.com
```

**Via Settings** (runtime):
1. Open Settings → Code Execution (E2B)
2. Enter custom backend URL
3. Save

### Default Backend

Default backend URL: `https://e2b.n92dev.us.kg`

This backend:
- Handles sandbox creation/cleanup
- Manages E2B API keys
- Provides secure execution environment

---

## Backend Setup (Optional)

If you want to run your own E2B backend:

### Requirements

- Node.js 18+
- E2B API key (from [e2b.dev](https://e2b.dev))

### Backend Endpoint

Your backend should provide:

**POST /execute**

Request:
```json
{
  "code": "print('Hello')",
  "language": "python"
}
```

Response:
```json
{
  "success": true,
  "execution": {
    "logs": {
      "stdout": ["Hello"],
      "stderr": []
    },
    "results": [],
    "error": null
  }
}
```

### Example Backend

```javascript
const express = require('express');
const { Sandbox } = require('@e2b/sdk');

const app = express();
app.use(express.json());

app.post('/execute', async (req, res) => {
  const { code, language = 'python' } = req.body;
  
  const sandbox = await Sandbox.create({ template: 'base' });
  
  try {
    const execution = await sandbox.runCode(code, { language });
    
    res.json({
      success: true,
      execution: {
        logs: execution.logs,
        results: execution.results,
        error: execution.error
      }
    });
  } finally {
    await sandbox.close();
  }
});

app.listen(3000);
```

---

## Limitations

### No Interactive Input

E2B execution does **not** support:
- `input()` calls (Python)
- `readline()` (Node.js)
- Interactive prompts
- User input during execution

### No Frameworks

For web frameworks (React, Vue, etc.), use **CodeSandbox** instead.

### Execution Timeout

- Default timeout: 90 seconds
- Long-running code may timeout

### Resource Limits

- Memory: Limited per sandbox
- CPU: Shared resources
- Disk: Temporary storage only

---

## Best Practices

### 1. Use Appropriate Tool

- **E2B**: Algorithms, data processing, calculations, scripts
- **CodeSandbox**: UI components, web apps, visual demos

### 2. Keep Code Focused

Write focused, single-purpose code blocks:

```python
# Good: Focused calculation
def calculate_tax(amount, rate):
    return amount * (rate / 100)

# Bad: Too complex, multiple concerns
```

### 3. Handle Errors

Include error handling:

```python
try:
    result = risky_operation()
    print(f"Success: {result}")
except Exception as e:
    print(f"Error: {e}")
```

### 4. Use Comments

Add comments for clarity:

```python
# Calculate compound interest
principal = 1000
rate = 0.05
years = 10
amount = principal * (1 + rate) ** years
print(f"Final amount: ${amount:.2f}")
```

---

## Troubleshooting

### Code Not Executing

1. Check language tag is correct
2. Verify backend URL is accessible
3. Check network connection
4. Review error message

### Execution Timeout

- Simplify code
- Reduce iterations
- Optimize algorithms
- Split into smaller chunks

### Backend Errors

- Verify backend URL
- Check backend logs
- Ensure backend is running
- Test backend health endpoint

### No Output

- Check for print/console.log statements
- Verify code actually runs
- Check for silent errors
- Review execution logs

---

## Security

### Sandbox Isolation

- Each execution runs in isolated sandbox
- No access to host system
- Network access limited
- Temporary storage only

### Code Safety

- Code is executed as-is
- No code review or validation
- User responsible for code safety
- Backend may implement additional security

---

## Additional Resources

- [E2B Documentation](https://e2b.dev/docs)
- [E2B SDK](https://github.com/e2b-dev/e2b)
- [E2B Templates](https://e2b.dev/docs/templates)

---

## Examples

### Data Analysis

```python
import pandas as pd

data = {
    'name': ['Alice', 'Bob', 'Charlie'],
    'score': [85, 92, 78]
}
df = pd.DataFrame(data)
print(df.describe())
```

### API Request

```python
import requests

response = requests.get('https://api.github.com/users/octocat')
data = response.json()
print(f"Name: {data['name']}")
print(f"Followers: {data['followers']}")
```

### File Operations

```python
# Create a file
with open('test.txt', 'w') as f:
    f.write('Hello, World!')

# Read the file
with open('test.txt', 'r') as f:
    content = f.read()
    print(content)
```

---

**Note**: E2B is for computational code execution. For visual web UI code, use CodeSandbox previews instead.

