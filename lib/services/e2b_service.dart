import 'dart:convert';
import 'package:http/http.dart' as http;

class E2bService {
  static const String baseUrl = 'https://api.e2b.dev';
  static const String productionBackendUrl = 'https://e2b.n92dev.us.kg';
  static const String localBackendUrl = 'http://localhost:3000';
  final String? apiKey;
  final String? backendUrl; // Allow override for custom backend URL

  E2bService({this.apiKey, this.backendUrl});

  /// Create a new sandbox for code execution
  Future<Map<String, dynamic>> createSandbox({String template = 'base'}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sandboxes'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey!,
        },
        body: jsonEncode({
          'templateID': template,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create sandbox: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create sandbox: $e');
    }
  }

  /// Execute code using the Node.js backend wrapper
  /// Supports: Python (default), JavaScript (js), TypeScript (ts), R (r), Java (java), Bash (bash)
  /// The backend handles sandbox creation and cleanup automatically
  Future<Map<String, dynamic>> executeCode({
    required String code,
    String language = 'python',
    String? sandboxId, // Not needed when using backend, kept for backward compatibility
  }) async {
    // Use custom backend URL if provided, otherwise use production URL
    final backendBaseUrl = backendUrl ?? productionBackendUrl;
    
    try {
      final requestBody = <String, dynamic>{
        'code': code,
      };
      
      // Add language parameter (backend handles default Python)
      requestBody['language'] = language;

      final response = await http.post(
        Uri.parse('$backendBaseUrl/execute'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 90)); // Increased timeout for code execution

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Check if request was successful
        if (responseData['success'] == true) {
          // Transform backend response to match expected format
          final execution = responseData['execution'] as Map<String, dynamic>;
          
          // Convert logs format: { stdout: [...], stderr: [...] } to individual result items
          final List<dynamic> results = [];
          
          // Add stdout messages as text results
          final logs = execution['logs'] as Map<String, dynamic>?;
          if (logs != null) {
            final stdout = logs['stdout'] as List<dynamic>? ?? [];
            for (final line in stdout) {
              if (line.toString().trim().isNotEmpty) {
                results.add({
                  'type': 'text',
                  'text': line.toString(),
                });
              }
            }
            
            // Add stderr messages as error results
            final stderr = logs['stderr'] as List<dynamic>? ?? [];
            for (final line in stderr) {
              if (line.toString().trim().isNotEmpty) {
                results.add({
                  'type': 'stderr',
                  'text': line.toString(),
                });
              }
            }
          }
          
          // Add execution results (from display() calls, charts, etc.)
          final executionResults = execution['results'] as List<dynamic>? ?? [];
          results.addAll(executionResults);
          
          // Add error if present
          final error = execution['error'];
          if (error != null) {
            final errorMap = error as Map<String, dynamic>;
            results.add({
              'type': 'error',
              'error': errorMap['value'] ?? errorMap['message'] ?? error.toString(),
              'text': errorMap['traceback'] ?? error.toString(),
            });
          }
          
          // Return in the format expected by code_block.dart
          return {
            'execution': {
              'results': results,
            },
          };
        } else {
          throw Exception(responseData['error'] ?? 'Code execution failed');
        }
      } else {
        final errorBody = response.body;
        throw Exception('Failed to execute code: ${response.statusCode} - $errorBody');
      }
    } on http.ClientException {
      throw Exception('Network error: Could not connect to backend at $backendBaseUrl. Please check your internet connection and the backend URL.');
    } catch (e) {
      throw Exception('Failed to execute code: $e');
    }
  }

  /// Execute Python code (backward compatibility)
  @Deprecated('Use executeCode instead')
  Future<Map<String, dynamic>> executePythonCode({
    required String code,
    String? sandboxId, // Not needed when using backend
  }) async {
    return executeCode(code: code, language: 'python', sandboxId: sandboxId);
  }

  /// Close a sandbox
  Future<void> closeSandbox(String sandboxId) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/sandboxes/$sandboxId'),
        headers: {
          'X-API-Key': apiKey!,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to close sandbox: ${response.statusCode}');
      }
    } catch (e) {
      // Silently fail on close errors
    }
  }

  /// Upload a file to the sandbox
  Future<void> uploadFile({
    required String sandboxId,
    required String path,
    required String content,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/filesystem/write'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey!,
        },
        body: jsonEncode({
          'path': path,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Read a file from the sandbox
  Future<String> readFile({
    required String sandboxId,
    required String path,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/filesystem/read?path=$path'),
        headers: {
          'X-API-Key': apiKey!,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'] as String;
      } else {
        throw Exception('Failed to read file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// List files in a directory
  Future<List<String>> listFiles({
    required String sandboxId,
    required String path,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/filesystem/list?path=$path'),
        headers: {
          'X-API-Key': apiKey!,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['files'] ?? []);
      } else {
        throw Exception('Failed to list files: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Install a package in the sandbox
  Future<Map<String, dynamic>> installPackage({
    required String sandboxId,
    required String packageName,
    String packageManager = 'pip',
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    String command;
    if (packageManager == 'pip') {
      command = 'pip install $packageName';
    } else if (packageManager == 'npm') {
      command = 'npm install $packageName';
    } else {
      command = '$packageManager install $packageName';
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/commands/run'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey!,
        },
        body: jsonEncode({
          'command': command,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to install package: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to install package: $e');
    }
  }
}
