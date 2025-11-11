import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/memory.dart';
import 'cloud_sync_service.dart';

class DatabaseService {
  static const int _databaseVersion = 7;
  static Database? _database;
  static bool _initialized = false;
  final CloudSyncService _cloudSyncService = CloudSyncService();
  String? _currentUserId;

  static void _initializeDatabaseFactory() {
    if (_initialized) return;

    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } catch (e) {
        throw Exception('Failed to initialize desktop database: $e. '
            'Ensure sqflite_common_ffi is properly installed and platform libraries are available.');
      }
    }
    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _initializeDatabaseFactory();

    String path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop platforms, use application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String dbDir = join(appDocDir.path, 'XibeChat');
      await Directory(dbDir).create(recursive: true);
      path = join(dbDir, 'xibe_chat.db');
    } else {
      // For mobile platforms, use default databases path
      path = join(await getDatabasesPath(), 'xibe_chat.db');
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chats(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            webSearchUsed INTEGER NOT NULL,
            chatId INTEGER NOT NULL,
            imageBase64 TEXT,
            imagePath TEXT,
            thinkingContent TEXT,
            isThinking INTEGER NOT NULL DEFAULT 0,
            responseTimeMs INTEGER,
            reaction TEXT,
            generatedImageBase64 TEXT,
            generatedImagePrompt TEXT,
            generatedImageModel TEXT,
            isGeneratingImage INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (chatId) REFERENCES chats (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE memories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add image columns for version 2
          await db.execute('ALTER TABLE messages ADD COLUMN imageBase64 TEXT');
          await db.execute('ALTER TABLE messages ADD COLUMN imagePath TEXT');
        }
        if (oldVersion < 3) {
          // Add thinking columns for version 3
          // SQLite doesn't support NOT NULL with DEFAULT in ALTER TABLE, so we make it nullable
          await db
              .execute('ALTER TABLE messages ADD COLUMN thinkingContent TEXT');
          await db.execute(
              'ALTER TABLE messages ADD COLUMN isThinking INTEGER DEFAULT 0');
          // Update existing rows to have isThinking = 0
          await db.update('messages', {'isThinking': 0},
              where: 'isThinking IS NULL');
        }
        if (oldVersion < 4) {
          // Add memories table for version 4
          await db.execute('''
            CREATE TABLE memories(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              content TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 5) {
          // Add UI enhancements: response time and reactions for version 5
          await db.execute(
              'ALTER TABLE messages ADD COLUMN responseTimeMs INTEGER');
          await db.execute('ALTER TABLE messages ADD COLUMN reaction TEXT');
        }
        if (oldVersion < 6) {
          // Add image generation fields for version 6
          await db.execute(
              'ALTER TABLE messages ADD COLUMN generatedImageBase64 TEXT');
          await db.execute(
              'ALTER TABLE messages ADD COLUMN generatedImagePrompt TEXT');
          await db.execute(
              'ALTER TABLE messages ADD COLUMN generatedImageModel TEXT');
        }
        if (oldVersion < 7) {
          // Add isGeneratingImage field for version 7
          await db.execute(
              'ALTER TABLE messages ADD COLUMN isGeneratingImage INTEGER DEFAULT 0');
        }
      },
    );
  }

  // Set current user ID for cloud sync
  void setUserId(String? userId) {
    _currentUserId = userId;
  }

  Future<int> createChat(Chat chat) async {
    final db = await database;
    final id = await db.insert('chats', chat.toMap());
    
    // Sync to cloud if user is logged in
    if (_currentUserId != null) {
      final chatWithId = Chat(
        id: id,
        title: chat.title,
        createdAt: chat.createdAt,
        updatedAt: chat.updatedAt,
      );
      _cloudSyncService.syncChatToCloud(_currentUserId!, chatWithId);
    }
    
    return id;
  }

  Future<List<Chat>> getAllChats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chats',
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Chat.fromMap(maps[i]));
  }

  Future<void> updateChat(Chat chat) async {
    final db = await database;
    await db.update(
      'chats',
      chat.toMap(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
    
    // Sync to cloud if user is logged in
    if (_currentUserId != null) {
      _cloudSyncService.syncChatToCloud(_currentUserId!, chat);
    }
  }

  Future<void> deleteChat(int chatId) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
        await txn.delete('chats', where: 'id = ?', whereArgs: [chatId]);
      });
      
      // Delete from cloud if user is logged in
      if (_currentUserId != null) {
        _cloudSyncService.deleteChatFromCloud(_currentUserId!, chatId);
      }
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  Future<int> insertMessage(Message message) async {
    final db = await database;
    final id = await db.insert('messages', message.toMap());
    
    // Sync to cloud if user is logged in
    if (_currentUserId != null) {
      final messageWithId = Message(
        id: id,
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
      _cloudSyncService.syncMessageToCloud(
        _currentUserId!,
        message.chatId.toString(),
        messageWithId,
      );
    }
    
    return id;
  }

  Future<List<Message>> getMessagesForChat(int chatId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }

  Future<void> deleteAllChats() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('chats');
  }

  // Memory operations
  Future<int> insertMemory(Memory memory) async {
    final db = await database;
    final id = await db.insert('memories', memory.toMap());
    
    // Sync to cloud if user is logged in
    if (_currentUserId != null) {
      final memoryWithId = Memory(
        id: id,
        content: memory.content,
        createdAt: memory.createdAt,
        updatedAt: memory.updatedAt,
      );
      _cloudSyncService.syncMemoryToCloud(_currentUserId!, memoryWithId);
    }
    
    return id;
  }

  Future<List<Memory>> getAllMemories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memories',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Memory.fromMap(maps[i]));
  }

  Future<void> updateMemory(Memory memory) async {
    final db = await database;
    await db.update(
      'memories',
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
    
    // Sync to cloud if user is logged in
    if (_currentUserId != null) {
      _cloudSyncService.syncMemoryToCloud(_currentUserId!, memory);
    }
  }

  Future<void> deleteMemory(int memoryId) async {
    final db = await database;
    await db.delete('memories', where: 'id = ?', whereArgs: [memoryId]);
    
    // Delete from cloud if user is logged in
    if (_currentUserId != null) {
      _cloudSyncService.deleteMemoryFromCloud(_currentUserId!, memoryId);
    }
  }

  Future<void> deleteAllMemories() async {
    final db = await database;
    await db.delete('memories');
  }

  // Message reaction operations
  Future<void> updateMessageReaction(int messageId, String? reaction) async {
    final db = await database;
    await db.update(
      'messages',
      {'reaction': reaction},
      where: 'id = ?',
      whereArgs: [messageId],
    );
    
    // Sync to cloud if user is logged in
    if (_currentUserId != null) {
      // Get the message to sync
      final messages = await db.query(
        'messages',
        where: 'id = ?',
        whereArgs: [messageId],
        limit: 1,
      );
      if (messages.isNotEmpty) {
        final message = Message.fromMap(messages.first);
        final updatedMessage = Message(
          id: message.id,
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
          reaction: reaction,
          generatedImageBase64: message.generatedImageBase64,
          generatedImagePrompt: message.generatedImagePrompt,
          generatedImageModel: message.generatedImageModel,
          isGeneratingImage: message.isGeneratingImage,
        );
        _cloudSyncService.syncMessageToCloud(
          _currentUserId!,
          message.chatId.toString(),
          updatedMessage,
        );
      }
    }
  }

  // Sync all local data to cloud
  Future<void> syncAllToCloud() async {
    if (_currentUserId == null) return;
    
    try {
      final chats = await getAllChats();
      final messagesByChat = <int, List<Message>>{};
      
      for (final chat in chats) {
        if (chat.id != null) {
          messagesByChat[chat.id!] = await getMessagesForChat(chat.id!);
        }
      }
      
      final memories = await getAllMemories();
      
      await _cloudSyncService.syncAllToCloud(
        userId: _currentUserId!,
        chats: chats,
        messagesByChat: messagesByChat,
        memories: memories,
      );
    } catch (e) {
      print('Error syncing all data to cloud: $e');
    }
  }

  // Load data from cloud and merge with local
  Future<void> loadFromCloud() async {
    if (_currentUserId == null) return;
    
    try {
      final cloudChats = await _cloudSyncService.fetchChatsFromCloud(_currentUserId!);
      final localChats = await getAllChats();
      
      // Merge cloud chats with local (cloud takes precedence for conflicts)
      final localChatIds = localChats.map((c) => c.id).toSet();
      
      for (final cloudChat in cloudChats) {
        if (cloudChat.id != null && !localChatIds.contains(cloudChat.id)) {
          // Chat exists in cloud but not locally - add it
          await createChat(cloudChat);
        } else if (cloudChat.id != null && localChatIds.contains(cloudChat.id)) {
          // Chat exists in both - update local with cloud version
          await updateChat(cloudChat);
        }
      }
      
      // Load messages for each chat
      for (final chat in cloudChats) {
        if (chat.id != null) {
          final cloudMessages = await _cloudSyncService.fetchMessagesFromCloud(
            _currentUserId!,
            chat.id.toString(),
          );
          final localMessages = await getMessagesForChat(chat.id!);
          
          // Merge messages (cloud takes precedence)
          final localMessageIds = localMessages.map((m) => m.id).toSet();
          
          for (final cloudMessage in cloudMessages) {
            if (cloudMessage.id != null && !localMessageIds.contains(cloudMessage.id)) {
              // Message exists in cloud but not locally - add it
              await insertMessage(cloudMessage);
            }
          }
        }
      }
      
      // Load memories
      final cloudMemories = await _cloudSyncService.fetchMemoriesFromCloud(_currentUserId!);
      final localMemories = await getAllMemories();
      
      final localMemoryIds = localMemories.map((m) => m.id).toSet();
      
      for (final cloudMemory in cloudMemories) {
        if (cloudMemory.id != null && !localMemoryIds.contains(cloudMemory.id)) {
          // Memory exists in cloud but not locally - add it
          await insertMemory(cloudMemory);
        }
      }
    } catch (e) {
      print('Error loading data from cloud: $e');
    }
  }
}
