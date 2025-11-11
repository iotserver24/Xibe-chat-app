const mongoose = require('mongoose');

const memorySchema = new mongoose.Schema({
  id: {
    type: Number,
    required: true,
  },
  userId: {
    type: String,
    required: true,
    index: true,
  },
  content: {
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
}, {
  timestamps: false,
});

memorySchema.index({ userId: 1, createdAt: -1 });

// Static method to get next memory ID for a user
memorySchema.statics.getNextMemoryId = async function(userId) {
  const lastMemory = await this.findOne(
    { userId: userId },
    { id: 1 },
    { sort: { id: -1 } }
  );
  return lastMemory ? lastMemory.id + 1 : 1;
};

const Memory = mongoose.model('Memory', memorySchema);

module.exports = Memory;

