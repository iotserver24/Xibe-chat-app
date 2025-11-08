const express = require('express');
const cors = require('cors');
const compression = require('compression');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(compression());
app.use(express.json({ limit: '10mb' }));

// CodeSandbox API configuration
const CODESANDBOX_API = 'https://codesandbox.io/api/v1/sandboxes/define';

/**
 * POST /preview/create
 * Creates a browser preview sandbox using CodeSandbox Define API
 * Body: { files: { "path": { "content": "..." }, ... }, framework: "react|vue|..." }
 */
app.post('/preview/create', async (req, res) => {
  try {
    const { files, framework } = req.body;

    if (!files || typeof files !== 'object') {
      return res.status(400).json({ error: 'Missing or invalid files object' });
    }

    // Create sandbox using CodeSandbox Define API
    const response = await axios.post(`${CODESANDBOX_API}?json=1`, {
      files,
      query: 'view=preview&autoresize=1',
    }, {
      headers: {
        'Content-Type': 'application/json',
      },
      timeout: 30000,
    });

    const sandboxId = response.data.sandbox_id;
    
    res.json({
      success: true,
      sandboxId,
      previewUrl: `https://codesandbox.io/s/${sandboxId}?view=preview`,
      embedUrl: `https://codesandbox.io/embed/${sandboxId}?view=preview&hidenavigation=1&module=/src/index.js`,
      framework: framework || 'unknown',
    });
  } catch (error) {
    console.error('Error creating preview:', error.message);
    
    if (error.response?.status === 429) {
      return res.status(429).json({
        error: 'Rate limit exceeded',
        retryAfter: error.response.headers['retry-after'] || 60,
      });
    }

    res.status(500).json({
      error: 'Failed to create preview sandbox',
      details: error.message,
    });
  }
});

/**
 * GET /health
 * Health check endpoint
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message,
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 CodeSandbox Proxy Server running on port ${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
});
