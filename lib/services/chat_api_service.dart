import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/memory.dart';
import '../config/sync_config.dart';

/// Cloud-only chat service - NO LOCAL STORAGE
/// All data is fetched from MongoDB API on-demand
class ChatApiService {
  final Connectivity _connectivity = Connectivity();
  String? _currentUserId;
  
  // In-memory cache for performance (cleared on logout)
  final Map<int, Chat> _chatCache = {};
  final Map<int, List<Message>> _messageCache = {};
  List<Chat>? _chatListCache;
  DateTime? _chatListCacheTime;
  
  // Cache duration
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  String get baseUrl => MONGODB_API_URL;
  
  void setUserId(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      clearCache();
    }
  }

  String? get currentUserId => _currentUserId;
  
  void clearCache() {
    _chatCache.clear();
    _messageCache.clear();
    _chatListCache = null;
    _chatListCacheTime = null;
  }

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Map<String, String> _getHeaders() {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer token', // TODO: Use actual Firebase token
      'X-User-Id': _currentUserId!,
    };
  }

  // ==================== CHATS ====================
  
  /// Fetch only chat metadata (titles, IDs, timestamps) - FAST!
  Future<List<Chat>> fetchChatList() async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }
    
    // Return cached list if fresh
    if (_chatListCache != null && _chatListCacheTime != null) {
      if (DateTime.now().difference(_chatListCacheTime!) < _cacheDuration) {
        print('📦 Returning cached chat list (${_chatListCache!.length} chats)');
        return _chatListCache!;
      }
    }

    try {
      final url = Uri.parse('${baseUrl}/chats');
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['chats'] != null) {
          final chats = (data['chats'] as List)
              .map((json) => Chat(
                    id: json['id'] as int?,
                    title: json['title'] as String? ?? '',
                    createdAt: json['createdAt'] != null
                        ? DateTime.parse(json['createdAt'] as String)
                        : DateTime.now(),
                    updatedAt: json['updatedAt'] != null
                        ? DateTime.parse(json['updatedAt'] as String)
                        : DateTime.now(),
                  ))
              .toList();
          
          // Cache the list
          _chatListCache = chats;
          _chatListCacheTime = DateTime.now();
          
          // Also cache individual chats
          for (var chat in chats) {
            if (chat.id != null) {
              _chatCache[chat.id!] = chat;
            }
          }
          
          print('✅ Fetched ${chats.length} chats from cloud');
          return chats;
        }
      }
      
      print('❌ Error fetching chats: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error fetching chats: $e');
      rethrow;
    }
  }

  /// Create a new chat
  Future<Chat?> createChat(String title) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final now = DateTime.now();
      final url = Uri.parse('${baseUrl}/chats');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'title': title,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['chat'] != null) {
          final chat = Chat(
            id: data['chat']['id'] as int?,
            title: data['chat']['title'] as String,
            createdAt: DateTime.parse(data['chat']['createdAt'] as String),
            updatedAt: DateTime.parse(data['chat']['updatedAt'] as String),
          );
          
          // Invalidate chat list cache
          _chatListCache = null;
          _chatListCacheTime = null;
          
          // Cache the new chat
          if (chat.id != null) {
            _chatCache[chat.id!] = chat;
          }
          
          print('✅ Created chat: ${chat.id} - "${chat.title}"');
          return chat;
        }
      }
      
      print('❌ Error creating chat: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('❌ Error creating chat: $e');
      rethrow;
    }
  }

  /// Update chat title
  Future<void> updateChatTitle(int chatId, String newTitle) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final url = Uri.parse('${baseUrl}/chats/$chatId');
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'title': newTitle,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // Invalidate caches
        _chatCache.remove(chatId);
        _chatListCache = null;
        _chatListCacheTime = null;
        
        print('✅ Updated chat title: $chatId');
      }
    } catch (e) {
      print('❌ Error updating chat: $e');
      rethrow;
    }
  }

  /// Delete a chat
  Future<void> deleteChat(int chatId) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final url = Uri.parse('${baseUrl}/chats/$chatId');
      await http.delete(url, headers: _getHeaders());
      
      // Clear from caches
      _chatCache.remove(chatId);
      _messageCache.remove(chatId);
      _chatListCache = null;
      _chatListCacheTime = null;
      
      print('✅ Deleted chat: $chatId');
    } catch (e) {
      print('❌ Error deleting chat: $e');
      rethrow;
    }
  }

  /// Delete all chats
  Future<void> deleteAllChats() async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final url = Uri.parse('${baseUrl}/chats');
      await http.delete(url, headers: _getHeaders());
      clearCache();
      print('✅ Deleted all chats');
    } catch (e) {
      print('❌ Error deleting all chats: $e');
      rethrow;
    }
  }

  // ==================== MESSAGES ====================
  
  /// Fetch messages for a chat (on-demand, when chat is selected)
  Future<List<Message>> fetchMessages(int chatId, {int limit = 50, int offset = 0}) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }
    
    // Return cached messages if this is the first page and cache is fresh
    if (offset == 0 && _messageCache.containsKey(chatId)) {
      print('📦 Returning cached messages for chat $chatId');
      return _messageCache[chatId]!;
    }

    try {
      final url = Uri.parse('${baseUrl}/messages/chat/$chatId?limit=$limit&offset=$offset');
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['messages'] != null) {
          final messages = (data['messages'] as List)
              .map((json) => Message(
                    id: json['id'] as int?,
                    role: json['role'] as String? ?? 'user',
                    content: json['content'] as String? ?? '',
                    timestamp: json['timestamp'] != null
                        ? DateTime.parse(json['timestamp'] as String)
                        : DateTime.now(),
                    webSearchUsed: json['webSearchUsed'] == true,
                    chatId: chatId,
                    imageBase64: json['imageBase64'] as String?,
                    imagePath: json['imagePath'] as String?,
                    thinkingContent: json['thinkingContent'] as String?,
                    isThinking: json['isThinking'] == true,
                    responseTimeMs: json['responseTimeMs'] as int?,
                    reaction: json['reaction'] as String?,
                    generatedImageBase64: json['generatedImageBase64'] as String?,
                    generatedImagePrompt: json['generatedImagePrompt'] as String?,
                    generatedImageModel: json['generatedImageModel'] as String?,
                    isGeneratingImage: json['isGeneratingImage'] == true,
                  ))
              .toList();
          
          // Cache first page only
          if (offset == 0) {
            _messageCache[chatId] = messages;
          }
          
          print('✅ Fetched ${messages.length} messages for chat $chatId');
          return messages;
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Error fetching messages: $e');
      rethrow;
    }
  }

  /// Send a message
  Future<Message?> sendMessage(Message message) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    // Ensure userId is set
    if (_currentUserId == null) {
      throw Exception('Cannot send message: User not authenticated. User ID is null.');
    }

    try {
      final url = Uri.parse('${baseUrl}/messages');
      final headers = _getHeaders();
      print('📤 Sending message (role: ${message.role}, chatId: ${message.chatId}, userId: $_currentUserId)');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'chatId': message.chatId,
          'role': message.role,
          'content': message.content,
          'timestamp': message.timestamp.toIso8601String(),
          'webSearchUsed': message.webSearchUsed,
          'imageBase64': message.imageBase64,
          'imagePath': message.imagePath,
          'thinkingContent': message.thinkingContent,
          'isThinking': message.isThinking,
          'responseTimeMs': message.responseTimeMs,
          'reaction': message.reaction,
          'generatedImageBase64': message.generatedImageBase64,
          'generatedImagePrompt': message.generatedImagePrompt,
          'generatedImageModel': message.generatedImageModel,
          'isGeneratingImage': message.isGeneratingImage,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['message'] != null) {
          final savedMessage = Message(
            id: data['message']['id'] as int?,
            role: message.role,
            content: message.content,
            timestamp: message.timestamp,
            webSearchUsed: message.webSearchUsed,
            chatId: message.chatId,
            imageBase64: message.imageBase64,
            imagePath: message.imagePath,
            thinkingContent: message.thinkingContent,
            isThinking: message.isThinking,
            responseTimeMs: message.responseTimeMs,
            reaction: message.reaction,
            generatedImageBase64: message.generatedImageBase64,
            generatedImagePrompt: message.generatedImagePrompt,
            generatedImageModel: message.generatedImageModel,
            isGeneratingImage: message.isGeneratingImage,
          );
          
          // Invalidate message cache for this chat
          _messageCache.remove(message.chatId);
          
          print('✅ Sent message: ${savedMessage.id}');
          return savedMessage;
        }
      }
      
      // Handle error responses
      if (response.statusCode == 401) {
        print('❌ Authentication failed: 401 Unauthorized');
        print('   User ID: $_currentUserId');
        print('   Response: ${response.body}');
        throw Exception('Failed to send message: Authentication failed (401). User ID: $_currentUserId');
      }
      
      print('❌ Error sending message: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to send message: Server returned status code: ${response.statusCode}');
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Update message (for reactions, etc.)
  Future<void> updateMessage(Message message) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final url = Uri.parse('${baseUrl}/messages/${message.id}');
      await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'content': message.content,
          'reaction': message.reaction,
          'thinkingContent': message.thinkingContent,
          'isThinking': message.isThinking,
          'generatedImageBase64': message.generatedImageBase64,
          'generatedImagePrompt': message.generatedImagePrompt,
          'generatedImageModel': message.generatedImageModel,
          'isGeneratingImage': message.isGeneratingImage,
        }),
      );
      
      // Invalidate message cache
      _messageCache.remove(message.chatId);
      
      print('✅ Updated message: ${message.id}');
    } catch (e) {
      print('❌ Error updating message: $e');
      rethrow;
    }
  }

  // ==================== MEMORIES ====================
  
  Future<List<Memory>> fetchMemories() async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final url = Uri.parse('${baseUrl}/memories');
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['memories'] != null) {
          return (data['memories'] as List)
              .map((json) => Memory(
                    id: json['id'] as int?,
                    content: json['content'] as String? ?? '',
                    createdAt: json['createdAt'] != null
                        ? DateTime.parse(json['createdAt'] as String)
                        : DateTime.now(),
                    updatedAt: json['updatedAt'] != null
                        ? DateTime.parse(json['updatedAt'] as String)
                        : DateTime.now(),
                  ))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ Error fetching memories: $e');
      rethrow;
    }
  }

  Future<Memory?> createMemory(String content) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final now = DateTime.now();
      final url = Uri.parse('${baseUrl}/memories');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'content': content,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['memory'] != null) {
          return Memory(
            id: data['memory']['id'] as int?,
            content: content,
            createdAt: now,
            updatedAt: now,
          );
        }
      }
      return null;
    } catch (e) {
      print('❌ Error creating memory: $e');
      rethrow;
    }
  }

  Future<void> updateMemory(Memory memory) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final url = Uri.parse('${baseUrl}/memories/${memory.id}');
      await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'content': memory.content,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print('❌ Error updating memory: $e');
      rethrow;
    }
  }

  Future<void> deleteMemory(int memoryId) async {
    if (!await isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final url = Uri.parse('${baseUrl}/memories/$memoryId');
      await http.delete(url, headers: _getHeaders());
    } catch (e) {
      print('❌ Error deleting memory: $e');
      rethrow;
    }
  }
}

