const express = require('express');
const router = express.Router();
const Message = require('../models/Message');
const Chat = require('../models/Chat');
const verifyFirebaseToken = require('../middleware/auth');

// Get all messages for a chat
router.get('/chat/:chatId', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const chatId = parseInt(req.params.chatId);
    const { limit = 200, offset = 0 } = req.query;

    // Verify chat belongs to user
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

    const messages = await Message.find({
      chatId: chatId,
      userId: userId,
    })
      .sort({ timestamp: -1 }) // Newest first for performance (better indexed)
      .limit(parseInt(limit))
      .skip(parseInt(offset))
      .lean();
    
    // Reverse back to oldest first for Flutter app
    messages.reverse();

    // Convert to match Flutter app format
    const formattedMessages = messages.map(msg => ({
      id: msg.id,
      role: msg.role,
      content: msg.content,
      timestamp: msg.timestamp.toISOString(),
      webSearchUsed: msg.webSearchUsed,
      chatId: msg.chatId,
      imageBase64: msg.imageBase64,
      imagePath: msg.imagePath,
      thinkingContent: msg.thinkingContent,
      isThinking: msg.isThinking,
      responseTimeMs: msg.responseTimeMs,
      reaction: msg.reaction,
      generatedImageBase64: msg.generatedImageBase64,
      generatedImagePrompt: msg.generatedImagePrompt,
      generatedImageModel: msg.generatedImageModel,
      isGeneratingImage: msg.isGeneratingImage,
    }));

    res.json({
      success: true,
      messages: formattedMessages,
      count: formattedMessages.length,
    });
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch messages',
      message: error.message,
    });
  }
});

// Create a new message
router.post('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const {
      chatId,
      role,
      content,
      timestamp,
      webSearchUsed,
      imageBase64,
      imagePath,
      thinkingContent,
      isThinking,
      responseTimeMs,
      reaction,
      generatedImageBase64,
      generatedImagePrompt,
      generatedImageModel,
      isGeneratingImage,
    } = req.body;

    console.log(`📨 Creating message - User: ${userId}, Chat: ${chatId}, Role: ${role}, Content length: ${content?.length || 0}`);

    // Verify chat belongs to user
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

    // Get next message ID
    const messageId = await Message.getNextMessageId(chatId);

    const message = new Message({
      id: messageId,
      chatId: chatId,
      userId: userId,
      role: role,
      content: content,
      timestamp: timestamp ? new Date(timestamp) : new Date(),
      webSearchUsed: webSearchUsed || false,
      imageBase64: imageBase64 || null,
      imagePath: imagePath || null,
      thinkingContent: thinkingContent || null,
      isThinking: isThinking || false,
      responseTimeMs: responseTimeMs || null,
      reaction: reaction || null,
      generatedImageBase64: generatedImageBase64 || null,
      generatedImagePrompt: generatedImagePrompt || null,
      generatedImageModel: generatedImageModel || null,
      isGeneratingImage: isGeneratingImage || false,
    });

    await message.save();

    // Update chat's updatedAt
    chat.updatedAt = new Date();
    await chat.save();

    res.status(201).json({
      success: true,
      message: {
        id: message.id,
        role: message.role,
        content: message.content,
        timestamp: message.timestamp.toISOString(),
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
      },
    });
  } catch (error) {
    console.error('Error creating message:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create message',
      message: error.message,
    });
  }
});

// Update a message (e.g., for reactions)
router.put('/:messageId', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const messageId = parseInt(req.params.messageId);
    const updates = req.body;

    const message = await Message.findOne({
      id: messageId,
      userId: userId,
    });

    if (!message) {
      return res.status(404).json({
        success: false,
        error: 'Message not found',
      });
    }

    // Update allowed fields
    if (updates.reaction !== undefined) message.reaction = updates.reaction;
    if (updates.content !== undefined) message.content = updates.content;
    if (updates.isThinking !== undefined) message.isThinking = updates.isThinking;
    if (updates.thinkingContent !== undefined) message.thinkingContent = updates.thinkingContent;
    if (updates.isGeneratingImage !== undefined) message.isGeneratingImage = updates.isGeneratingImage;
    if (updates.generatedImageBase64 !== undefined) message.generatedImageBase64 = updates.generatedImageBase64;

    await message.save();

    res.json({
      success: true,
      message: {
        id: message.id,
        role: message.role,
        content: message.content,
        timestamp: message.timestamp.toISOString(),
        webSearchUsed: message.webSearchUsed,
        chatId: message.chatId,
        reaction: message.reaction,
        isThinking: message.isThinking,
        thinkingContent: message.thinkingContent,
        isGeneratingImage: message.isGeneratingImage,
        generatedImageBase64: message.generatedImageBase64,
      },
    });
  } catch (error) {
    console.error('Error updating message:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update message',
      message: error.message,
    });
  }
});

// Delete a message
router.delete('/:messageId', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const messageId = parseInt(req.params.messageId);

    const message = await Message.findOneAndDelete({
      id: messageId,
      userId: userId,
    });

    if (!message) {
      return res.status(404).json({
        success: false,
        error: 'Message not found',
      });
    }

    res.json({
      success: true,
      message: 'Message deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting message:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete message',
      message: error.message,
    });
  }
});

module.exports = router;

