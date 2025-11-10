class CustomProvider {
  final String id;
  final String name;
  final String baseUrl;
  final String apiKey;
  final String type;
  final bool isBuiltIn;
  final Map<String, String>? additionalHeaders;

  CustomProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.type,
    this.isBuiltIn = false,
    this.additionalHeaders,
  });

  factory CustomProvider.fromJson(Map<String, dynamic> json) {
    return CustomProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      apiKey: json['apiKey'] as String,
      type: json['type'] as String,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      additionalHeaders: json['additionalHeaders'] != null
          ? Map<String, String>.from(json['additionalHeaders'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'type': type,
      'isBuiltIn': isBuiltIn,
      'additionalHeaders': additionalHeaders,
    };
  }

  CustomProvider copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? apiKey,
    String? type,
    bool? isBuiltIn,
    Map<String, String>? additionalHeaders,
  }) {
    return CustomProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      type: type ?? this.type,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      additionalHeaders: additionalHeaders ?? this.additionalHeaders,
    );
  }

  static List<CustomProvider> getBuiltInProviders() {
    return [
      CustomProvider(
        id: 'xibe',
        name: 'Xibe',
        baseUrl: 'https://api.xibe.app',
        apiKey: '',
        type: 'openai',
        isBuiltIn: true,
      ),
      CustomProvider(
        id: 'openai',
        name: 'OpenAI',
        baseUrl: 'https://api.openai.com/v1',
        apiKey: '',
        type: 'openai',
        isBuiltIn: true,
      ),
      CustomProvider(
        id: 'anthropic',
        name: 'Anthropic',
        baseUrl: 'https://api.anthropic.com/v1',
        apiKey: '',
        type: 'anthropic',
        isBuiltIn: true,
        additionalHeaders: {
          'anthropic-version': '2023-06-01',
        },
      ),
      CustomProvider(
        id: 'openrouter',
        name: 'OpenRouter',
        baseUrl: 'https://openrouter.ai/api/v1',
        apiKey: '',
        type: 'openai',
        isBuiltIn: true,
      ),
      CustomProvider(
        id: 'together',
        name: 'Together AI',
        baseUrl: 'https://api.together.xyz/v1',
        apiKey: '',
        type: 'openai',
        isBuiltIn: true,
      ),
      CustomProvider(
        id: 'groq',
        name: 'Groq',
        baseUrl: 'https://api.groq.com/openai/v1',
        apiKey: '',
        type: 'openai',
        isBuiltIn: true,
      ),
    ];
  }
}
