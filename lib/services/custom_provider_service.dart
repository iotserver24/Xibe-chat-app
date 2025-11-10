import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/custom_provider.dart';
import '../services/mcp_client_service.dart';

class CustomProviderService {
  final CustomProvider provider;

  CustomProviderService({required this.provider});

  Stream<String> sendMessageStream({
    required String message,
    required List<Message> history,
    required String modelId,
    required String endpointUrl, // Full endpoint URL from model
    String? systemPrompt,
    bool reasoning = false,
    List<McpTool>? mcpTools,
  }) async* {
    try {
      // Use endpoint URL in this priority:
      // 1. Model's custom endpointUrl (if provided)
      // 2. Provider's endpointUrl (if provided)
      // 3. Auto-generate from provider baseUrl based on type
      final endpoint = endpointUrl.isNotEmpty
          ? endpointUrl
          : (provider.endpointUrl?.isNotEmpty == true
              ? provider.endpointUrl!
              : (provider.type == 'anthropic'
                  ? '${provider.baseUrl}/messages'
                  : '${provider.baseUrl}/chat/completions'));

      final request = http.Request('POST', Uri.parse(endpoint));

      final headers = {
        'Content-Type': 'application/json',
        if (provider.apiKey.isNotEmpty)
          'Authorization': provider.type == 'anthropic'
              ? 'x-api-key ${provider.apiKey}'
              : 'Bearer ${provider.apiKey}',
        ...?provider.additionalHeaders,
      };

      request.headers.addAll(headers);

      Map<String, dynamic> requestBody;

      if (provider.type == 'anthropic') {
        final messages = [
          ...history.map((m) => {
                'role': m.role,
                'content': m.content,
              }),
          {'role': 'user', 'content': message},
        ];

        requestBody = {
          'model': modelId,
          'messages': messages,
          'max_tokens': 4096,
          'stream': true,
          if (systemPrompt != null && systemPrompt.isNotEmpty)
            'system': systemPrompt,
        };
      } else {
        final messages = [
          if (systemPrompt != null && systemPrompt.isNotEmpty)
            {'role': 'system', 'content': systemPrompt},
          ...history.map((m) => m.toApiFormat()),
          {'role': 'user', 'content': message},
        ];

        requestBody = {
          'model': modelId,
          'messages': messages,
          'stream': true,
          if (reasoning)
            'reasoning': {
              'enabled': true,
              'effort': 'medium', // Can be "low", "medium", or "high"
            },
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
      }

      request.body = jsonEncode(requestBody);

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception(
            'Server returned status code: ${streamedResponse.statusCode}');
      }

      String buffer = '';
      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += chunk;

        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty || !line.startsWith('data: ')) {
            continue;
          }

          final data = line.substring(6);

          if (data == '[DONE]') {
            return;
          }

          try {
            final json = jsonDecode(data);

            if (provider.type == 'anthropic') {
              if (json['type'] == 'content_block_delta') {
                final delta = json['delta'];
                if (delta != null && delta['text'] != null) {
                  yield delta['text'] as String;
                }
              }
            } else {
              final delta = json['choices']?[0]?['delta'];
              if (delta != null && delta['content'] != null) {
                yield delta['content'] as String;
              }
            }
          } catch (e) {
            continue;
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
