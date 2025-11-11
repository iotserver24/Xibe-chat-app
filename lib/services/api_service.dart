import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/ai_model.dart';
import '../services/mcp_client_service.dart';

/// Represents a streaming response chunk that can be either content or tool calls
class StreamChunk {
  final String? content;
  final List<Map<String, dynamic>>? toolCalls;

  StreamChunk({this.content, this.toolCalls});

  bool get isContent => content != null;
  bool get isToolCalls => toolCalls != null && toolCalls!.isNotEmpty;
}

class ApiService {
  static const String baseUrl = 'https://api.xibe.app';
  static const String chatEndpoint = '/openai/v1/chat/completions';
  static const String modelsEndpoint = '/api/xibe/models';

  final String? apiKey;

  ApiService({this.apiKey});

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

  // Fetch available models from Xibe API
  Future<List<AiModel>> fetchModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$modelsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
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

      request.headers.addAll({
        'Content-Type': 'application/json',
        if (apiKey != null && apiKey!.isNotEmpty)
          'Authorization': 'Bearer $apiKey',
      });

      // Build messages array in OpenAI format
      final messages = [
        if (systemPrompt != null && systemPrompt.isNotEmpty)
          {'role': 'system', 'content': systemPrompt},
        ...history.map((m) => m.toApiFormat()),
        {'role': 'user', 'content': message},
      ];

      final requestBody = {
        'model': model,
        'messages': messages,
        'stream': true,
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

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception(
            'Server returned status code: ${streamedResponse.statusCode}');
      }

      String buffer = '';
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
                yield delta['content'] as String;
              }
            }
          } catch (e) {
            // Skip invalid JSON chunks
            continue;
          }
        }
      }
    } catch (e) {
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
        if (systemPrompt != null && systemPrompt.isNotEmpty)
          {'role': 'system', 'content': systemPrompt},
        ...history.map((m) => m.toApiFormat()),
        {'role': 'user', 'content': message},
      ];

      final response = await http
          .post(
            Uri.parse('$baseUrl$chatEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              if (apiKey != null && apiKey!.isNotEmpty)
                'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': model,
              'messages': messages,
              'stream': false,
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
