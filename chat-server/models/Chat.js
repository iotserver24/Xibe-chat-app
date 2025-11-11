const mongoose = require('mongoose');

const chatSchema = new mongoose.Schema({
  id: {
    type: Number,
    required: true,
    unique: true,
  },
  userId: {
    type: String,
    required: true,
    index: true,
  },
  title: {
    type: String,
    required: true,
    maxlength: 500,
  },
  createdAt: {
    type: Date,
    required: true,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    required: true,
    default: Date.now,
  },
  deletedAt: {
    type: Date,
    default: null,
  },
}, {
  timestamps: false, // We manage timestamps manually
});

// Index for faster queries
chatSchema.index({ userId: 1, updatedAt: -1 });
chatSchema.index({ userId: 1, deletedAt: 1 });

// Pre-save hook to update updatedAt
chatSchema.pre('save', function(next) {
  if (this.isModified() && !this.isNew) {
    this.updatedAt = new Date();
  }
  next();
});

// Virtual to check if chat is deleted
chatSchema.virtual('isDeleted').get(function() {
  return this.deletedAt !== null;
});

// Method to soft delete
chatSchema.methods.softDelete = function() {
  this.deletedAt = new Date();
  return this.save();
};

// Static method to get user's active chats count
chatSchema.statics.getActiveChatCount = async function(userId) {
  return this.countDocuments({
    userId: userId,
    deletedAt: null,
  });
};

// Static method to get next chat ID for a user
chatSchema.statics.getNextChatId = async function(userId) {
  const lastChat = await this.findOne(
    { userId: userId },
    { id: 1 },
    { sort: { id: -1 } }
  );
  return lastChat ? lastChat.id + 1 : 1;
};

const Chat = mongoose.model('Chat', chatSchema);

module.exports = Chat;

