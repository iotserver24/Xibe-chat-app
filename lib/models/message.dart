class Message {
  final int? id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final bool webSearchUsed;
  final int chatId;
  final String? imageBase64; // Base64 encoded image data for vision models
  final String? imagePath; // Local file path for displaying image
  final String? thinkingContent; // Content of AI thinking process
  final bool isThinking; // Whether AI is in thinking mode
  final int? responseTimeMs; // Response time in milliseconds
  final String? reaction; // User reaction: 'thumbs_up' or 'thumbs_down'
  final String? generatedImageBase64; // Base64 encoded generated image data
  final String? generatedImagePrompt; // Prompt used to generate the image
  final String? generatedImageModel; // Model used for image generation
  final bool isGeneratingImage; // Whether image is currently being generated
  final bool showDonationPrompt; // Whether to show donation prompt after this message

  Message({
    this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.webSearchUsed = false,
    required this.chatId,
    this.imageBase64,
    this.imagePath,
    this.thinkingContent,
    this.isThinking = false,
    this.responseTimeMs,
    this.reaction,
    this.generatedImageBase64,
    this.generatedImagePrompt,
    this.generatedImageModel,
    this.isGeneratingImage = false,
    this.showDonationPrompt = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'webSearchUsed': webSearchUsed ? 1 : 0,
      'chatId': chatId,
      'imageBase64': imageBase64,
      'imagePath': imagePath,
      'thinkingContent': thinkingContent,
      'isThinking': isThinking ? 1 : 0,
      'responseTimeMs': responseTimeMs,
      'reaction': reaction,
      'generatedImageBase64': generatedImageBase64,
      'generatedImagePrompt': generatedImagePrompt,
      'generatedImageModel': generatedImageModel,
      'isGeneratingImage': isGeneratingImage ? 1 : 0,
      'showDonationPrompt': showDonationPrompt ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      role: map['role'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      webSearchUsed: map['webSearchUsed'] == 1,
      chatId: map['chatId'],
      imageBase64: map['imageBase64'],
      imagePath: map['imagePath'],
      thinkingContent: map['thinkingContent'],
      isThinking: map['isThinking'] != null && map['isThinking'] == 1,
      responseTimeMs: map['responseTimeMs'] as int?,
      reaction: map['reaction'] as String?,
      generatedImageBase64: map['generatedImageBase64'] as String?,
      generatedImagePrompt: map['generatedImagePrompt'] as String?,
      generatedImageModel: map['generatedImageModel'] as String?,
      isGeneratingImage:
          map['isGeneratingImage'] != null && map['isGeneratingImage'] == 1,
      showDonationPrompt:
          map['showDonationPrompt'] != null && map['showDonationPrompt'] == 1,
    );
  }

  Map<String, dynamic> toApiFormat() {
    // For messages with images (vision models), use OpenAI's format
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      return {
        'role': role,
        'content': [
          {
            'type': 'text',
            'text': content,
          },
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$imageBase64',
            },
          },
        ],
      };
    }

    // Standard text-only message
    return {
      'role': role,
      'content': content,
    };
  }
}
