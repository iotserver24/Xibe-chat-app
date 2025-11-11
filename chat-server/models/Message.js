const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  id: {
    type: Number,
    required: true,
  },
  chatId: {
    type: Number,
    required: true,
    index: true,
  },
  userId: {
    type: String,
    required: true,
    index: true,
  },
  role: {
    type: String,
    required: true,
    enum: ['user', 'assistant', 'system'],
  },
  content: {
    type: String,
    required: true,
  },
  timestamp: {
    type: Date,
    required: true,
    default: Date.now,
  },
  webSearchUsed: {
    type: Boolean,
    default: false,
  },
  imageBase64: {
    type: String,
    default: null,
  },
  imagePath: {
    type: String,
    default: null,
  },
  thinkingContent: {
    type: String,
    default: null,
  },
  isThinking: {
    type: Boolean,
    default: false,
  },
  responseTimeMs: {
    type: Number,
    default: null,
  },
  reaction: {
    type: String,
    default: null,
  },
  generatedImageBase64: {
    type: String,
    default: null,
  },
  generatedImagePrompt: {
    type: String,
    default: null,
  },
  generatedImageModel: {
    type: String,
    default: null,
  },
  isGeneratingImage: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: false,
});

// Compound index for faster queries
messageSchema.index({ chatId: 1, timestamp: -1 });
messageSchema.index({ userId: 1, timestamp: -1 });

// Static method to get next message ID for a chat
messageSchema.statics.getNextMessageId = async function(chatId) {
  const lastMessage = await this.findOne(
    { chatId: chatId },
    { id: 1 },
    { sort: { id: -1 } }
  );
  return lastMessage ? lastMessage.id + 1 : 1;
};

const Message = mongoose.model('Message', messageSchema);

module.exports = Message;

