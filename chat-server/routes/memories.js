const express = require('express');
const router = express.Router();
const Memory = require('../models/Memory');
const verifyFirebaseToken = require('../middleware/auth');

// Get all memories for a user
router.get('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;

    const memories = await Memory.find({ userId: userId })
      .sort({ createdAt: -1 })
      .lean();

    res.json({
      success: true,
      memories: memories.map(m => ({
        id: m.id,
        content: m.content,
        createdAt: m.createdAt.toISOString(),
        updatedAt: m.updatedAt.toISOString(),
      })),
    });
  } catch (error) {
    console.error('Error fetching memories:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch memories',
      message: error.message,
    });
  }
});

// Create a memory
router.post('/', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const { content, createdAt, updatedAt } = req.body;

    const memoryId = await Memory.getNextMemoryId(userId);

    const memory = new Memory({
      id: memoryId,
      userId: userId,
      content: content,
      createdAt: createdAt ? new Date(createdAt) : new Date(),
      updatedAt: updatedAt ? new Date(updatedAt) : new Date(),
    });

    await memory.save();

    res.status(201).json({
      success: true,
      memory: {
        id: memory.id,
        content: memory.content,
        createdAt: memory.createdAt.toISOString(),
        updatedAt: memory.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error creating memory:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create memory',
      message: error.message,
    });
  }
});

// Update a memory
router.put('/:memoryId', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const memoryId = parseInt(req.params.memoryId);
    const { content } = req.body;

    const memory = await Memory.findOne({
      id: memoryId,
      userId: userId,
    });

    if (!memory) {
      return res.status(404).json({
        success: false,
        error: 'Memory not found',
      });
    }

    memory.content = content;
    memory.updatedAt = new Date();
    await memory.save();

    res.json({
      success: true,
      memory: {
        id: memory.id,
        content: memory.content,
        createdAt: memory.createdAt.toISOString(),
        updatedAt: memory.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error updating memory:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update memory',
      message: error.message,
    });
  }
});

// Delete a memory
router.delete('/:memoryId', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const memoryId = parseInt(req.params.memoryId);

    const memory = await Memory.findOneAndDelete({
      id: memoryId,
      userId: userId,
    });

    if (!memory) {
      return res.status(404).json({
        success: false,
        error: 'Memory not found',
      });
    }

    res.json({
      success: true,
      message: 'Memory deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting memory:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete memory',
      message: error.message,
    });
  }
});

module.exports = router;

