import 'dart:io';
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/memory.dart';
import 'cloud_sync_service.dart';
import 'mongodb_sync_service.dart';
import '../config/sync_config.dart';

class DatabaseService {
  static const int _databaseVersion = 7;
  static Database? _database;
  static bool _initialized = false;
  final CloudSyncService _cloudSyncService = CloudSyncService();
  final MongoDBSyncService _mongodbSyncService = MongoDBSyncService();
  String? _currentUserId;
  
  // Get the active sync service based on config
  dynamic get _activeSyncService {
    return USE_MONGODB ? _mongodbSyncService : _cloudSyncService;
  }
  
  // Queue to serialize database operations and prevent locks
  final _operationQueue = <Future<dynamic> Function()>[];
  bool _processingQueue = false;

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
  
  // Execute database operations through a queue to prevent concurrent access issues
  Future<T> _executeInQueue<T>(Future<T> Function() operation) async {
    final completer = Completer<T>();
    
    _operationQueue.add(() async {
      try {
        final result = await operation();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    _processQueue();
    return completer.future;
  }
  
  Future<void> _processQueue() async {
    if (_processingQueue || _operationQueue.isEmpty) return;
    
    _processingQueue = true;
    
    while (_operationQueue.isNotEmpty) {
      final operation = _operationQueue.removeAt(0);
      try {
        await operation();
        // Increased delay between operations to prevent database locks
        // This gives SQLite more time to release locks and commit transactions
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print('❌ Error in database operation queue: $e');
        // Longer delay on error to prevent cascading failures
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    
    _processingQueue = false;
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

  Future<int> createChat(Chat chat, {bool skipCloudSync = false}) async {
    return _executeInQueue(() async {
      final db = await database;
      
      // If chat has an ID, use INSERT OR REPLACE to handle duplicates
      int id;
      if (chat.id != null) {
        // Use INSERT OR REPLACE to handle existing chats (e.g., from cloud sync)
        await db.insert('chats', chat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        id = chat.id!;
      } else {
        // Auto-generate ID for new chats
        id = await db.insert('chats', chat.toMap());
      }
      
      // Sync to cloud if user is logged in (unless explicitly skipped)
      if (!skipCloudSync && _currentUserId != null) {
        final chatWithId = Chat(
          id: id,
          title: chat.title,
          createdAt: chat.createdAt,
          updatedAt: chat.updatedAt,
        );
        print('📤 Syncing chat to cloud: ${chatWithId.id} - "${chatWithId.title}"');
        // Don't await cloud sync to prevent blocking database operations
        _activeSyncService.syncChatToCloud(_currentUserId!, chatWithId).catchError((e) {
          print('❌ Error syncing chat to cloud: $e');
        });
      } else if (skipCloudSync) {
        print('⏭️  Chat sync skipped (skipCloudSync=true)');
      } else if (_currentUserId == null) {
        print('⏭️  Chat sync skipped (user not logged in)');
      }
      
      return id;
    });
  }

  Future<List<Chat>> getAllChats() async {
    return _executeInQueue(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'chats',
        orderBy: 'updatedAt DESC',
      );
      return List.generate(maps.length, (i) => Chat.fromMap(maps[i]));
    });
  }

  Future<void> updateChat(Chat chat) async {
    return _executeInQueue(() async {
      final db = await database;
      await db.update(
        'chats',
        chat.toMap(),
        where: 'id = ?',
        whereArgs: [chat.id],
      );
      
      // Sync to cloud if user is logged in
      if (_currentUserId != null) {
        print('📤 Updating chat in cloud: ${chat.id} - "${chat.title}"');
        // Don't await cloud sync to prevent blocking database operations
        _activeSyncService.syncChatToCloud(_currentUserId!, chat).catchError((e) {
          print('❌ Error syncing chat update to cloud: $e');
        });
      } else {
        print('⏭️  Chat update sync skipped (user not logged in)');
      }
    });
  }

  Future<void> deleteChat(int chatId) async {
    return _executeInQueue(() async {
      final db = await database;
      try {
        await db.transaction((txn) async {
          await txn.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
          await txn.delete('chats', where: 'id = ?', whereArgs: [chatId]);
        });
        
        // Delete from cloud if user is logged in
        if (_currentUserId != null) {
          // Don't await cloud sync to prevent blocking database operations
          _activeSyncService.deleteChatFromCloud(_currentUserId!, chatId).catchError((e) {
            print('Error deleting chat from cloud: $e');
          });
        }
      } catch (e) {
        throw Exception('Failed to delete chat: $e');
      }
    });
  }

  Future<int> insertMessage(Message message, {bool skipCloudSync = false}) async {
    return _executeInQueue(() async {
      final db = await database;
      
      // If message has an ID, use INSERT OR REPLACE to handle duplicates
      int id;
      if (message.id != null) {
        // Use INSERT OR REPLACE to handle existing messages (e.g., from cloud sync)
        await db.insert('messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        id = message.id!;
      } else {
        // Auto-generate ID for new messages
        id = await db.insert('messages', message.toMap());
      }
      
      // Sync to cloud if user is logged in (unless explicitly skipped)
      if (!skipCloudSync && _currentUserId != null) {
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
        // Don't await cloud sync to prevent blocking database operations
        _activeSyncService.syncMessageToCloud(
          _currentUserId!,
          message.chatId.toString(),
          messageWithId,
        ).catchError((e) {
          print('Error syncing message to cloud: $e');
        });
      }
      
      return id;
    });
  }

  Future<List<Message>> getMessagesForChat(int chatId, {int? limit, int? offset}) async {
    return _executeInQueue(() async {
      final db = await database;
      
      // Reduced default limit to 200 messages to prevent memory issues
      // This significantly reduces RAM usage for large chats
      final queryLimit = limit ?? 200;
      final queryOffset = offset ?? 0;
      
      try {
        final List<Map<String, dynamic>> maps = await db.query(
          'messages',
          where: 'chatId = ?',
          whereArgs: [chatId],
          orderBy: 'timestamp DESC', // Get most recent first
          limit: queryLimit,
          offset: queryOffset,
        );
        
        // Reverse to get chronological order (oldest first)
        final messages = List.generate(maps.length, (i) => Message.fromMap(maps[i]));
        return messages.reversed.toList();
      } catch (e) {
        // If query fails (e.g., memory issue), try with much smaller limit
        if (queryLimit > 50) {
          print('⚠️ Query failed with limit $queryLimit, retrying with smaller limit: $e');
          return getMessagesForChat(chatId, limit: 50, offset: offset);
        }
        rethrow;
      }
    });
  }
  
  // Get total message count for a chat (for pagination)
  Future<int> getMessageCountForChat(int chatId) async {
    return _executeInQueue(() async {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM messages WHERE chatId = ?',
        [chatId],
      );
      return result.first['count'] as int? ?? 0;
    });
  }

  Future<void> deleteAllChats() async {
    return _executeInQueue(() async {
      final db = await database;
      
      // Delete from local database using transaction to prevent locks
      await db.transaction((txn) async {
        await txn.delete('messages');
        await txn.delete('chats');
      });
      
      // Delete all chats and their messages from cloud if user is logged in
      if (_currentUserId != null) {
        // Don't await cloud sync to prevent blocking database operations
        _activeSyncService.deleteAllChatsFromCloud(_currentUserId!).catchError((e) {
          print('Error deleting all chats from cloud: $e');
        });
      }
    });
  }

  // Memory operations
  Future<int> insertMemory(Memory memory, {bool skipCloudSync = false}) async {
    return _executeInQueue(() async {
      final db = await database;
      
      // If memory has an ID, use INSERT OR REPLACE to handle duplicates
      int id;
      if (memory.id != null) {
        // Use INSERT OR REPLACE to handle existing memories (e.g., from cloud sync)
        await db.insert('memories', memory.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        id = memory.id!;
      } else {
        // Auto-generate ID for new memories
        id = await db.insert('memories', memory.toMap());
      }
      
      // Sync to cloud if user is logged in (unless explicitly skipped)
      if (!skipCloudSync && _currentUserId != null) {
        final memoryWithId = Memory(
          id: id,
          content: memory.content,
          createdAt: memory.createdAt,
          updatedAt: memory.updatedAt,
        );
        // Don't await cloud sync to prevent blocking database operations
        _activeSyncService.syncMemoryToCloud(_currentUserId!, memoryWithId).catchError((e) {
          print('Error syncing memory to cloud: $e');
        });
      }
      
      return id;
    });
  }

  Future<List<Memory>> getAllMemories() async {
    return _executeInQueue(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'memories',
        orderBy: 'createdAt DESC',
      );
      return List.generate(maps.length, (i) => Memory.fromMap(maps[i]));
    });
  }

  Future<void> updateMemory(Memory memory) async {
    return _executeInQueue(() async {
      final db = await database;
      await db.update(
        'memories',
        memory.toMap(),
        where: 'id = ?',
        whereArgs: [memory.id],
      );
      
      // Sync to cloud if user is logged in
      if (_currentUserId != null) {
        // Don't await cloud sync to prevent blocking database operations
        _activeSyncService.syncMemoryToCloud(_currentUserId!, memory).catchError((e) {
          print('Error syncing memory to cloud: $e');
        });
      }
    });
  }

  Future<void> deleteMemory(int memoryId) async {
    return _executeInQueue(() async {
      final db = await database;
      await db.delete('memories', where: 'id = ?', whereArgs: [memoryId]);
      
      // Delete from cloud if user is logged in
      if (_currentUserId != null) {
        // Don't await cloud sync to prevent blocking database operations
        _activeSyncService.deleteMemoryFromCloud(_currentUserId!, memoryId).catchError((e) {
          print('Error deleting memory from cloud: $e');
        });
      }
    });
  }

  Future<void> deleteAllMemories() async {
    return _executeInQueue(() async {
      final db = await database;
      await db.delete('memories');
    });
  }

  // Message reaction operations
  Future<void> updateMessageReaction(int messageId, String? reaction) async {
    return _executeInQueue(() async {
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
          // Don't await cloud sync to prevent blocking database operations
          _activeSyncService.syncMessageToCloud(
            _currentUserId!,
            message.chatId.toString(),
            updatedMessage,
          ).catchError((e) {
            print('Error syncing message reaction to cloud: $e');
          });
        }
      }
    });
  }

  // Sync all local data to cloud
  // Uses efficient queries to prevent database locks
  Future<void> syncAllToCloud() async {
    if (_currentUserId == null) return;
    
    try {
      final chats = await getAllChats();
      final messagesByChat = <int, List<Message>>{};
      
      // Load messages in batches to prevent database locks
      for (final chat in chats) {
        if (chat.id != null) {
          try {
            // Reduced limit to 200 messages per chat to prevent memory exhaustion
            // This is a reasonable limit for cloud sync while avoiding OOM errors
            messagesByChat[chat.id!] = await getMessagesForChat(chat.id!, limit: 200);
            // Increased delay between queries to prevent overwhelming the database
            await Future.delayed(const Duration(milliseconds: 50));
          } catch (e) {
            print('❌ Error loading messages for chat ${chat.id} during sync: $e');
            // Continue with empty list if loading fails
            messagesByChat[chat.id!] = [];
          }
        }
      }
      
      final memories = await getAllMemories();
      
      await _activeSyncService.syncAllToCloud(
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
  // Uses a single large transaction to prevent database locks
  // Fetches data from Firestore first (outside queue), then queues database operations
  Future<void> loadFromCloud() async {
    if (_currentUserId == null) {
      print('⏭️  loadFromCloud skipped: No user ID set');
      return;
    }
    
    // Fetch all data from Firestore FIRST (outside the queue to avoid blocking)
    try {
      print('📥 Fetching chats from cloud for user: $_currentUserId');
      final cloudChats = await _activeSyncService.fetchChatsFromCloud(_currentUserId!);
      print('📥 Found ${cloudChats.length} chats in cloud');
      
      // Prepare chats to insert/update (cloud takes precedence for conflicts)
      final chatsToInsert = <Chat>[];
      
      for (final cloudChat in cloudChats) {
        if (cloudChat.id != null) {
          chatsToInsert.add(cloudChat);
        }
      }
      
      // Fetch all messages for all chats first (outside transaction)
      final messagesByChat = <int, List<Message>>{};
      int totalMessagesToLoad = 0;
      
      for (final chat in cloudChats) {
        if (chat.id != null) {
          try {
            // Limit to 200 messages per chat to prevent memory exhaustion
            final cloudMessages = await _activeSyncService.fetchMessagesFromCloud(
              _currentUserId!,
              chat.id.toString(),
              limit: 200,
            );
            if (cloudMessages.isNotEmpty) {
              messagesByChat[chat.id!] = cloudMessages;
              totalMessagesToLoad += cloudMessages.length as int;
              print('📥 Found ${cloudMessages.length} messages for chat ${chat.id}');
            }
          } catch (e) {
            print('❌ Error fetching messages for chat ${chat.id}: $e');
            // Continue with next chat even if this one fails
          }
        }
      }
      
      // Fetch memories
      final cloudMemories = await _activeSyncService.fetchMemoriesFromCloud(_currentUserId!);
      
      // Now queue the database operations (this will be executed in the queue)
      return _executeInQueue(() async {
        final db = await database;
        
        try {
          // Do all database operations in a single transaction to prevent locks
          print('💾 Saving all data to local database in single transaction...');
          await db.transaction((txn) async {
            // Insert/update all chats
            if (chatsToInsert.isNotEmpty) {
              for (final chat in chatsToInsert) {
                await txn.insert('chats', chat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
              }
              print('✅ Saved ${chatsToInsert.length} chats');
            }
            
            // Insert/update all messages
            if (messagesByChat.isNotEmpty) {
              for (final entry in messagesByChat.entries) {
                for (final message in entry.value) {
                  if (message.id != null) {
                    await txn.insert('messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
                  }
                }
              }
              print('✅ Saved $totalMessagesToLoad messages');
            }
            
            // Insert/update all memories
            if (cloudMemories.isNotEmpty) {
              for (final memory in cloudMemories) {
                if (memory.id != null) {
                  await txn.insert('memories', memory.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
                }
              }
              print('✅ Saved ${cloudMemories.length} memories');
            }
          });
          
          print('✅ Completed loading all data from cloud');
        } catch (e) {
          print('❌ Error saving data to local database: $e');
          rethrow;
        }
      });
    } catch (e) {
      print('❌ Error fetching data from cloud: $e');
      rethrow;
    }
  }
}
