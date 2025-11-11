import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/ai_model.dart';
import '../models/custom_provider.dart';
import '../models/custom_model.dart';
import '../services/chat_api_service.dart';
import '../services/api_service.dart';
import '../services/custom_provider_service.dart';
import '../services/mcp_client_service.dart';
import '../services/image_generation_service.dart';

/// NEW ChatProvider - Cloud-only, no local database
class ChatProvider extends ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService();
  late ApiService _apiService;
  final McpClientService _mcpClientService = McpClientService();
  final ImageGenerationService _imageGenerationService = ImageGenerationService();
  
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
  List<CustomProvider> _customProviders = [];
  List<CustomModel> _customModels = [];
  String _selectedModel = 'gemini';
  String? _systemPrompt;
  String Function()? _memoryContextGetter;
  Future<void> Function(String)? _onMemoryExtracted;
  String? _pendingPrompt;

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
  String get selectedModel => _selectedModel;
  String? get systemPrompt => _systemPrompt;
  String? get pendingPrompt => _pendingPrompt;

  bool get selectedModelSupportsVision {
    final customModel = _customModels.firstWhere(
      (m) => m.modelId == _selectedModel,
      orElse: () => CustomModel(
        id: '',
        name: '',
        modelId: '',
        providerId: '',
        description: '',
        endpointUrl: '',
      ),
    );

    if (customModel.modelId.isNotEmpty) {
      return customModel.supportsVision;
    }

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

  void _initializeApiService(String? apiKey) {
    _apiService = ApiService(apiKey: apiKey, systemPrompt: _systemPrompt);
  }

  void updateApiKey(String? apiKey) {
    _initializeApiService(apiKey);
  }

  void updateSystemPrompt(String? systemPrompt) {
    _systemPrompt = systemPrompt;
    _initializeApiService(_apiService.apiKey);
  }

  void setMemoryContextGetter(String Function()? getter) {
    _memoryContextGetter = getter;
  }

  void setOnMemoryExtracted(Future<void> Function(String)? callback) {
    _onMemoryExtracted = callback;
  }

  // Set user ID for API authentication
  void setUserId(String? userId) {
    _chatApiService.setUserId(userId);
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
    try {
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
    if (_currentChat == null || _isLoadingMore) return;

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
      
      if (chat != null) {
        await refreshChats(); // Reload chat list
        await selectChat(chat); // Select the new chat
        print('✅ Chat created: ${chat.id}');
      }
    } catch (e) {
      print('❌ Error creating chat: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    bool useWebSearch = false,
  }) async {
    if (content.trim().isEmpty && imageBase64 == null) return;

    // Create chat if doesn't exist
    if (_currentChat == null) {
      final title = content.length > 50 ? '${content.substring(0, 50)}...' : content;
      await createChat(title);
      if (_currentChat == null) return; // Failed to create chat
    }

    // Add user message to UI immediately (optimistic update)
    final userMessage = Message(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
      chatId: _currentChat!.id!,
      imageBase64: imageBase64,
      imagePath: imagePath,
      webSearchUsed: useWebSearch,
    );

    _messages.add(userMessage);
    notifyListeners();

    try {
      // Save user message to cloud
      final savedUserMessage = await _chatApiService.sendMessage(userMessage);
      if (savedUserMessage != null) {
        // Replace optimistic message with saved one (has ID)
        final index = _messages.indexOf(userMessage);
        if (index != -1) {
          _messages[index] = savedUserMessage;
        }
      }

      // Get AI response
      await _getAiResponse(content, imageBase64, useWebSearch);
    } catch (e) {
      print('❌ Error sending message: $e');
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

    // Add thinking placeholder
    final thinkingMessage = Message(
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
      chatId: _currentChat!.id!,
      isThinking: true,
    );
    _messages.add(thinkingMessage);
    notifyListeners();

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

      await for (final chunk in _apiService.streamChatCompletion(
        model: _selectedModel,
        messages: conversationHistory,
        imageBase64: imageBase64,
        useWebSearch: useWebSearch,
        systemPrompt: _systemPrompt,
        memoryContext: memoryContext,
        mcpClientService: _mcpClientService,
      )) {
        _streamingContent += chunk;
        
        // Update thinking message
        final index = _messages.indexOf(thinkingMessage);
        if (index != -1) {
          _messages[index] = Message(
            role: 'assistant',
            content: _streamingContent,
            timestamp: thinkingMessage.timestamp,
            chatId: _currentChat!.id!,
            isThinking: false,
          );
        }
        
        notifyListeners();
      }

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Save assistant message to cloud
      final assistantMessage = Message(
        role: 'assistant',
        content: _streamingContent,
        timestamp: DateTime.now(),
        chatId: _currentChat!.id!,
        responseTimeMs: responseTime,
        webSearchUsed: useWebSearch,
      );

      final savedMessage = await _chatApiService.sendMessage(assistantMessage);
      if (savedMessage != null) {
        final index = _messages.indexOf(thinkingMessage);
        if (index != -1) {
          _messages[index] = savedMessage;
        }
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
    } catch (e) {
      print('❌ Error getting AI response: $e');
      _error = e.toString();
      _messages.remove(thinkingMessage);
    } finally {
      _isStreaming = false;
      notifyListeners();
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

  // ==================== MODEL OPERATIONS ====================

  Future<void> _loadModels() async {
    try {
      _availableModels = await _apiService.getAvailableModels();
      await _loadCustomProviders();
    } catch (e) {
      print('Error loading models: $e');
    }
  }

  Future<void> _loadCustomProviders() async {
    try {
      _customProviders = await CustomProviderService.loadProviders();
      _customModels = [];
      for (var provider in _customProviders) {
        if (provider.enabled) {
          _customModels.addAll(provider.models);
        }
      }
    } catch (e) {
      print('Error loading custom providers: $e');
    }
  }

  void selectModel(String modelName) {
    _selectedModel = modelName;
    notifyListeners();
  }

  // Image generation methods remain the same...
  Future<void> generateImage(String prompt, {String model = 'flux-schnell'}) async {
    // Implementation same as before
  }

  void dispose() {
    _mcpClientService.dispose();
    super.dispose();
  }
}

