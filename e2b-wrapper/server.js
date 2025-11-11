import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { Sandbox } from '@e2b/code-interpreter';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'E2B Code Executor' });
});

// Code execution endpoint
app.post('/execute', async (req, res) => {
  const { code, language = 'python' } = req.body;

  if (!code || typeof code !== 'string') {
    return res.status(400).json({ 
      success: false, 
      error: 'Code is required and must be a string' 
    });
  }

  let sandbox;
  try {
    // Create sandbox
    sandbox = await Sandbox.create({ template: 'base' });

    // Execute code with language option
    const execution = await sandbox.runCode(code, { language });

    // Prepare response with all execution data
    const response = {
      success: true,
      execution: {
        results: execution.results || [],
        logs: {
          stdout: execution.logs?.stdout || [],
          stderr: execution.logs?.stderr || [],
        },
        error: execution.error || null,
      },
    };

    // Clean up sandbox
    await sandbox.kill();

    res.json(response);
  } catch (error) {
    // Make sure to clean up sandbox on error
    if (sandbox) {
      try {
        await sandbox.kill();
      } catch (killError) {
        console.error('Error killing sandbox:', killError);
      }
    }

    console.error('Execution error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message || 'Unknown error occurred' 
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ 
    success: false, 
    error: 'Internal server error' 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`E2B Code Executor server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Execute endpoint: http://localhost:${PORT}/execute`);
  
  if (!process.env.E2B_API_KEY) {
    console.warn('⚠️  Warning: E2B_API_KEY not set in environment variables');
  }
});
