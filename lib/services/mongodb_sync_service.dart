import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/memory.dart';

import '../config/sync_config.dart';

class MongoDBSyncService {
  final Connectivity _connectivity = Connectivity();
  
  String get baseUrl => MONGODB_API_URL;

  // Check if device is online
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Get headers with auth
  Map<String, String> _getHeaders(String userId) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer token', // TODO: Use actual Firebase token
      'X-User-Id': userId,
    };
  }

  // Sync chat to MongoDB
  Future<void> syncChatToCloud(String userId, Chat chat) async {
    if (!await isOnline) {
      print('⚠️  Chat sync skipped: Device is offline');
      return;
    }

    try {
      final url = Uri.parse('${baseUrl}/chats');
      final response = await http.post(
        url,
        headers: _getHeaders(userId),
        body: jsonEncode({
          'id': chat.id,
          'title': chat.title,
          'createdAt': chat.createdAt.toIso8601String(),
          'updatedAt': chat.updatedAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Chat synced to MongoDB: ${chat.id} - "${chat.title}"');
      } else {
        print('❌ Error syncing chat: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error syncing chat to MongoDB: $e');
    }
  }

  // Sync message to MongoDB
  Future<void> syncMessageToCloud(
      String userId, String chatId, Message message) async {
    if (!await isOnline) return;

    try {
      final url = Uri.parse('${baseUrl}/messages');
      final response = await http.post(
        url,
        headers: _getHeaders(userId),
        body: jsonEncode({
          'id': message.id,
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
        print('✅ Message synced to MongoDB: ${message.id}');
      } else {
        print('❌ Error syncing message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error syncing message to MongoDB: $e');
    }
  }

  // Sync memory to MongoDB
  Future<void> syncMemoryToCloud(String userId, Memory memory) async {
    if (!await isOnline) return;

    try {
      final url = Uri.parse('${baseUrl}/memories');
      final response = await http.post(
        url,
        headers: _getHeaders(userId),
        body: jsonEncode({
          'id': memory.id,
          'content': memory.content,
          'createdAt': memory.createdAt.toIso8601String(),
          'updatedAt': memory.updatedAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Memory synced to MongoDB: ${memory.id}');
      }
    } catch (e) {
      print('❌ Error syncing memory to MongoDB: $e');
    }
  }

  // Fetch all chats from MongoDB
  Future<List<Chat>> fetchChatsFromCloud(String userId) async {
    if (!await isOnline) return [];

    try {
      final url = Uri.parse('${baseUrl}/chats');
      final response = await http.get(
        url,
        headers: _getHeaders(userId),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['chats'] != null) {
          return (data['chats'] as List)
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
        }
      }
      return [];
    } catch (e) {
      print('❌ Error fetching chats from MongoDB: $e');
      return [];
    }
  }

  // Fetch messages for a chat from MongoDB
  Future<List<Message>> fetchMessagesFromCloud(
      String userId, String chatId, {int limit = 200}) async {
    if (!await isOnline) return [];

    try {
      final url = Uri.parse('${baseUrl}/messages/chat/$chatId?limit=$limit');
      final response = await http.get(
        url,
        headers: _getHeaders(userId),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['messages'] != null) {
          return (data['messages'] as List)
              .map((json) => Message(
                    id: json['id'] as int?,
                    role: json['role'] as String? ?? 'user',
                    content: json['content'] as String? ?? '',
                    timestamp: json['timestamp'] != null
                        ? DateTime.parse(json['timestamp'] as String)
                        : DateTime.now(),
                    webSearchUsed: json['webSearchUsed'] == true,
                    chatId: int.parse(chatId),
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
        }
      }
      return [];
    } catch (e) {
      print('❌ Error fetching messages from MongoDB: $e');
      return [];
    }
  }

  // Fetch all memories from MongoDB
  Future<List<Memory>> fetchMemoriesFromCloud(String userId) async {
    if (!await isOnline) return [];

    try {
      final url = Uri.parse('${baseUrl}/memories');
      final response = await http.get(
        url,
        headers: _getHeaders(userId),
      );

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
      print('❌ Error fetching memories from MongoDB: $e');
      return [];
    }
  }

  // Delete chat from MongoDB
  Future<void> deleteChatFromCloud(String userId, int chatId) async {
    if (!await isOnline) return;

    try {
      final url = Uri.parse('${baseUrl}/chats/$chatId');
      await http.delete(
        url,
        headers: _getHeaders(userId),
      );
    } catch (e) {
      print('❌ Error deleting chat from MongoDB: $e');
    }
  }

  // Delete all chats from MongoDB
  Future<void> deleteAllChatsFromCloud(String userId) async {
    if (!await isOnline) return;

    try {
      final url = Uri.parse('${baseUrl}/chats');
      await http.delete(
        url,
        headers: _getHeaders(userId),
      );
    } catch (e) {
      print('❌ Error deleting all chats from MongoDB: $e');
    }
  }

  // Delete message from MongoDB
  Future<void> deleteMessageFromCloud(
      String userId, String chatId, int messageId) async {
    if (!await isOnline) return;

    try {
      final url = Uri.parse('${baseUrl}/messages/$messageId');
      await http.delete(
        url,
        headers: _getHeaders(userId),
      );
    } catch (e) {
      print('❌ Error deleting message from MongoDB: $e');
    }
  }

  // Delete memory from MongoDB
  Future<void> deleteMemoryFromCloud(String userId, int memoryId) async {
    if (!await isOnline) return;

    try {
      final url = Uri.parse('${baseUrl}/memories/$memoryId');
      await http.delete(
        url,
        headers: _getHeaders(userId),
      );
    } catch (e) {
      print('❌ Error deleting memory from MongoDB: $e');
    }
  }

  // Batch sync all local data to MongoDB
  Future<void> syncAllToCloud({
    required String userId,
    required List<Chat> chats,
    required Map<int, List<Message>> messagesByChat,
    required List<Memory> memories,
  }) async {
    if (!await isOnline) return;

    try {
      // Sync chats
      for (final chat in chats) {
        await syncChatToCloud(userId, chat);
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Sync messages
      for (final entry in messagesByChat.entries) {
        for (final message in entry.value) {
          await syncMessageToCloud(userId, entry.key.toString(), message);
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      // Sync memories
      for (final memory in memories) {
        await syncMemoryToCloud(userId, memory);
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      print('❌ Error batch syncing to MongoDB: $e');
    }
  }
}

