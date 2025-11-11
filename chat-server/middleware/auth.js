// Simple Firebase Auth verification middleware
// In production, use firebase-admin SDK for proper verification

const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.log('❌ Auth failed: No authorization header');
      console.log('   Headers:', JSON.stringify(req.headers, null, 2));
      return res.status(401).json({ 
        error: 'Unauthorized',
        message: 'No authorization token provided' 
      });
    }

    const token = authHeader.split('Bearer ')[1];
    
    // Extract user ID from token (simplified - in production use firebase-admin)
    // For now, we'll accept userId from header for development
    // TODO: Implement proper Firebase Admin SDK verification
    
    const userId = req.headers['x-user-id'];
    
    if (!userId) {
      console.log('❌ Auth failed: No X-User-Id header');
      console.log('   Authorization header:', authHeader ? 'Present' : 'Missing');
      console.log('   X-User-Id header:', userId || 'Missing');
      return res.status(401).json({ 
        error: 'Unauthorized',
        message: 'User ID not provided' 
      });
    }

    // Attach userId to request
    req.userId = userId;
    req.token = token;
    
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(401).json({ 
      error: 'Unauthorized',
      message: 'Invalid authentication token' 
    });
  }
};

module.exports = verifyFirebaseToken;

