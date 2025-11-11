import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/ai_model.dart';
import '../services/mcp_client_service.dart';
import '../config/sync_config.dart';

/// Represents a streaming response chunk that can be either content or tool calls
class StreamChunk {
  final String? content;
  final List<Map<String, dynamic>>? toolCalls;

  StreamChunk({this.content, this.toolCalls});

  bool get isContent => content != null;
  bool get isToolCalls => toolCalls != null && toolCalls!.isNotEmpty;
}

class ApiService {
  // Use local chat-server for AI requests
  String get baseUrl => MONGODB_API_URL.replaceAll('/api', ''); // Remove /api suffix
  static const String chatEndpoint = '/api/ai/chat/completions';
  static const String modelsEndpoint = '/api/ai/models';

  final String? apiKey;
  String? _userId;

  ApiService({this.apiKey});

  void setUserId(String? userId) {
    _userId = userId;
  }

  /// Get the built-in image generation tool
  static McpTool getImageGenerationTool() {
    return McpTool(
      name: 'generate_image',
      description:
          'Generate an image using AI based on a text prompt. The AI can intelligently determine the best dimensions (width/height) based on the user\'s request (e.g., "banner", "square", "portrait", "landscape", "wallpaper", etc.). The AI can also set other parameters like negative_prompt, guidance_scale, steps, model, and seed for optimal results.',
      inputSchema: {
        'type': 'object',
        'properties': {
          'prompt': {
            'type': 'string',
            'description':
                'The text description of the image to generate. Be descriptive and include details about style, composition, colors, mood, etc.',
          },
          'width': {
            'type': 'integer',
            'description':
                'Image width in pixels. Choose based on user request: 1024 for square, 1920 for landscape/banner, 1080 for portrait, 2048 for high-res, etc. Default: 1024',
            'default': 1024,
          },
          'height': {
            'type': 'integer',
            'description':
                'Image height in pixels. Choose based on user request: 1024 for square, 1080 for landscape, 1920 for portrait/banner, 2048 for high-res, etc. Default: 1024',
            'default': 1024,
          },
          'model': {
            'type': 'string',
            'description':
                'The AI model to use for image generation. Options: flux (default, high quality), turbo (faster), kontext, gptimage. Default: flux',
            'enum': ['flux', 'turbo', 'kontext', 'gptimage'],
            'default': 'flux',
          },
          'negative_prompt': {
            'type': 'string',
            'description':
                'What to avoid in the image (e.g., "blurry, low quality, distorted"). Use this to improve image quality by excluding unwanted elements.',
          },
          'guidance_scale': {
            'type': 'number',
            'description':
                'How closely to follow the prompt. Higher values (7-20) follow prompt more strictly, lower values (1-7) allow more creativity. Typical range: 7-15. Default: 7.5',
            'minimum': 1,
            'maximum': 20,
          },
          'steps': {
            'type': 'integer',
            'description':
                'Number of diffusion steps. More steps = higher quality but slower. Range: 20-50. Default: 30',
            'minimum': 20,
            'maximum': 50,
          },
          'seed': {
            'type': 'integer',
            'description':
                'Random seed for reproducibility. If user wants the same image again, use the same seed. Leave null for random generation.',
          },
          'enhance': {
            'type': 'boolean',
            'description':
                'Let AI improve/enhance the prompt for better results. Default: true',
            'default': true,
          },
        },
        'required': ['prompt'],
      },
    );
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    // Add authentication headers for chat-server
    if (_userId != null) {
      headers['Authorization'] = 'Bearer token'; // Chat-server expects this
      headers['X-User-Id'] = _userId!;
    }
    
    return headers;
  }

  // Fetch available models from chat-server
  Future<List<AiModel>> fetchModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$modelsEndpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> modelsJson = jsonDecode(response.body);
        return modelsJson.map((json) => AiModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch models: $e');
    }
  }

  // Send message with streaming support
  Stream<String> sendMessageStream({
    required String message,
    required List<Message> history,
    required String model,
    String? systemPrompt,
    bool reasoning = false,
    List<McpTool>? mcpTools,
  }) async* {
    try {
      final request = http.Request(
        'POST',
        Uri.parse('$baseUrl$chatEndpoint'),
      );

      // Use chat-server authentication headers
      request.headers.addAll(_getHeaders());

      // Build messages array (without system prompt - sent separately)
      final messages = [
        ...history.map((m) => m.toApiFormat()),
        {'role': 'user', 'content': message},
      ];

      final requestBody = {
        'model': model,
        'messages': messages,
        'stream': true,
        if (systemPrompt != null && systemPrompt.isNotEmpty)
          'systemPrompt': systemPrompt,
        if (reasoning)
          'reasoning': {
            'enabled': true,
            'effort': 'medium', // Can be "low", "medium", or "high"
          },
        // Include MCP tools if available
        if (mcpTools != null && mcpTools.isNotEmpty)
          'tools': mcpTools
              .map((tool) => {
                    'type': 'function',
                    'function': {
                      'name': tool.name,
                      'description': tool.description,
                      'parameters': tool.inputSchema ?? {},
                    }
                  })
              .toList(),
      };

      request.body = jsonEncode(requestBody);
      
      print('📤 Sending AI request to: $baseUrl$chatEndpoint');
      print('   Model: $model, Stream: true, Messages: ${messages.length}');

      final streamedResponse = await request.send();

      print('📥 Response status: ${streamedResponse.statusCode}');
      
      if (streamedResponse.statusCode != 200) {
        // Try to read error body
        String errorBody = '';
        try {
          errorBody = await streamedResponse.stream.transform(utf8.decoder).join();
        } catch (_) {}
        
        print('❌ Server error: ${streamedResponse.statusCode}');
        print('   Error body: $errorBody');
        
        throw Exception(
            'Server returned status code: ${streamedResponse.statusCode}. $errorBody');
      }

      String buffer = '';
      int lineCount = 0;
      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += chunk;

        // Process complete lines
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty || !line.startsWith('data: ')) {
            continue;
          }

          final data = line.substring(6); // Remove 'data: ' prefix

          if (data == '[DONE]') {
            return;
          }

          try {
            final json = jsonDecode(data);
            final delta = json['choices']?[0]?['delta'];
            if (delta != null) {
              // Check for tool calls first
              if (delta['tool_calls'] != null) {
                final toolCalls = delta['tool_calls'] as List;
                // Yield tool calls as special JSON string that can be parsed later
                yield 'TOOL_CALLS:${jsonEncode(toolCalls)}';
              }
              // Check for content
              if (delta['content'] != null) {
                final content = delta['content'] as String;
                lineCount++;
                if (lineCount <= 3) {
                  print('   Line $lineCount: content length=${content.length}');
                }
                yield content;
              }
            }
            
            // Check for errors in response
            if (json['error'] != null) {
              print('❌ API error in stream: ${json['error']}');
              throw Exception('API error: ${json['error']}');
            }
          } catch (e) {
            // Log JSON decode errors but continue
            if (lineCount < 5) {
              print('⚠️  JSON decode error (line $lineCount): $e');
              print('   Data: ${data.substring(0, data.length > 100 ? 100 : data.length)}');
            }
            continue;
          }
        }
      }
      
      print('✅ Stream processing complete. Total lines processed: $lineCount');
      
      if (lineCount == 0) {
        print('⚠️  Warning: No content lines received from stream!');
        throw Exception('No content received from AI stream');
      }
    } catch (e, stackTrace) {
      print('❌ Error in sendMessageStream: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to send message: $e');
    }
  }

  // Non-streaming version for backward compatibility
  Future<String> sendMessage({
    required String message,
    required List<Message> history,
    required String model,
    String? systemPrompt,
  }) async {
    try {
      final messages = [
        ...history.map((m) => m.toApiFormat()),
        {'role': 'user', 'content': message},
      ];

      final response = await http
          .post(
            Uri.parse('$baseUrl$chatEndpoint'),
            headers: _getHeaders(),
            body: jsonEncode({
              'model': model,
              'messages': messages,
              'stream': false,
              if (systemPrompt != null && systemPrompt.isNotEmpty)
                'systemPrompt': systemPrompt,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
