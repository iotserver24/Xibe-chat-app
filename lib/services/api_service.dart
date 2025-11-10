import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/ai_model.dart';
import '../services/mcp_client_service.dart';

class ApiService {
  static const String baseUrl = 'https://api.xibe.app';
  static const String chatEndpoint = '/openai/v1/chat/completions';
  static const String modelsEndpoint = '/api/xibe/models';

  final String? apiKey;

  ApiService({this.apiKey});

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
            if (delta != null && delta['content'] != null) {
              yield delta['content'] as String;
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
