const express = require('express');
const router = express.Router();
const axios = require('axios');
const verifyFirebaseToken = require('../middleware/auth');

// Proxy AI chat completions to external API
router.post('/chat/completions', verifyFirebaseToken, async (req, res) => {
  try {
    const userId = req.userId;
    const {
      model,
      messages,
      stream = false,
      systemPrompt,
      useWebSearch,
      reasoning,
      tools,
    } = req.body;

    console.log(`🤖 AI Request - User: ${userId}, Model: ${model}, Stream: ${stream}`);

    // Get API key from environment or use default
    const apiKey = process.env.XIBE_API_KEY || process.env.API_KEY;
    
    if (!apiKey) {
      console.error('❌ No API key configured');
      return res.status(500).json({
        success: false,
        error: 'AI service not configured',
        message: 'API key not set in server environment',
      });
    }

    // Build messages array
    const apiMessages = [];
    
    // Add system prompt if provided
    if (systemPrompt && systemPrompt.trim()) {
      apiMessages.push({
        role: 'system',
        content: systemPrompt,
      });
    }

    // Add conversation history
    if (messages && Array.isArray(messages)) {
      apiMessages.push(...messages);
    }

    // Prepare request body for external API
    const requestBody = {
      model: model || 'gemini',
      messages: apiMessages,
      stream: stream,
    };

    // Add optional parameters
    if (reasoning) {
      requestBody.reasoning = reasoning;
    }

    if (tools && Array.isArray(tools) && tools.length > 0) {
      requestBody.tools = tools;
    }

    // Make request to external API
    const apiUrl = process.env.XIBE_API_URL || 'https://api.xibe.app';
    const endpoint = `${apiUrl}/openai/v1/chat/completions`;

    console.log(`📡 Forwarding to: ${endpoint}`);

    if (stream) {
      // Handle streaming response
      try {
        const response = await axios({
          method: 'POST',
          url: endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`,
          },
          data: requestBody,
          responseType: 'stream',
        });

        console.log(`✅ Stream response status: ${response.status}`);

        // Set headers for streaming
        res.setHeader('Content-Type', 'text/event-stream');
        res.setHeader('Cache-Control', 'no-cache');
        res.setHeader('Connection', 'keep-alive');

        // Handle stream errors
        response.data.on('error', (error) => {
          console.error('❌ Stream error:', error.message);
          if (!res.headersSent) {
            res.status(500).json({
              success: false,
              error: 'Stream error',
              message: error.message,
            });
          }
        });

        // Pipe the stream to client
        response.data.pipe(res);
      } catch (streamError) {
        console.error('❌ Stream setup error:', streamError.message);
        if (!res.headersSent) {
          res.status(500).json({
            success: false,
            error: 'Failed to start stream',
            message: streamError.message,
          });
        }
      }
    } else {
      // Handle non-streaming response
      const response = await axios({
        method: 'POST',
        url: endpoint,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        data: requestBody,
        timeout: 60000, // 60 second timeout
      });

      res.json(response.data);
    }
  } catch (error) {
    console.error('❌ AI request error:', error.message);
    
    if (error.response) {
      // Forward error from external API
      res.status(error.response.status).json({
        success: false,
        error: 'AI service error',
        message: error.response.data?.message || error.message,
      });
    } else {
      res.status(500).json({
        success: false,
        error: 'AI request failed',
        message: error.message,
      });
    }
  }
});

// Get available models
router.get('/models', verifyFirebaseToken, async (req, res) => {
  try {
    const apiKey = process.env.XIBE_API_KEY || process.env.API_KEY;
    const apiUrl = process.env.XIBE_API_URL || 'https://api.xibe.app';
    const endpoint = `${apiUrl}/api/xibe/models`;

    if (!apiKey) {
      return res.status(500).json({
        success: false,
        error: 'AI service not configured',
      });
    }

    const response = await axios({
      method: 'GET',
      url: endpoint,
      headers: {
        'Content-Type': 'application/json',
      },
      timeout: 30000,
    });

    res.json(response.data);
  } catch (error) {
    console.error('❌ Error fetching models:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch models',
      message: error.message,
    });
  }
});

module.exports = router;

