import 'dart:convert';
import 'package:http/http.dart' as http;

class CodeSandboxService {
  // Change this to your deployed server URL in production
  static const String baseUrl = 'http://localhost:3000';

  /// Detects if code can be previewed in CodeSandbox
  /// Looks for <codesandbox> tags in the AI response
  static bool canPreview(String content) {
    return content.contains('<codesandbox>') || 
           content.contains('</codesandbox>');
  }

  /// Extracts code from <codesandbox> tags
  static String extractCode(String content) {
    final regex = RegExp(
      r'<codesandbox>(.*?)</codesandbox>',
      dotAll: true,
      multiLine: true,
    );
    final match = regex.firstMatch(content);
    return match?.group(1)?.trim() ?? content;
  }

  /// Detects the framework from code content
  static String detectFramework(String code) {
    final lowerCode = code.toLowerCase();
    
    if (lowerCode.contains('import react') || 
        lowerCode.contains('from \'react\'') || 
        lowerCode.contains('from "react"')) {
      return 'react';
    }
    if (lowerCode.contains('import vue') || 
        lowerCode.contains('from \'vue\'')) {
      return 'vue';
    }
    if (lowerCode.contains('@angular') || 
        lowerCode.contains('angular')) {
      return 'angular';
    }
    if (lowerCode.contains('svelte')) {
      return 'svelte';
    }
    if (lowerCode.contains('<!doctype html') || 
        lowerCode.contains('<html')) {
      return 'html';
    }
    
    return 'javascript';
  }

  /// Creates a preview sandbox
  static Future<CodeSandboxPreview> createPreview({
    required String code,
    String? framework,
  }) async {
    try {
      // Auto-detect framework if not provided
      framework ??= detectFramework(code);

      // Parse code into files based on framework
      final files = _parseCodeIntoFiles(code, framework);

      final response = await http.post(
        Uri.parse('$baseUrl/preview/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'files': files,
          'framework': framework,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return CodeSandboxPreview.fromJson(json);
      } else if (response.statusCode == 429) {
        throw CodeSandboxException(
          'Rate limit exceeded. Please try again later.',
          statusCode: 429,
        );
      } else {
        throw CodeSandboxException(
          'Failed to create preview: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is CodeSandboxException) rethrow;
      throw CodeSandboxException('Failed to create preview: $e');
    }
  }

  /// Parse code into file structure for CodeSandbox
  static Map<String, Map<String, String>> _parseCodeIntoFiles(
    String code,
    String framework,
  ) {
    // If code already contains multiple file markers, parse them
    if (code.contains('// File:') || code.contains('/* File:')) {
      return _parseMultiFileCode(code);
    }

    // Single file code - create appropriate structure based on framework
    switch (framework) {
      case 'react':
        return _createReactFiles(code);
      case 'vue':
        return _createVueFiles(code);
      case 'angular':
        return _createAngularFiles(code);
      case 'svelte':
        return _createSvelteFiles(code);
      case 'html':
        return _createHtmlFiles(code);
      default:
        return _createVanillaJsFiles(code);
    }
  }

  static Map<String, Map<String, String>> _parseMultiFileCode(String code) {
    final files = <String, Map<String, String>>{};
    final fileRegex = RegExp(
      r'//\s*File:\s*(.+?)\n(.*?)(?=//\s*File:|$)',
      dotAll: true,
      multiLine: true,
    );

    for (final match in fileRegex.allMatches(code)) {
      final fileName = match.group(1)?.trim() ?? 'index.js';
      final content = match.group(2)?.trim() ?? '';
      files[fileName] = {'content': content};
    }

    return files.isNotEmpty ? files : _createVanillaJsFiles(code);
  }

  static Map<String, Map<String, String>> _createReactFiles(String code) {
    // Check if code is already a complete component
    final hasImport = code.contains('import');
    final hasExport = code.contains('export');

    String appJs;
    if (hasImport && hasExport) {
      appJs = code;
    } else {
      appJs = '''
import React from 'react';

$code
''';
    }

    return {
      'package.json': {
        'content': jsonEncode({
          'dependencies': {
            'react': '^18.2.0',
            'react-dom': '^18.2.0',
          },
        }),
      },
      'public/index.html': {
        'content': '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Preview</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
''',
      },
      'src/index.js': {
        'content': '''
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
''',
      },
      'src/App.js': {
        'content': appJs,
      },
    };
  }

  static Map<String, Map<String, String>> _createVueFiles(String code) {
    return {
      'package.json': {
        'content': jsonEncode({
          'dependencies': {
            'vue': '^3.3.0',
          },
        }),
      },
      'index.html': {
        'content': '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Preview</title>
</head>
<body>
  <div id="app"></div>
  <script type="module" src="/src/main.js"></script>
</body>
</html>
''',
      },
      'src/main.js': {
        'content': '''
import { createApp } from 'vue';
import App from './App.vue';

createApp(App).mount('#app');
''',
      },
      'src/App.vue': {
        'content': code.contains('<template>') ? code : '''
<template>
  <div>
    $code
  </div>
</template>
''',
      },
    };
  }

  static Map<String, Map<String, String>> _createAngularFiles(String code) {
    return {
      'package.json': {
        'content': jsonEncode({
          'dependencies': {
            '@angular/core': '^16.0.0',
            '@angular/platform-browser': '^16.0.0',
            '@angular/platform-browser-dynamic': '^16.0.0',
          },
        }),
      },
      'src/index.html': {
        'content': '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Preview</title>
</head>
<body>
  <app-root></app-root>
</body>
</html>
''',
      },
      'src/main.ts': {
        'content': '''
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';

platformBrowserDynamic().bootstrapModule(AppModule);
''',
      },
      'src/app/app.component.ts': {
        'content': code,
      },
    };
  }

  static Map<String, Map<String, String>> _createSvelteFiles(String code) {
    return {
      'package.json': {
        'content': jsonEncode({
          'dependencies': {
            'svelte': '^4.0.0',
          },
        }),
      },
      'public/index.html': {
        'content': '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Preview</title>
</head>
<body>
</body>
</html>
''',
      },
      'src/main.js': {
        'content': '''
import App from './App.svelte';

const app = new App({
  target: document.body,
});

export default app;
''',
      },
      'src/App.svelte': {
        'content': code,
      },
    };
  }

  static Map<String, Map<String, String>> _createHtmlFiles(String code) {
    return {
      'index.html': {
        'content': code,
      },
    };
  }

  static Map<String, Map<String, String>> _createVanillaJsFiles(String code) {
    return {
      'index.html': {
        'content': '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Preview</title>
  <style>
    body {
      margin: 0;
      padding: 20px;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
  </style>
</head>
<body>
  <div id="root"></div>
  <script src="/index.js"></script>
</body>
</html>
''',
      },
      'index.js': {
        'content': code,
      },
    };
  }
}

class CodeSandboxPreview {
  final bool success;
  final String sandboxId;
  final String previewUrl;
  final String embedUrl;
  final String framework;

  CodeSandboxPreview({
    required this.success,
    required this.sandboxId,
    required this.previewUrl,
    required this.embedUrl,
    required this.framework,
  });

  factory CodeSandboxPreview.fromJson(Map<String, dynamic> json) {
    return CodeSandboxPreview(
      success: json['success'] as bool? ?? false,
      sandboxId: json['sandboxId'] as String? ?? '',
      previewUrl: json['previewUrl'] as String? ?? '',
      embedUrl: json['embedUrl'] as String? ?? '',
      framework: json['framework'] as String? ?? 'unknown',
    );
  }
}

class CodeSandboxException implements Exception {
  final String message;
  final int? statusCode;

  CodeSandboxException(this.message, {this.statusCode});

  @override
  String toString() => 'CodeSandboxException: $message';
}
