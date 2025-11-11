const express = require('express');
const router = express.Router();
const Chat = require('../models/Chat');
const Message = require('../models/Message');
const verifyFirebaseToken = require('../middleware/auth');

const MAX_CHATS_PER_USER = 100;

// Get all chats for a user
router.get('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const { limit = 100, offset = 0 } = req.query;

    const chats = await Chat.find({
      userId: userId,
      deletedAt: null,
    })
      .sort({ updatedAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset))
      .lean();

    // Convert to match Flutter app format
    const formattedChats = chats.map(chat => ({
      id: chat.id,
      title: chat.title,
      createdAt: chat.createdAt.toISOString(),
      updatedAt: chat.updatedAt.toISOString(),
    }));

    res.json({
      success: true,
      chats: formattedChats,
      count: formattedChats.length,
    });
  } catch (error) {
    console.error('Error fetching chats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch chats',
      message: error.message,
    });
  }
});

// Get a single chat by ID
router.get('/:chatId', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const chatId = parseInt(req.params.chatId);

    const chat = await Chat.findOne({
      id: chatId,
      userId: userId,
      deletedAt: null,
    }).lean();

    if (!chat) {
      return res.status(404).json({
        success: false,
        error: 'Chat not found',
      });
    }

    res.json({
      success: true,
      chat: {
        id: chat.id,
        title: chat.title,
        createdAt: chat.createdAt.toISOString(),
        updatedAt: chat.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error fetching chat:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch chat',
      message: error.message,
    });
  }
});

// Create a new chat
router.post('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const { title, createdAt, updatedAt } = req.body;

    // Check chat limit
    const activeChatCount = await Chat.getActiveChatCount(userId);
    if (activeChatCount >= MAX_CHATS_PER_USER) {
      return res.status(400).json({
        success: false,
        error: 'Chat limit exceeded',
        message: `Maximum ${MAX_CHATS_PER_USER} chats per user`,
      });
    }

    // Get next chat ID
    const chatId = await Chat.getNextChatId(userId);

    const chat = new Chat({
      id: chatId,
      userId: userId,
      title: title || 'New Chat',
      createdAt: createdAt ? new Date(createdAt) : new Date(),
      updatedAt: updatedAt ? new Date(updatedAt) : new Date(),
    });

    await chat.save();

    res.status(201).json({
      success: true,
      chat: {
        id: chat.id,
        title: chat.title,
        createdAt: chat.createdAt.toISOString(),
        updatedAt: chat.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error creating chat:', error);
    
    // Handle duplicate ID error
    if (error.code === 11000) {
      // Retry with next ID
      try {
        const userId = req.userId;
        const chatId = await Chat.getNextChatId(userId);
        const chat = new Chat({
          id: chatId,
          userId: userId,
          title: req.body.title || 'New Chat',
          createdAt: req.body.createdAt ? new Date(req.body.createdAt) : new Date(),
          updatedAt: req.body.updatedAt ? new Date(req.body.updatedAt) : new Date(),
        });
        await chat.save();
        
        return res.status(201).json({
          success: true,
          chat: {
            id: chat.id,
            title: chat.title,
            createdAt: chat.createdAt.toISOString(),
            updatedAt: chat.updatedAt.toISOString(),
          },
        });
      } catch (retryError) {
        return res.status(500).json({
          success: false,
          error: 'Failed to create chat after retry',
          message: retryError.message,
        });
      }
    }

    res.status(500).json({
      success: false,
      error: 'Failed to create chat',
      message: error.message,
    });
  }
});

// Update a chat
router.put('/:chatId', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const chatId = parseInt(req.params.chatId);
    const { title, updatedAt } = req.body;

    const chat = await Chat.findOne({
      id: chatId,
      userId: userId,
      deletedAt: null,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        error: 'Chat not found',
      });
    }

    if (title !== undefined) chat.title = title;
    if (updatedAt !== undefined) chat.updatedAt = new Date(updatedAt);
    else chat.updatedAt = new Date();

    await chat.save();

    res.json({
      success: true,
      chat: {
        id: chat.id,
        title: chat.title,
        createdAt: chat.createdAt.toISOString(),
        updatedAt: chat.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error updating chat:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update chat',
      message: error.message,
    });
  }
});

// Delete a chat (soft delete)
router.delete('/:chatId', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const chatId = parseInt(req.params.chatId);

    const chat = await Chat.findOne({
      id: chatId,
      userId: userId,
      deletedAt: null,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        error: 'Chat not found',
      });
    }

    // Soft delete the chat
    await chat.softDelete();

    // Also delete all messages for this chat
    await Message.deleteMany({
      chatId: chatId,
      userId: userId,
    });

    res.json({
      success: true,
      message: 'Chat deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting chat:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete chat',
      message: error.message,
    });
  }
});

// Delete all chats for a user
router.delete('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;

    // Soft delete all chats
    await Chat.updateMany(
      { userId: userId, deletedAt: null },
      { deletedAt: new Date() }
    );

    // Delete all messages
    await Message.deleteMany({ userId: userId });

    res.json({
      success: true,
      message: 'All chats deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting all chats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete all chats',
      message: error.message,
    });
  }
});

module.exports = router;

