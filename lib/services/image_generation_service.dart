import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageGenerationService {
  static const String _baseUrl = 'https://image.pollinations.ai';
  static const String _token = 'uNoesre5jXDzjhiY';
  static const String _modelsEndpoint = '$_baseUrl/models';

  /// Fetch available image generation models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await http
          .get(
            Uri.parse(_modelsEndpoint),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> models = jsonDecode(response.body);
        return models.map((m) => m.toString()).toList();
      } else {
        // Return default models if API fails
        return ['flux', 'kontext', 'turbo', 'gptimage'];
      }
    } catch (e) {
      print('Error fetching image models: $e');
      // Return default models on error
      return ['flux', 'kontext', 'turbo', 'gptimage'];
    }
  }

  /// Generate an image using Pollinations.AI
  /// Returns the image bytes and metadata
  Future<Map<String, dynamic>> generateImage({
    required String prompt,
    String model = 'flux',
    int width = 1024,
    int height = 1024,
    int? seed,
    bool enhance = true,
    bool nologo = true,
    String? negativePrompt,
    double? guidanceScale,
    int? steps,
    bool? private,
  }) async {
    try {
      // Encode prompt for URL
      final encodedPrompt = Uri.encodeComponent(prompt);

      // Build URL with parameters
      final queryParams = <String, String>{
        'model': model,
        'width': width.toString(),
        'height': height.toString(),
        'token': _token,
        if (seed != null) 'seed': seed.toString(),
        'enhance': enhance.toString(),
        'nologo': nologo.toString(),
        if (negativePrompt != null && negativePrompt.isNotEmpty)
          'negative_prompt': negativePrompt,
        if (guidanceScale != null) 'guidance_scale': guidanceScale.toString(),
        if (steps != null) 'steps': steps.toString(),
        if (private != null) 'private': private.toString(),
      };

      final url = Uri.parse('$_baseUrl/prompt/$encodedPrompt')
          .replace(queryParameters: queryParams);

      // Make request
      final response = await http.get(
        url,
        headers: {
          'Accept': 'image/*',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'imageBytes': response.bodyBytes,
          'prompt': prompt,
          'model': model,
          'width': width,
          'height': height,
          'seed': seed,
          'negativePrompt': negativePrompt,
          'guidanceScale': guidanceScale,
          'steps': steps,
        };
      } else {
        throw Exception(
            'Image generation failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
