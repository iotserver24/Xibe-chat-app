const express = require('express');
const router = express.Router();
const Chat = require('../models/Chat');
const Message = require('../models/Message');
const Memory = require('../models/Memory');
const verifyFirebaseToken = require('../middleware/auth');

// Sync endpoint - get changes since timestamp
router.get('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const since = req.query.since ? new Date(req.query.since) : null;

    const query = {
      userId: userId,
      deletedAt: null,
    };

    if (since) {
      query.updatedAt = { $gt: since };
    }

    // Get updated chats
    const chats = await Chat.find(query)
      .sort({ updatedAt: -1 })
      .lean();

    // Get updated messages (if since is provided, get messages from those chats)
    let messages = [];
    if (since) {
      const chatIds = chats.map(c => c.id);
      messages = await Message.find({
        userId: userId,
        chatId: { $in: chatIds },
        timestamp: { $gt: since },
      })
        .sort({ timestamp: 1 })
        .lean();
    }

    // Get updated memories
    const memoryQuery = { userId: userId };
    if (since) {
      memoryQuery.updatedAt = { $gt: since };
    }
    const memories = await Memory.find(memoryQuery)
      .sort({ updatedAt: -1 })
      .lean();

    res.json({
      success: true,
      chats: chats.map(c => ({
        id: c.id,
        title: c.title,
        createdAt: c.createdAt.toISOString(),
        updatedAt: c.updatedAt.toISOString(),
      })),
      messages: messages.map(m => ({
        id: m.id,
        chatId: m.chatId,
        role: m.role,
        content: m.content,
        timestamp: m.timestamp.toISOString(),
        webSearchUsed: m.webSearchUsed,
        imageBase64: m.imageBase64,
        imagePath: m.imagePath,
        thinkingContent: m.thinkingContent,
        isThinking: m.isThinking,
        responseTimeMs: m.responseTimeMs,
        reaction: m.reaction,
        generatedImageBase64: m.generatedImageBase64,
        generatedImagePrompt: m.generatedImagePrompt,
        generatedImageModel: m.generatedImageModel,
        isGeneratingImage: m.isGeneratingImage,
      })),
      memories: memories.map(m => ({
        id: m.id,
        content: m.content,
        createdAt: m.createdAt.toISOString(),
        updatedAt: m.updatedAt.toISOString(),
      })),
      syncedAt: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error syncing:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to sync',
      message: error.message,
    });
  }
});

// Push local changes to server
router.post('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const { chats, messages, memories } = req.body;

    const results = {
      chats: { created: 0, updated: 0, errors: [] },
      messages: { created: 0, updated: 0, errors: [] },
      memories: { created: 0, updated: 0, errors: [] },
    };

    // Sync chats
    if (chats && Array.isArray(chats)) {
      for (const chatData of chats) {
        try {
          const existingChat = await Chat.findOne({
            id: chatData.id,
            userId: userId,
          });

          if (existingChat) {
            // Update existing
            existingChat.title = chatData.title;
            existingChat.updatedAt = new Date(chatData.updatedAt);
            await existingChat.save();
            results.chats.updated++;
          } else {
            // Create new
            const chat = new Chat({
              id: chatData.id,
              userId: userId,
              title: chatData.title,
              createdAt: new Date(chatData.createdAt),
              updatedAt: new Date(chatData.updatedAt),
            });
            await chat.save();
            results.chats.created++;
          }
        } catch (error) {
          results.chats.errors.push({ id: chatData.id, error: error.message });
        }
      }
    }

    // Sync messages
    if (messages && Array.isArray(messages)) {
      for (const msgData of messages) {
        try {
          const existingMessage = await Message.findOne({
            id: msgData.id,
            chatId: msgData.chatId,
            userId: userId,
          });

          if (existingMessage) {
            // Update existing
            Object.assign(existingMessage, {
              content: msgData.content,
              role: msgData.role,
              timestamp: new Date(msgData.timestamp),
              webSearchUsed: msgData.webSearchUsed,
              imageBase64: msgData.imageBase64,
              imagePath: msgData.imagePath,
              thinkingContent: msgData.thinkingContent,
              isThinking: msgData.isThinking,
              responseTimeMs: msgData.responseTimeMs,
              reaction: msgData.reaction,
              generatedImageBase64: msgData.generatedImageBase64,
              generatedImagePrompt: msgData.generatedImagePrompt,
              generatedImageModel: msgData.generatedImageModel,
              isGeneratingImage: msgData.isGeneratingImage,
            });
            await existingMessage.save();
            results.messages.updated++;
          } else {
            // Create new
            const message = new Message({
              id: msgData.id,
              chatId: msgData.chatId,
              userId: userId,
              role: msgData.role,
              content: msgData.content,
              timestamp: new Date(msgData.timestamp),
              webSearchUsed: msgData.webSearchUsed || false,
              imageBase64: msgData.imageBase64,
              imagePath: msgData.imagePath,
              thinkingContent: msgData.thinkingContent,
              isThinking: msgData.isThinking || false,
              responseTimeMs: msgData.responseTimeMs,
              reaction: msgData.reaction,
              generatedImageBase64: msgData.generatedImageBase64,
              generatedImagePrompt: msgData.generatedImagePrompt,
              generatedImageModel: msgData.generatedImageModel,
              isGeneratingImage: msgData.isGeneratingImage || false,
            });
            await message.save();
            results.messages.created++;
          }
        } catch (error) {
          results.messages.errors.push({ id: msgData.id, error: error.message });
        }
      }
    }

    // Sync memories
    if (memories && Array.isArray(memories)) {
      for (const memData of memories) {
        try {
          const existingMemory = await Memory.findOne({
            id: memData.id,
            userId: userId,
          });

          if (existingMemory) {
            existingMemory.content = memData.content;
            existingMemory.updatedAt = new Date(memData.updatedAt);
            await existingMemory.save();
            results.memories.updated++;
          } else {
            const memory = new Memory({
              id: memData.id,
              userId: userId,
              content: memData.content,
              createdAt: new Date(memData.createdAt),
              updatedAt: new Date(memData.updatedAt),
            });
            await memory.save();
            results.memories.created++;
          }
        } catch (error) {
          results.memories.errors.push({ id: memData.id, error: error.message });
        }
      }
    }

    res.json({
      success: true,
      results: results,
    });
  } catch (error) {
    console.error('Error pushing sync:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to push sync',
      message: error.message,
    });
  }
});

module.exports = router;

