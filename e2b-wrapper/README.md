# E2B Code Executor - Node.js Backend Wrapper

A Node.js Express backend that wraps the E2B Code Interpreter SDK to provide a REST API endpoint for executing code in secure, isolated sandboxes. This backend enables Flutter and other applications to execute code in multiple languages without directly using the E2B SDK.

## 🚀 Features

- **Multi-language Support**: Python, JavaScript, TypeScript, R, Java, and Bash
- **Secure Execution**: Code runs in isolated E2B sandboxes
- **Automatic Cleanup**: Sandboxes are automatically created and destroyed
- **Chart/Image Support**: Returns charts and images from code execution
- **Error Handling**: Comprehensive error handling and logging
- **REST API**: Simple HTTP endpoints for easy integration

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [API Reference](#api-reference)
  - [Health Check](#health-check)
  - [Execute Code](#execute-code)
- [Supported Languages](#supported-languages)
- [Request/Response Formats](#requestresponse-formats)
- [Error Handling](#error-handling)
- [Usage Examples](#usage-examples)
- [Integration with Flutter](#integration-with-flutter)
- [Troubleshooting](#troubleshooting)
- [Testing](#testing)

## Prerequisites

- Node.js 18+ (with ES modules support)
- npm or pnpm
- E2B API Key ([Get one here](https://e2b.dev))

## Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```
   
   Or with pnpm:
   ```bash
   pnpm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your E2B API key:
   ```env
   E2B_API_KEY=your_e2b_api_key_here
   PORT=3000
   ```

3. **Start the server:**
   ```bash
   npm start
   ```
   
   Or for development with auto-reload:
   ```bash
   npm run dev
   ```

   The server will start on `http://localhost:3000` by default.

## Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `E2B_API_KEY` | Your E2B API key | Yes | - |
| `PORT` | Server port | No | `3000` |

### Example `.env` file:
```env
E2B_API_KEY=e2b_your_api_key_here
PORT=3000
```

## API Reference

### Base URL
```
http://localhost:3000
```

### Health Check

Check if the server is running and healthy.

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "ok",
  "service": "E2B Code Executor"
}
```

**Example:**
```bash
curl http://localhost:3000/health
```

### Execute Code

Execute code in an E2B sandbox.

**Endpoint:** `POST /execute`

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "code": "print('Hello, World!')",
  "language": "python"
}
```

**Parameters:**

| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| `code` | string | Yes | The code to execute | - |
| `language` | string | No | Language code (see supported languages) | `"python"` |

**Response Format:**

**Success (200 OK):**
```json
{
  "success": true,
  "execution": {
    "results": [
      {
        "type": "text",
        "text": "Output text here"
      },
      {
        "type": "png",
        "base64": "iVBORw0KGgoAAAANSUhEUgAA..."
      }
    ],
    "logs": {
      "stdout": [
        "Hello, World!\n",
        "Output line 2\n"
      ],
      "stderr": [
        "Warning message\n"
      ]
    },
    "error": null
  }
}
```

**Error (500 Internal Server Error):**
```json
{
  "success": false,
  "error": "Error message here"
}
```

**Validation Error (400 Bad Request):**
```json
{
  "success": false,
  "error": "Code is required and must be a string"
}
```

## Supported Languages

| Language | Code | Description |
|----------|------|-------------|
| Python | `python` | Python 3 (default) |
| JavaScript | `js` | Node.js JavaScript |
| TypeScript | `ts` | TypeScript (compiled to JavaScript) |
| R | `r` | R statistical language |
| Java | `java` | Java |
| Bash | `bash` | Bash shell script |

### Language-Specific Notes

- **Python**: Default language, supports all standard libraries and can install packages via pip
- **JavaScript/TypeScript**: Runs in Node.js environment, supports npm packages
- **R**: R statistical computing environment
- **Java**: Full Java runtime
- **Bash**: Linux shell commands

## Request/Response Formats

### Code Execution Request

```json
{
  "code": "print('Hello from Python!')\nprint('Test successful!')",
  "language": "python"
}
```

### Successful Execution Response

The response contains three main sections:

1. **`execution.results`**: Array of result objects from display calls, charts, etc.
   - `type`: Result type (`text`, `png`, `chart`, etc.)
   - `text`: Text content (for text results)
   - `base64`: Base64 encoded image (for PNG results)
   - `chart`: Chart data object (for interactive charts)

2. **`execution.logs`**: Standard output and error streams
   - `stdout`: Array of strings printed to stdout
   - `stderr`: Array of strings printed to stderr

3. **`execution.error`**: Error object if execution failed
   - `name`: Error name (e.g., "SyntaxError", "ZeroDivisionError")
   - `value`: Error message
   - `traceback`: Full error traceback

### Example: Python with Output

**Request:**
```json
{
  "code": "x = 10\ny = 20\nprint(f'Sum: {x + y}')\nprint(f'Product: {x * y}')",
  "language": "python"
}
```

**Response:**
```json
{
  "success": true,
  "execution": {
    "results": [],
    "logs": {
      "stdout": [
        "Sum: 30\n",
        "Product: 200\n"
      ],
      "stderr": []
    },
    "error": null
  }
}
```

### Example: Python with Chart

**Request:**
```json
{
  "code": "import matplotlib\nmatplotlib.use('Agg')\nimport matplotlib.pyplot as plt\nimport numpy as np\n\nx = np.linspace(0, 10, 100)\ny = np.sin(x)\nplt.plot(x, y)\nplt.title('Sine Wave')\nplt.savefig('/tmp/chart.png')\nprint('Chart generated!')",
  "language": "python"
}
```

**Response:**
```json
{
  "success": true,
  "execution": {
    "results": [
      {
        "type": "png",
        "base64": "iVBORw0KGgoAAAANSUhEUgAA..."
      }
    ],
    "logs": {
      "stdout": [
        "Chart generated!\n"
      ],
      "stderr": []
    },
    "error": null
  }
}
```

### Example: JavaScript

**Request:**
```json
{
  "code": "const numbers = [1, 2, 3, 4, 5];\nconst sum = numbers.reduce((a, b) => a + b, 0);\nconsole.log(`Sum: ${sum}`);",
  "language": "js"
}
```

**Response:**
```json
{
  "success": true,
  "execution": {
    "results": [],
    "logs": {
      "stdout": [
        "Sum: 15\n"
      ],
      "stderr": []
    },
    "error": null
  }
}
```

### Example: Error Response

**Request:**
```json
{
  "code": "result = 10 / 0",
  "language": "python"
}
```

**Response:**
```json
{
  "success": true,
  "execution": {
    "results": [],
    "logs": {
      "stdout": [],
      "stderr": []
    },
    "error": {
      "name": "ZeroDivisionError",
      "value": "division by zero",
      "traceback": "Traceback (most recent call last):\n  File \"<stdin>\", line 1, in <module>\nZeroDivisionError: division by zero"
    }
  }
}
```

## Error Handling

The API uses standard HTTP status codes:

- **200 OK**: Code executed successfully (check `success` field and `error` in execution)
- **400 Bad Request**: Invalid request (missing code, invalid format)
- **500 Internal Server Error**: Server error or E2B API error

### Error Response Format

```json
{
  "success": false,
  "error": "Descriptive error message"
}
```

### Common Errors

1. **Missing Code:**
   ```json
   {
     "success": false,
     "error": "Code is required and must be a string"
   }
   ```

2. **E2B API Error:**
   ```json
   {
     "success": false,
     "error": "Failed to create sandbox: Invalid API key"
   }
   ```

3. **Execution Timeout:**
   - The execution might timeout if code runs too long (default 90 seconds)
   - Sandbox will still be cleaned up automatically

## Usage Examples

### cURL

**Simple Python execution:**
```bash
curl -X POST http://localhost:3000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "print(\"Hello, World!\")", "language": "python"}'
```

**JavaScript with arrays:**
```bash
curl -X POST http://localhost:3000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "const arr = [1,2,3]; console.log(arr.map(x => x*2));", "language": "js"}'
```

### Python (requests)

```python
import requests

url = "http://localhost:3000/execute"
payload = {
    "code": "print('Hello from Python!')\nprint('Test successful!')",
    "language": "python"
}

response = requests.post(url, json=payload)
result = response.json()

if result["success"]:
    print("Output:")
    for line in result["execution"]["logs"]["stdout"]:
        print(line, end="")
else:
    print(f"Error: {result['error']}")
```

### JavaScript/Node.js (fetch)

```javascript
const response = await fetch('http://localhost:3000/execute', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    code: "console.log('Hello from JavaScript!');",
    language: 'js'
  })
});

const result = await response.json();

if (result.success) {
  console.log('Output:', result.execution.logs.stdout);
} else {
  console.error('Error:', result.error);
}
```

### PowerShell

```powershell
$body = @{
    code = "print('Hello from PowerShell!')"
    language = "python"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:3000/execute" `
    -Method Post -Body $body -ContentType "application/json"

if ($response.success) {
    Write-Host "Output:"
    $response.execution.logs.stdout | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "Error: $($response.error)"
}
```

## Integration with Flutter

The Flutter app connects to this backend at `http://localhost:3000`. Example Flutter code:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> executeCode({
  required String code,
  String language = 'python',
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/execute'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'code': code,
      'language': language,
    }),
  ).timeout(const Duration(seconds: 90));

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to execute code: ${response.statusCode}');
  }
}
```

## Handling Interactive Input

E2B doesn't support real-time interactive `input()` calls. Instead, simulate user input by using variables:

**Instead of:**
```python
name = input("Enter your name: ")
age = int(input("Enter your age: "))
print(f"Hello {name}, you are {age} years old")
```

**Use:**
```python
# Simulate user input with variables
name = "John Doe"  # Would normally come from input()
age = 25  # Would normally come from input()
print(f"Hello {name}, you are {age} years old")
```

The backend will execute this code successfully without blocking.

## Troubleshooting

### Server won't start

1. **Check if port is in use:**
   ```bash
   # Windows
   netstat -ano | findstr :3000
   
   # Linux/Mac
   lsof -i :3000
   ```

2. **Verify E2B API key:**
   - Check `.env` file exists
   - Verify `E2B_API_KEY` is set correctly
   - Ensure API key is valid and has credits

### Connection refused errors

- Ensure server is running: `npm start`
- Check firewall settings
- Verify URL is correct: `http://localhost:3000`

### Execution timeouts

- Code execution has a 90-second timeout
- For longer-running code, consider breaking it into smaller chunks
- Check E2B account for any rate limits

### Code execution errors

- Check the `error` field in the response for detailed error messages
- Verify code syntax is correct for the specified language
- For Python, ensure required packages are installed (or included in code)

## Testing

The repository includes test scripts:

### Basic API Test

```bash
# PowerShell
.\test-api.ps1

# Bash
chmod +x test-api.sh
./test-api.sh
```

### Comprehensive Language Test

```bash
# PowerShell
.\test-all.ps1
```

### Interactive Input Test

```bash
# PowerShell
.\test-interactive.ps1
```

## Project Structure

```
execute/
├── server.js          # Main Express server
├── package.json       # Dependencies and scripts
├── .env.example      # Environment variables template
├── .env              # Your environment variables (not in git)
├── .gitignore        # Git ignore file
├── README.md         # This file
├── test-api.ps1      # Basic API test script
├── test-all.ps1      # Comprehensive test suite
└── test-interactive.ps1 # Interactive input tests
```

## Security Considerations

- **API Key**: Never commit `.env` file to version control
- **Sandbox Isolation**: Each execution runs in an isolated sandbox
- **Automatic Cleanup**: Sandboxes are automatically destroyed after execution
- **Network**: Consider adding authentication/authorization for production use
- **Rate Limiting**: Consider implementing rate limiting for production

## Limitations

1. **Interactive Input**: Real-time `input()` is not supported; use variables instead
2. **File Persistence**: Files created in one execution are not available in the next
3. **Execution Timeout**: Default timeout is 90 seconds
4. **Network Access**: Sandboxes have internet access by default

## Performance Notes

- **Sandbox Creation**: ~150ms startup time per execution
- **Network Latency**: Additional latency from HTTP requests
- **Concurrent Requests**: Server handles requests sequentially by default
- **Resource Usage**: Each sandbox uses minimal resources

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

ISC

## Support

For issues related to:
- **E2B SDK**: Check [E2B Documentation](https://e2b.dev/docs)
- **This Backend**: Open an issue in the repository
- **Flutter Integration**: See the main Flutter project documentation

## Changelog

### v1.0.0
- Initial release
- Support for Python, JavaScript, TypeScript, R, Java, Bash
- REST API endpoints
- Automatic sandbox management
- Chart/image support