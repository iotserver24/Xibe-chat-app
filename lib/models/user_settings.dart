class UserSettings {
  final String? apiKey;
  final String? systemPrompt;
  final String? defaultModel;
  final String? imageGenerationModel;
  final double temperature;
  final int maxTokens;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;
  final String updateChannel;
  final String? selectedAiProfileId;
  final List<Map<String, dynamic>> aiProfiles;
  final List<Map<String, dynamic>> customProviders;
  final List<Map<String, dynamic>> customModels;
  final DateTime? lastSyncedAt;

  UserSettings({
    this.apiKey,
    this.systemPrompt,
    this.defaultModel,
    this.imageGenerationModel,
    required this.temperature,
    required this.maxTokens,
    required this.topP,
    required this.frequencyPenalty,
    required this.presencePenalty,
    required this.updateChannel,
    this.selectedAiProfileId,
    required this.aiProfiles,
    required this.customProviders,
    required this.customModels,
    this.lastSyncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'apiKey': apiKey,
      'systemPrompt': systemPrompt,
      'defaultModel': defaultModel,
      'imageGenerationModel': imageGenerationModel,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
      'frequencyPenalty': frequencyPenalty,
      'presencePenalty': presencePenalty,
      'updateChannel': updateChannel,
      'selectedAiProfileId': selectedAiProfileId,
      'aiProfiles': aiProfiles,
      'customProviders': customProviders,
      'customModels': customModels,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      apiKey: map['apiKey'] as String?,
      systemPrompt: map['systemPrompt'] as String?,
      defaultModel: map['defaultModel'] as String?,
      imageGenerationModel: map['imageGenerationModel'] as String?,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: map['maxTokens'] as int? ?? 2048,
      topP: (map['topP'] as num?)?.toDouble() ?? 1.0,
      frequencyPenalty: (map['frequencyPenalty'] as num?)?.toDouble() ?? 0.0,
      presencePenalty: (map['presencePenalty'] as num?)?.toDouble() ?? 0.0,
      updateChannel: map['updateChannel'] as String? ?? 'stable',
      selectedAiProfileId: map['selectedAiProfileId'] as String?,
      aiProfiles: (map['aiProfiles'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      customProviders: (map['customProviders'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      customModels: (map['customModels'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'] as String)
          : null,
    );
  }

  UserSettings copyWith({
    String? apiKey,
    String? systemPrompt,
    String? defaultModel,
    String? imageGenerationModel,
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    String? updateChannel,
    String? selectedAiProfileId,
    List<Map<String, dynamic>>? aiProfiles,
    List<Map<String, dynamic>>? customProviders,
    List<Map<String, dynamic>>? customModels,
    DateTime? lastSyncedAt,
  }) {
    return UserSettings(
      apiKey: apiKey ?? this.apiKey,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      defaultModel: defaultModel ?? this.defaultModel,
      imageGenerationModel: imageGenerationModel ?? this.imageGenerationModel,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      updateChannel: updateChannel ?? this.updateChannel,
      selectedAiProfileId: selectedAiProfileId ?? this.selectedAiProfileId,
      aiProfiles: aiProfiles ?? this.aiProfiles,
      customProviders: customProviders ?? this.customProviders,
      customModels: customModels ?? this.customModels,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

