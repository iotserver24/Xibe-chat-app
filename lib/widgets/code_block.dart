import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import '../services/e2b_service.dart';
import '../services/codesandbox_service.dart';
import '../screens/codesandbox_preview_screen.dart';

class CodeBlock extends StatefulWidget {
  final String code;
  final String? language;

  const CodeBlock({
    super.key,
    required this.code,
    this.language,
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _isRunning = false;
  String? _output;
  String? _error;
  List<Map<String, dynamic>>? _results; // Store all result types
  bool _isCreatingPreview = false;

  /// Check if the language starts with "codesandbox-"
  bool get _isCodesandboxPreview {
    final lang = widget.language?.toLowerCase() ?? '';
    return lang.startsWith('codesandbox-');
  }

  /// Extract the actual framework name from "codesandbox-{framework}"
  String? get _codesandboxFramework {
    if (!_isCodesandboxPreview) return null;
    final lang = widget.language?.toLowerCase() ?? '';
    return lang.replaceFirst('codesandbox-', '');
  }

  /// Check if the code can be executed based on language support
  bool get _canRun {
    final lang = widget.language?.toLowerCase();
    return lang == 'python' || 
           lang == 'py' ||
           lang == 'javascript' || 
           lang == 'js' || 
           lang == 'jsx' ||
           lang == 'typescript' ||
           lang == 'ts' ||
           lang == 'tsx' ||
           lang == 'react' ||
           lang == 'r' ||
           lang == 'java' ||
           lang == 'bash' ||
           lang == 'sh';
  }

  /// Map language to E2B language code
  String? get _e2bLanguageCode {
    final lang = widget.language?.toLowerCase();
    if (lang == 'python' || lang == 'py') return 'python';
    if (lang == 'javascript' || lang == 'js' || lang == 'jsx') return 'js';
    if (lang == 'typescript' || lang == 'ts' || lang == 'tsx') return 'ts';
    if (lang == 'react') return 'js'; // React uses JavaScript
    if (lang == 'r') return 'r';
    if (lang == 'java') return 'java';
    if (lang == 'bash' || lang == 'sh') return 'bash';
    return 'python'; // Default to Python
  }


  String get _displayLanguage {
    final lang = widget.language?.toLowerCase() ?? '';
    
    // Handle codesandbox- prefix
    if (lang.startsWith('codesandbox-')) {
      final framework = lang.replaceFirst('codesandbox-', '');
      if (framework == 'react') return 'React (Preview)';
      if (framework == 'vue') return 'Vue (Preview)';
      if (framework == 'angular') return 'Angular (Preview)';
      if (framework == 'svelte') return 'Svelte (Preview)';
      if (framework == 'html') return 'HTML (Preview)';
      return '${framework[0].toUpperCase()}${framework.substring(1)} (Preview)';
    }
    
    if (lang == 'jsx' || lang == 'tsx' || lang == 'react') return 'React';
    if (lang == 'js' || lang == 'javascript') return 'JavaScript';
    if (lang == 'ts' || lang == 'typescript') return 'TypeScript';
    if (lang == 'python' || lang == 'py') return 'Python';
    if (lang == 'r') return 'R';
    if (lang == 'java') return 'Java';
    if (lang == 'bash' || lang == 'sh') return 'Bash';
    return widget.language ?? 'Code';
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _output = null;
      _error = null;
      _results = null;
    });

    try {
      // Execute code using the backend wrapper
      // The backend handles sandbox creation and cleanup automatically
      // No API key needed - backend handles it
      // Backend URL comes from build environment variable or default
      final e2bService = E2bService();
      final languageCode = _e2bLanguageCode ?? 'python';
      final executionResult = await e2bService.executeCode(
        code: widget.code,
        language: languageCode,
      );

      // Parse the execution results
      // E2B API returns: { "execution": { "results": [...] } }
      final execution = executionResult['execution'] as Map<String, dynamic>?;
      final results = execution?['results'] as List<dynamic>? ?? [];
      
      // Process different result types: stdout, stderr, png, chart, text, error
      final List<Map<String, dynamic>> processedResults = [];
      String? combinedOutput;
      String? combinedError;

      for (final result in results) {
        final resultMap = result as Map<String, dynamic>;
        final type = resultMap['type'] as String?;
        
        switch (type) {
          case 'stdout':
          case 'text':
            final text = resultMap['text'] as String? ?? resultMap['content'] as String? ?? '';
            if (text.isNotEmpty) {
              processedResults.add({'type': type, 'content': text});
              combinedOutput = (combinedOutput ?? '') + text + '\n';
            }
            break;
          case 'stderr':
          case 'error':
            final text = resultMap['text'] as String? ?? resultMap['content'] as String? ?? resultMap['error'] as String? ?? '';
            if (text.isNotEmpty) {
              processedResults.add({'type': type, 'content': text});
              combinedError = (combinedError ?? '') + text + '\n';
            }
            break;
          case 'png':
            // Handle image outputs (charts, plots)
            final base64 = resultMap['base64'] as String? ?? resultMap['content'] as String?;
            if (base64 != null) {
              processedResults.add({'type': 'png', 'base64': base64});
              if (combinedOutput == null) {
                combinedOutput = '[Chart/Image generated]';
              }
            }
            break;
          case 'chart':
            // Handle interactive chart data
            final chartData = resultMap['chart'] as Map<String, dynamic>? ?? resultMap;
            processedResults.add({'type': 'chart', 'data': chartData});
            if (combinedOutput == null) {
              combinedOutput = '[Interactive chart generated]';
            }
            break;
        }
      }

      setState(() {
        _results = processedResults;
        _output = combinedOutput?.trim();
        _error = combinedError?.trim();
        
        // If no output and no error, show success message
        if (_output == null && _error == null) {
          _output = 'Code executed successfully';
        }
      });
    } on FormatException catch (e) {
      setState(() {
        _error = 'Invalid response from backend: ${e.message}';
      });
    } on http.ClientException catch (e) {
      setState(() {
        _error = 'Network error: ${e.message}\n\nPlease check your internet connection and ensure the backend server is accessible.';
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _runPreview() async {
    setState(() => _isCreatingPreview = true);

    try {
      // Create preview using codesandbox service
      final preview = await CodeSandboxService.createPreview(
        code: widget.code,
        framework: _codesandboxFramework,
      );

      if (!mounted) return;

      setState(() => _isCreatingPreview = false);

      // Open preview screen as a regular page transition (not fullscreen dialog)
      // This prevents blank page issues on Windows and improves navigation consistency
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodeSandboxPreviewScreen(
            embedUrl: preview.embedUrl,
            title: 'Code Preview',
            framework: preview.framework,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isCreatingPreview = false);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create preview: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFEF4444),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with language and buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _displayLanguage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_isCodesandboxPreview) ...[
                  IconButton(
                    icon: _isCreatingPreview
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10A37F)),
                            ),
                          )
                        : const Icon(Icons.play_circle_outline, size: 20),
                    color: const Color(0xFF10A37F),
                    onPressed: _isCreatingPreview ? null : _runPreview,
                    tooltip: 'Run Preview in CodeSandbox',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ] else if (_canRun) ...[
                  IconButton(
                    icon: _isRunning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          )
                        : const Icon(Icons.play_arrow, size: 20),
                    color: Colors.blue,
                    onPressed: _isRunning ? null : _runCode,
                    tooltip: 'Run code in E2B sandbox',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: Colors.white70,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'Copy code',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Code content with syntax highlighting
          Container(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                widget.code,
                // Strip codesandbox- prefix for syntax highlighting
                language: _isCodesandboxPreview 
                    ? (_codesandboxFramework == 'html' ? 'html' : 'javascript')
                    : (widget.language ?? 'plaintext'),
                theme: atomOneDarkTheme,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          // Output/Error display
          if (_output != null || _error != null || (_results != null && _results!.isNotEmpty))
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _error != null
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: _error != null
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _error != null ? Icons.error_outline : Icons.check_circle_outline,
                        size: 16,
                        color: _error != null ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _error != null ? 'Error' : 'Output',
                        style: TextStyle(
                          color: _error != null ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Display different result types
                  if (_results != null && _results!.isNotEmpty)
                    ...(_results!.map((result) {
                      final type = result['type'] as String?;
                      
                      if (type == 'png' && result['base64'] != null) {
                        // Display image/chart
                        try {
                          final base64 = result['base64'] as String;
                          // Remove data URL prefix if present
                          final base64Data = base64.contains(',') 
                              ? base64.split(',').last 
                              : base64;
                          final imageBytes = base64Decode(base64Data);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Image.memory(
                              Uint8List.fromList(imageBytes),
                              fit: BoxFit.contain,
                            ),
                          );
                        } catch (e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '[Unable to display image: $e]',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          );
                        }
                      } else if (type == 'chart' && result['data'] != null) {
                        // Display chart info (could be enhanced with a chart widget)
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.bar_chart, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Interactive chart generated',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList()),
                  // Display text output/error
                  if ((_output != null && _output!.isNotEmpty) || 
                      (_error != null && _error!.isNotEmpty))
                    SelectableText(
                      _error ?? _output ?? '',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
