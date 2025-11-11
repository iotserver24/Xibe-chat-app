import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/ai_model.dart';
import '../models/custom_provider.dart';
import '../models/custom_model.dart';
import '../services/chat_api_service.dart';
import '../services/api_service.dart';
import '../services/mcp_client_service.dart' show McpClientService, McpTool;

/// NEW ChatProvider - Cloud-only, no local database
class ChatProvider extends ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService();
  late ApiService _apiService;
  final McpClientService _mcpClientService = McpClientService();
  
  // Lightweight chat list (titles only)
  List<Chat> _chats = [];
  Chat? _currentChat;
  
  // Messages for current chat only
  List<Message> _messages = [];
  bool _hasMoreMessages = true;
  int _messageOffset = 0;
  static const int _messagePageSize = 50;
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isStreaming = false;
  String? _error;
  String _streamingContent = '';
  
  List<AiModel> _availableModels = [];
  // TODO: Re-enable custom providers/models in future
  // List<CustomProvider> _customProviders = [];
  // List<CustomModel> _customModels = [];
  String _selectedModel = 'gemini';
  String? _systemPrompt;
  String Function()? _memoryContextGetter;
  Future<void> Function(String)? _onMemoryExtracted;
  String? _pendingPrompt;
  String? _currentUserId; // Track current user ID to prevent unnecessary reloads
  bool _isLoadingChats = false; // Prevent concurrent loads

  // Getters
  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isStreaming => _isStreaming;
  String? get error => _error;
  String get streamingContent => _streamingContent;
  List<AiModel> get availableModels => _availableModels;
  // TODO: Re-enable custom providers/models in future
  // List<CustomProvider> get customProviders => _customProviders;
  // List<CustomModel> get customModels => _customModels;
  List<CustomProvider> get customProviders => [];
  List<CustomModel> get customModels => [];
  String get selectedModel => _selectedModel;
  String? get systemPrompt => _systemPrompt;
  String? get pendingPrompt => _pendingPrompt;

  void setPendingPrompt(String? prompt) {
    _pendingPrompt = prompt;
    notifyListeners();
  }

  void clearPendingPrompt() {
    _pendingPrompt = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get selectedModelSupportsVision {
    // TODO: Re-enable custom model vision check in future
    // final customModel = _customModels.firstWhere(
    //   (m) => m.modelId == _selectedModel,
    //   orElse: () => CustomModel(
    //     id: '',
    //     name: '',
    //     modelId: '',
    //     providerId: '',
    //     description: '',
    //     endpointUrl: '',
    //   ),
    // );

    // if (customModel.modelId.isNotEmpty) {
    //   return customModel.supportsVision;
    // }

    final model = _availableModels.firstWhere(
      (m) => m.name == _selectedModel,
      orElse: () => AiModel(
        name: '',
        description: '',
        inputModalities: [],
        outputModalities: [],
        aliases: [],
      ),
    );
    return model.vision == true || model.inputModalities.contains('image');
  }

  ChatProvider({String? apiKey, String? systemPrompt}) {
    _systemPrompt = systemPrompt;
    _initializeApiService(apiKey);
    _loadChats();
    _loadModels();
    _initializeMcp();
  }

  Future<void> _initializeMcp() async {
    try {
      await _mcpClientService.initialize();
    } catch (e) {
      print('Failed to initialize MCP: $e');
    }
  }

  /// Reload MCP configuration and reconnect to servers
  Future<void> reloadMcpServers() async {
    try {
      await _mcpClientService.reload();
      notifyListeners();
    } catch (e) {
      print('Failed to reload MCP servers: $e');
    }
  }

  void _initializeApiService(String? apiKey) {
    _apiService = ApiService(apiKey: apiKey);
    _apiService.setUserId(_currentUserId);
  }

  void updateApiKey(String? apiKey) {
    _apiService = ApiService(apiKey: apiKey);
    _apiService.setUserId(_currentUserId);
    notifyListeners();
  }

  void updateSystemPrompt(String? systemPrompt) {
    _systemPrompt = systemPrompt;
    notifyListeners();
  }

  void setMemoryContextGetter(String Function()? getter) {
    _memoryContextGetter = getter;
  }

  void setOnMemoryExtracted(Future<void> Function(String)? callback) {
    _onMemoryExtracted = callback;
  }

  // Set user ID for API authentication
  void setUserId(String? userId) {
    // Only reload if userId actually changed
    if (_currentUserId == userId) {
      return; // No change, skip
    }
    
    _currentUserId = userId;
    _chatApiService.setUserId(userId);
    _apiService.setUserId(userId);
    
    if (userId == null) {
      // User logged out - clear everything
      _chats = [];
      _currentChat = null;
      _messages = [];
      notifyListeners();
    } else {
      // User logged in - load chats
      _loadChats();
    }
  }

  // ==================== CHAT OPERATIONS ====================

  /// Load chat list (titles only) - FAST!
  Future<void> _loadChats() async {
    // Prevent concurrent loads
    if (_isLoadingChats) {
      return;
    }
    
    try {
      _isLoadingChats = true;
      _isLoading = true;
      notifyListeners();
      
      print('📥 Loading chat list from cloud...');
      _chats = await _chatApiService.fetchChatList();
      print('✅ Loaded ${_chats.length} chats');
      
      _error = null;
    } catch (e) {
      print('❌ Error loading chats: $e');
      _error = e.toString();
      _chats = [];
    } finally {
      _isLoading = false;
      _isLoadingChats = false;
      notifyListeners();
    }
  }

  /// Refresh chat list
  Future<void> refreshChats() async {
    _chatApiService.clearCache();
    await _loadChats();
  }

  /// Select a chat and load its messages
  Future<void> selectChat(Chat chat) async {
    if (_currentChat?.id == chat.id) {
      // Already selected, just refresh
      return reloadCurrentChat();
    }

    _currentChat = chat;
    _messages = [];
    _messageOffset = 0;
    _hasMoreMessages = true;
    notifyListeners();

    // Load first page of messages
    await _loadMessages();
  }

  /// Load messages for current chat (paginated)
  Future<void> _loadMessages() async {
    if (_currentChat == null || _currentChat?.id == null || _isLoadingMore) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      print('📥 Loading messages for chat ${_currentChat!.id} (offset: $_messageOffset)');
      final newMessages = await _chatApiService.fetchMessages(
        _currentChat!.id!,
        limit: _messagePageSize,
        offset: _messageOffset,
      );

      if (newMessages.length < _messagePageSize) {
        _hasMoreMessages = false;
      }

      _messages.addAll(newMessages);
      _messageOffset += newMessages.length;
      
      print('✅ Loaded ${newMessages.length} messages (total: ${_messages.length})');
    } catch (e) {
      print('❌ Error loading messages: $e');
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (!_hasMoreMessages || _isLoadingMore) return;
    await _loadMessages();
  }

  /// Reload current chat messages
  Future<void> reloadCurrentChat() async {
    if (_currentChat == null) return;

    _messages = [];
    _messageOffset = 0;
    _hasMoreMessages = true;
    notifyListeners();

    await _loadMessages();
  }

  /// Create a new chat
  Future<void> createChat(String title) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📝 Creating new chat: "$title"');
      final chat = await _chatApiService.createChat(title);
      
      if (chat != null && chat.id != null) {
        await refreshChats(); // Reload chat list
        await selectChat(chat); // Select the new chat
        print('✅ Chat created: ${chat.id}');
      } else {
        print('❌ Chat created but has no ID');
        _error = 'Failed to create chat: no ID returned';
      }
    } catch (e) {
      print('❌ Error creating chat: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new chat (with optional default model)
  Future<void> createNewChat({String? defaultModel}) async {
    final now = DateTime.now();
    
    // Use default model if provided, otherwise keep current selection
    if (defaultModel != null && defaultModel.isNotEmpty) {
      _selectedModel = defaultModel;
    }

    // Create a temporary chat that's not yet saved to cloud
    // It will be saved when the user sends the first message
    _currentChat = Chat(
      id: null, // null indicates this chat hasn't been saved yet
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
    );
    _messages = [];
    _error = null;
    _isLoading = false;
    _isStreaming = false;
    _streamingContent = '';
    notifyListeners();
  }

  /// Rename a chat
  Future<void> renameChat(int chatId, String newTitle) async {
    try {
      await _chatApiService.updateChatTitle(chatId, newTitle);
      await refreshChats();
      
      if (_currentChat?.id == chatId) {
        _currentChat = _chats.firstWhere((c) => c.id == chatId);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error renaming chat: $e');
      _error = e.toString();
    }
  }

  /// Delete a chat
  Future<void> deleteChat(int chatId) async {
    try {
      await _chatApiService.deleteChat(chatId);
      
      // Remove from local list
      _chats.removeWhere((c) => c.id == chatId);
      
      // Clear current chat if it was deleted
      if (_currentChat?.id == chatId) {
        _currentChat = null;
        _messages = [];
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting chat: $e');
      _error = e.toString();
    }
  }

  /// Delete all chats
  Future<void> deleteAllChats() async {
    try {
      await _chatApiService.deleteAllChats();
      _chats = [];
      _currentChat = null;
      _messages = [];
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting all chats: $e');
      _error = e.toString();
    }
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Send a message (creates chat if needed)
  Future<void> sendMessage(
    String content, {
    String? imageBase64,
    String? imagePath,
    bool webSearch = false,
    bool reasoning = false,
    bool imageGeneration = false,
    String? imageGenerationModel,
  }) async {
    final useWebSearch = webSearch;
    if (content.trim().isEmpty && imageBase64 == null) return;

    // Create chat if doesn't exist
    if (_currentChat == null || _currentChat?.id == null) {
      final title = content.length > 50 ? '${content.substring(0, 50)}...' : content;
      await createChat(title);
      if (_currentChat == null || _currentChat?.id == null) {
        print('❌ Failed to create chat or chat has no ID');
        return; // Failed to create chat or chat has no ID
      }
    }

    // Step 1: Save user message to cloud FIRST
    Message? savedUserMessage;
    try {
      final userMessage = Message(
        role: 'user',
        content: content,
        timestamp: DateTime.now(),
        chatId: _currentChat!.id!,
        imageBase64: imageBase64,
        imagePath: imagePath,
        webSearchUsed: useWebSearch,
      );

      // Save to cloud first
      print('📤 Step 1: Saving user message to cloud...');
      savedUserMessage = await _chatApiService.sendMessage(userMessage);
      
      if (savedUserMessage == null) {
        throw Exception('Failed to save user message to cloud');
      }
      
      print('✅ Step 1: User message saved (ID: ${savedUserMessage.id})');
    } catch (e) {
      print('❌ Error saving user message: $e');
      _error = 'Failed to save message: $e';
      notifyListeners();
      return; // Don't proceed if user message can't be saved
    }

    // Step 2: Add user message to UI (now with ID from cloud)
    _messages.add(savedUserMessage);
    notifyListeners();

    // Step 3: Get AI response (streaming)
    try {
      print('🤖 Step 2: Getting AI response...');
      await _getAiResponse(content, imageBase64, useWebSearch);
      print('✅ Step 2: AI response received');
    } catch (e) {
      print('❌ Error getting AI response: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _getAiResponse(
    String userMessage,
    String? imageBase64,
    bool useWebSearch,
  ) async {
    _isStreaming = true;
    _streamingContent = '';
    _error = null;
    notifyListeners();

    // Ensure we have a valid chat with ID
    if (_currentChat == null || _currentChat?.id == null) {
      print('❌ Cannot get AI response: chat is null or has no ID');
      return;
    }

    // Add thinking placeholder with visible content
    final thinkingMessage = Message(
      role: 'assistant',
      content: '...', // Show placeholder text so message bubble appears
      timestamp: DateTime.now(),
      chatId: _currentChat!.id!,
      isThinking: true,
    );
    _messages.add(thinkingMessage);
    notifyListeners();
    print('🤔 Added thinking message, isStreaming: $_isStreaming');

    try {
      final startTime = DateTime.now();
      final conversationHistory = _messages
          .where((m) => m.id != null) // Only include saved messages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      // Get memory context if available
      String? memoryContext;
      if (_memoryContextGetter != null) {
        memoryContext = _memoryContextGetter!();
      }

      // Get MCP tools if available
      List<McpTool>? mcpTools;
      try {
        mcpTools = await _mcpClientService.getAllTools();
      } catch (e) {
        print('Error getting MCP tools: $e');
      }

      // Format conversation history for API
      final formattedHistory = conversationHistory
          .where((m) => m['content'] != null && (m['content'] as String).isNotEmpty)
          .map((m) => Message(
                role: m['role'] as String,
                content: m['content'] as String,
                timestamp: DateTime.now(),
                chatId: _currentChat!.id!,
              ))
          .toList();

      // Build final user message with context
      String finalMessage = userMessage;
      if (memoryContext != null && memoryContext.isNotEmpty) {
        finalMessage = '$memoryContext\n\n$userMessage';
      }

      print('📡 Starting stream request...');
      int chunkCount = 0;
      await for (final chunk in _apiService.sendMessageStream(
        message: finalMessage,
        history: formattedHistory,
        model: _selectedModel,
        systemPrompt: _systemPrompt,
        mcpTools: mcpTools,
      )) {
        chunkCount++;
        _streamingContent += chunk;
        
        // Update thinking message with streaming content
        final index = _messages.indexOf(thinkingMessage);
        if (index != -1) {
          _messages[index] = Message(
            role: 'assistant',
            content: _streamingContent.isEmpty ? '...' : _streamingContent,
            timestamp: thinkingMessage.timestamp,
            chatId: _currentChat!.id!,
            isThinking: false,
          );
        }
        
        notifyListeners();
        
        // Log first few chunks for debugging
        if (chunkCount <= 3) {
          print('📦 Received chunk $chunkCount: ${chunk.substring(0, chunk.length > 50 ? 50 : chunk.length)}...');
        }
      }
      
      print('✅ Stream completed. Total chunks: $chunkCount, Content length: ${_streamingContent.length}');
      
      if (_streamingContent.isEmpty) {
        print('⚠️  Warning: Stream completed but content is empty!');
        throw Exception('AI response was empty');
      }

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Step 3: Save assistant message to cloud AFTER AI responds
      final assistantMessage = Message(
        role: 'assistant',
        content: _streamingContent,
        timestamp: DateTime.now(),
        chatId: _currentChat!.id!,
        responseTimeMs: responseTime,
        webSearchUsed: useWebSearch,
      );

      // Update the thinking message with final content (before saving)
      final index = _messages.indexOf(thinkingMessage);
      if (index != -1) {
        _messages[index] = assistantMessage;
        notifyListeners();
      }

      // Save assistant message to cloud
      print('💾 Step 3: Saving assistant message to cloud...');
      try {
        // Verify userId is still set before saving
        if (_chatApiService.currentUserId == null) {
          print('⚠️  Warning: UserId is null when saving assistant message. Current userId: $_currentUserId');
          // Try to re-set userId from ChatProvider
          if (_currentUserId != null) {
            _chatApiService.setUserId(_currentUserId);
            print('✅ Re-set userId in ChatApiService: $_currentUserId');
          } else {
            throw Exception('Cannot save assistant message: User ID is null');
          }
        }
        
        final savedMessage = await _chatApiService.sendMessage(assistantMessage);
        if (savedMessage != null) {
          if (index != -1) {
            _messages[index] = savedMessage;
            notifyListeners();
          }
          print('✅ Step 3: Assistant message saved (ID: ${savedMessage.id})');
        } else {
          print('⚠️  Warning: Assistant message save returned null');
        }
      } catch (e) {
        print('⚠️  Warning: Failed to save assistant message to cloud: $e');
        print('   Chat ID: ${_currentChat?.id}');
        print('   User ID: $_currentUserId');
        print('   ChatApiService User ID: ${_chatApiService.currentUserId}');
        // Don't throw - the message is already displayed to the user
        // Just log the error and continue
      }

      // Extract and save memories if callback is provided
      if (_onMemoryExtracted != null && _streamingContent.isNotEmpty) {
        try {
          await _onMemoryExtracted!(_streamingContent);
        } catch (e) {
          print('Error extracting memory: $e');
        }
      }

      _streamingContent = '';
    } catch (e, stackTrace) {
      print('❌ Error getting AI response: $e');
      print('Stack trace: $stackTrace');
      _error = e.toString();
      
      // Remove thinking message and show error
      final index = _messages.indexOf(thinkingMessage);
      if (index != -1) {
        _messages.removeAt(index);
      }
      
      // Show error message to user
      final errorMessage = Message(
        role: 'assistant',
        content: 'Sorry, I encountered an error: ${e.toString()}',
        timestamp: DateTime.now(),
        chatId: _currentChat!.id!,
        isThinking: false,
      );
      _messages.add(errorMessage);
    } finally {
      _isStreaming = false;
      notifyListeners();
      print('🏁 Finished AI response (isStreaming: false)');
    }
  }

  /// Add reaction to a message
  Future<void> addReactionToMessage(Message message, String reaction) async {
    try {
      final updatedMessage = Message(
        id: message.id,
        role: message.role,
        content: message.content,
        timestamp: message.timestamp,
        chatId: message.chatId,
        reaction: reaction,
        webSearchUsed: message.webSearchUsed,
        imageBase64: message.imageBase64,
        imagePath: message.imagePath,
        thinkingContent: message.thinkingContent,
        isThinking: message.isThinking,
        responseTimeMs: message.responseTimeMs,
        generatedImageBase64: message.generatedImageBase64,
        generatedImagePrompt: message.generatedImagePrompt,
        generatedImageModel: message.generatedImageModel,
        isGeneratingImage: message.isGeneratingImage,
      );

      await _chatApiService.updateMessage(updatedMessage);

      // Update local message
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error adding reaction: $e');
      _error = e.toString();
    }
  }

  /// Set message reaction (by message ID)
  Future<void> setMessageReaction(int messageId, String? reaction) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) {
      print('Message with ID $messageId not found');
      return;
    }
    
    final message = _messages[messageIndex];
    if (reaction == null) {
      // Remove reaction
      await addReactionToMessage(message, '');
    } else {
      await addReactionToMessage(message, reaction);
    }
  }

  // ==================== MODEL OPERATIONS ====================

  Future<void> _loadModels() async {
    try {
      _availableModels = await _apiService.fetchModels();
      // TODO: Re-enable custom providers/models in future
      // Note: Custom providers are now managed through settings provider
      // _customProviders = [];
      // _customModels = [];
    } catch (e) {
      print('Error loading models: $e');
    }
  }

  // TODO: Re-enable custom providers/models in future
  void updateCustomProviders(List<CustomProvider> providers, List<CustomModel> models) {
    // _customProviders = providers;
    // _customModels = models;
    // notifyListeners();
    // For now, ignore custom providers/models - will be handled by chat-server in future
  }

  /// Get all models as a list of maps
  List<Map<String, String>> getAllModels() {
    final models = <Map<String, String>>[];

    for (var xibeModel in _availableModels) {
      models.add({
        'id': xibeModel.name,
        'name': xibeModel.description.isNotEmpty
            ? xibeModel.description
            : xibeModel.name,
        'provider': 'Xibe',
      });
    }

    // TODO: Re-enable custom models in future
    // for (var customModel in _customModels) {
    //   final provider = _customProviders.firstWhere(
    //     (p) => p.id == customModel.providerId,
    //     orElse: () => CustomProvider(
    //       id: '',
    //       name: 'Unknown',
    //       baseUrl: '',
    //       apiKey: '',
    //       type: 'openai',
    //     ),
    //   );
    //   models.add({
    //     'id': customModel.modelId,
    //     'name': customModel.name,
    //     'provider': provider.name,
    //   });
    // }

    return models;
  }

  void selectModel(String modelName) {
    _selectedModel = modelName;
    notifyListeners();
  }

  /// Set selected model (alias for selectModel)
  void setSelectedModel(String model) {
    selectModel(model);
  }

  // Image generation
  Future<void> generateImage(String prompt, {String model = 'flux-schnell'}) async {
    // TODO: Implement image generation if needed
    print('Image generation not yet implemented in new provider');
  }

  // ==================== GREETING METHODS ====================

  String getGreeting() {
    final hour = DateTime.now().hour;
    
    // Get a variety of greetings based on time of day
    final List<String> morningGreetings = [
      'Good morning! ☀️',
      'Ready to start your day? 🌅',
      'Morning! What can I help you with? ☕',
      'Good morning! How can I assist you today? 🌞',
      'Rise and shine! Ready when you are. 🌄',
    ];
    
    final List<String> afternoonGreetings = [
      'Good afternoon! 🌤️',
      'Afternoon! How can I help? ☀️',
      'Ready when you are. 🌥️',
      'Good afternoon! What would you like to explore? 🌤️',
      'Afternoon! Let\'s get started. ☀️',
    ];
    
    final List<String> eveningGreetings = [
      'Good evening! 🌙',
      'Evening! How can I assist? 🌆',
      'Ready when you are. 🌃',
      'Good evening! What can I help you with? 🌙',
      'Evening! Let\'s dive in. 🌉',
    ];
    
    // Use chat ID to select different greeting (consistent per chat)
    // If no chat exists yet, use a hash of current time to vary it
    final chatId = _currentChat?.id ?? DateTime.now().day;
    final seed = chatId.hashCode.abs();
    
    List<String> greetings;
    if (hour < 12) {
      greetings = morningGreetings;
    } else if (hour < 17) {
      greetings = afternoonGreetings;
    } else {
      greetings = eveningGreetings;
    }
    
    // Select greeting based on seed to ensure variety
    return greetings[seed % greetings.length];
  }
  
  String getGreetingSubtitle() {
    final List<String> subtitles = [
      'Start a conversation to begin',
      'What would you like to know?',
      'How can I help you today?',
      'Ask me anything!',
      'Let\'s explore together',
      'What\'s on your mind?',
      'I\'m here to help',
      'Ready to chat?',
    ];
    
    // Use chat ID to select different subtitle (consistent per chat)
    final chatId = _currentChat?.id ?? DateTime.now().day;
    final seed = chatId.hashCode.abs();
    return subtitles[seed % subtitles.length];
  }

  @override
  void dispose() {
    // MCP client service doesn't have dispose method
    super.dispose();
  }
}

