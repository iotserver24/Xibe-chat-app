class CustomModel {
  final String id;
  final String name;
  final String modelId;
  final String providerId;
  final String description;
  final bool supportsVision;
  final bool supportsStreaming;
  final bool supportsTools;
  final int? maxTokens;

  CustomModel({
    required this.id,
    required this.name,
    required this.modelId,
    required this.providerId,
    required this.description,
    this.supportsVision = false,
    this.supportsStreaming = true,
    this.supportsTools = false,
    this.maxTokens,
  });

  factory CustomModel.fromJson(Map<String, dynamic> json) {
    return CustomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      modelId: json['modelId'] as String,
      providerId: json['providerId'] as String,
      description: json['description'] as String,
      supportsVision: json['supportsVision'] as bool? ?? false,
      supportsStreaming: json['supportsStreaming'] as bool? ?? true,
      supportsTools: json['supportsTools'] as bool? ?? false,
      maxTokens: json['maxTokens'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'modelId': modelId,
      'providerId': providerId,
      'description': description,
      'supportsVision': supportsVision,
      'supportsStreaming': supportsStreaming,
      'supportsTools': supportsTools,
      'maxTokens': maxTokens,
    };
  }

  CustomModel copyWith({
    String? id,
    String? name,
    String? modelId,
    String? providerId,
    String? description,
    bool? supportsVision,
    bool? supportsStreaming,
    bool? supportsTools,
    int? maxTokens,
  }) {
    return CustomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      modelId: modelId ?? this.modelId,
      providerId: providerId ?? this.providerId,
      description: description ?? this.description,
      supportsVision: supportsVision ?? this.supportsVision,
      supportsStreaming: supportsStreaming ?? this.supportsStreaming,
      supportsTools: supportsTools ?? this.supportsTools,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}
