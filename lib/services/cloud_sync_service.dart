import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/memory.dart';
import '../models/user.dart' as app_user;
import '../models/user_settings.dart';

class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  // Check if device is online
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Get user's chats collection reference
  CollectionReference _getChatsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('chats');
  }

  // Get user's messages collection reference for a chat
  CollectionReference _getMessagesRef(String userId, String chatId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages');
  }

  // Get user's memories collection reference
  CollectionReference _getMemoriesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('memories');
  }

  // Get user's settings document reference
  DocumentReference _getSettingsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('settings').doc('user_settings');
  }

  // Get user's profile document reference
  DocumentReference _getUserProfileRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // Sync chat to cloud
  Future<void> syncChatToCloud(String userId, Chat chat) async {
    if (!await isOnline) return;

    try {
      final chatRef = _getChatsRef(userId).doc(chat.id.toString());
      await chatRef.set({
        'id': chat.id,
        'title': chat.title,
        'createdAt': chat.createdAt.toIso8601String(),
        'updatedAt': chat.updatedAt.toIso8601String(),
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing chat to cloud: $e');
      // Don't throw - allow app to continue working offline
    }
  }

  // Sync message to cloud
  Future<void> syncMessageToCloud(
      String userId, String chatId, Message message) async {
    if (!await isOnline) return;

    try {
      final messageRef =
          _getMessagesRef(userId, chatId).doc(message.id.toString());
      await messageRef.set({
        'id': message.id,
        'role': message.role,
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
        'webSearchUsed': message.webSearchUsed,
        'chatId': message.chatId,
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
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing message to cloud: $e');
      // Don't throw - allow app to continue working offline
    }
  }

  // Sync memory to cloud
  Future<void> syncMemoryToCloud(String userId, Memory memory) async {
    if (!await isOnline) return;

    try {
      final memoryRef = _getMemoriesRef(userId).doc(memory.id.toString());
      await memoryRef.set({
        'id': memory.id,
        'content': memory.content,
        'createdAt': memory.createdAt.toIso8601String(),
        'updatedAt': memory.updatedAt.toIso8601String(),
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing memory to cloud: $e');
      // Don't throw - allow app to continue working offline
    }
  }

  // Delete chat from cloud (including all messages in that chat)
  Future<void> deleteChatFromCloud(String userId, int chatId) async {
    if (!await isOnline) return;

    try {
      final chatIdStr = chatId.toString();
      
      // Get all messages in this chat
      final messagesSnapshot = await _getMessagesRef(userId, chatIdStr).get();
      
      // Use batch to delete all messages and the chat
      final batch = _firestore.batch();
      
      // Delete all messages in this chat
      for (final messageDoc in messagesSnapshot.docs) {
        batch.delete(messageDoc.reference);
      }
      
      // Delete the chat document
      final chatRef = _getChatsRef(userId).doc(chatIdStr);
      batch.delete(chatRef);
      
      // Commit all deletions
      await batch.commit();
    } catch (e) {
      print('Error deleting chat from cloud: $e');
    }
  }

  // Delete all chats and their messages from cloud
  Future<void> deleteAllChatsFromCloud(String userId) async {
    if (!await isOnline) return;

    try {
      // Get all chats first
      final chatsSnapshot = await _getChatsRef(userId).get();
      
      // Use batch to delete all chats and their messages
      final batch = _firestore.batch();
      
      for (final chatDoc in chatsSnapshot.docs) {
        final chatId = chatDoc.id;
        
        // Delete all messages in this chat
        final messagesSnapshot = await _getMessagesRef(userId, chatId).get();
        for (final messageDoc in messagesSnapshot.docs) {
          batch.delete(messageDoc.reference);
        }
        
        // Delete the chat document
        batch.delete(chatDoc.reference);
      }
      
      // Commit all deletions
      await batch.commit();
    } catch (e) {
      print('Error deleting all chats from cloud: $e');
    }
  }

  // Delete message from cloud
  Future<void> deleteMessageFromCloud(
      String userId, String chatId, int messageId) async {
    if (!await isOnline) return;

    try {
      final messageRef =
          _getMessagesRef(userId, chatId).doc(messageId.toString());
      await messageRef.delete();
    } catch (e) {
      print('Error deleting message from cloud: $e');
    }
  }

  // Delete memory from cloud
  Future<void> deleteMemoryFromCloud(String userId, int memoryId) async {
    if (!await isOnline) return;

    try {
      final memoryRef = _getMemoriesRef(userId).doc(memoryId.toString());
      await memoryRef.delete();
    } catch (e) {
      print('Error deleting memory from cloud: $e');
    }
  }

  // Fetch all chats from cloud
  Future<List<Chat>> fetchChatsFromCloud(String userId) async {
    if (!await isOnline) return [];

    try {
      final snapshot = await _getChatsRef(userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Chat(
          id: data['id'] as int?,
          title: data['title'] as String? ?? '',
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error fetching chats from cloud: $e');
      return [];
    }
  }

  // Fetch messages for a chat from cloud
  Future<List<Message>> fetchMessagesFromCloud(
      String userId, String chatId) async {
    if (!await isOnline) return [];

    try {
      final snapshot = await _getMessagesRef(userId, chatId)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Message(
          id: data['id'] as int?,
          role: data['role'] as String? ?? 'user',
          content: data['content'] as String? ?? '',
          timestamp: data['timestamp'] != null
              ? DateTime.parse(data['timestamp'] as String)
              : DateTime.now(),
          webSearchUsed: data['webSearchUsed'] == true,
          chatId: int.parse(chatId),
          imageBase64: data['imageBase64'] as String?,
          imagePath: data['imagePath'] as String?,
          thinkingContent: data['thinkingContent'] as String?,
          isThinking: data['isThinking'] == true,
          responseTimeMs: data['responseTimeMs'] as int?,
          reaction: data['reaction'] as String?,
          generatedImageBase64: data['generatedImageBase64'] as String?,
          generatedImagePrompt: data['generatedImagePrompt'] as String?,
          generatedImageModel: data['generatedImageModel'] as String?,
          isGeneratingImage: data['isGeneratingImage'] == true,
        );
      }).toList();
    } catch (e) {
      print('Error fetching messages from cloud: $e');
      return [];
    }
  }

  // Fetch all memories from cloud
  Future<List<Memory>> fetchMemoriesFromCloud(String userId) async {
    if (!await isOnline) return [];

    try {
      final snapshot = await _getMemoriesRef(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Memory(
          id: data['id'] as int?,
          content: data['content'] as String? ?? '',
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error fetching memories from cloud: $e');
      return [];
    }
  }

  // Batch sync all local data to cloud (for initial sync or after offline period)
  Future<void> syncAllToCloud({
    required String userId,
    required List<Chat> chats,
    required Map<int, List<Message>> messagesByChat,
    required List<Memory> memories,
  }) async {
    if (!await isOnline) return;

    try {
      final batch = _firestore.batch();

      // Sync chats
      for (final chat in chats) {
        final chatRef = _getChatsRef(userId).doc(chat.id.toString());
        batch.set(chatRef, {
          'id': chat.id,
          'title': chat.title,
          'createdAt': chat.createdAt.toIso8601String(),
          'updatedAt': chat.updatedAt.toIso8601String(),
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Sync messages
      for (final entry in messagesByChat.entries) {
        final chatId = entry.key.toString();
        for (final message in entry.value) {
          final messageRef =
              _getMessagesRef(userId, chatId).doc(message.id.toString());
          batch.set(messageRef, {
            'id': message.id,
            'role': message.role,
            'content': message.content,
            'timestamp': message.timestamp.toIso8601String(),
            'webSearchUsed': message.webSearchUsed,
            'chatId': message.chatId,
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
            'syncedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }

      // Sync memories
      for (final memory in memories) {
        final memoryRef = _getMemoriesRef(userId).doc(memory.id.toString());
        batch.set(memoryRef, {
          'id': memory.id,
          'content': memory.content,
          'createdAt': memory.createdAt.toIso8601String(),
          'updatedAt': memory.updatedAt.toIso8601String(),
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Error batch syncing to cloud: $e');
      // Don't throw - allow app to continue working
    }
  }

  // Save/Update user profile in cloud
  Future<void> saveUserProfile(String userId, app_user.User user) async {
    if (!await isOnline) return;

    try {
      await _getUserProfileRef(userId).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'createdAt': user.createdAt.toIso8601String(),
        'lastLoginAt': user.lastLoginAt.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user profile to cloud: $e');
    }
  }

  // Fetch user profile from cloud
  Future<app_user.User?> fetchUserProfile(String userId) async {
    if (!await isOnline) return null;

    try {
      final doc = await _getUserProfileRef(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return app_user.User(
          uid: data['uid'] ?? userId,
          email: data['email'] ?? '',
          displayName: data['displayName'],
          photoUrl: data['photoUrl'],
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
          lastLoginAt: data['lastLoginAt'] != null
              ? DateTime.parse(data['lastLoginAt'] as String)
              : DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Error fetching user profile from cloud: $e');
      return null;
    }
  }

  // Save/Update user settings in cloud
  Future<void> saveUserSettings(String userId, UserSettings settings) async {
    if (!await isOnline) return;

    try {
      await _getSettingsRef(userId).set({
        ...settings.toMap(),
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user settings to cloud: $e');
    }
  }

  // Fetch user settings from cloud
  Future<UserSettings?> fetchUserSettings(String userId) async {
    if (!await isOnline) return null;

    try {
      final doc = await _getSettingsRef(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserSettings.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user settings from cloud: $e');
      return null;
    }
  }
}

