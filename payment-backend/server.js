const express = require('express');
const Razorpay = require('razorpay');
const crypto = require('crypto');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Xibe Payment Backend is running',
    timestamp: new Date().toISOString()
  });
});

// Create order endpoint
app.post('/api/create-order', async (req, res) => {
  try {
    const { amount, currency = 'INR', receipt } = req.body;

    // Validate amount
    if (!amount || amount <= 0) {
      return res.status(400).json({ 
        error: 'Invalid amount',
        message: 'Amount must be greater than 0'
      });
    }

    // Create order options
    const options = {
      amount: amount * 100, // Amount in paise (smallest currency unit)
      currency: currency,
      receipt: receipt || `receipt_${Date.now()}`,
      notes: {
        purpose: 'Xibe Chat Donation',
        timestamp: new Date().toISOString()
      }
    };

    // Create order using Razorpay API
    const order = await razorpay.orders.create(options);
    
    console.log('Order created:', order.id);

    res.json({
      success: true,
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId: process.env.RAZORPAY_KEY_ID
    });

  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ 
      error: 'Failed to create order',
      message: error.message 
    });
  }
});

// Verify payment signature endpoint
app.post('/api/verify-payment', async (req, res) => {
  try {
    const { orderId, paymentId, signature } = req.body;

    // Validate required fields
    if (!orderId || !paymentId || !signature) {
      return res.status(400).json({ 
        error: 'Missing required fields',
        message: 'orderId, paymentId, and signature are required'
      });
    }

    // Generate expected signature
    const data = `${orderId}|${paymentId}`;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(data)
      .digest('hex');

    // Compare signatures
    const isValid = expectedSignature === signature;

    if (isValid) {
      console.log('Payment verified successfully:', paymentId);
      
      // Here you can add logic to:
      // - Store payment details in database
      // - Send confirmation email
      // - Update user credits/benefits
      
      res.json({
        success: true,
        verified: true,
        message: 'Payment verified successfully',
        paymentId: paymentId
      });
    } else {
      console.warn('Payment verification failed:', paymentId);
      res.status(400).json({
        success: false,
        verified: false,
        message: 'Invalid payment signature'
      });
    }

  } catch (error) {
    console.error('Error verifying payment:', error);
    res.status(500).json({ 
      error: 'Failed to verify payment',
      message: error.message 
    });
  }
});

// Get payment details endpoint (optional)
app.get('/api/payment/:paymentId', async (req, res) => {
  try {
    const { paymentId } = req.params;
    
    const payment = await razorpay.payments.fetch(paymentId);
    
    res.json({
      success: true,
      payment: {
        id: payment.id,
        amount: payment.amount / 100, // Convert paise to rupees
        currency: payment.currency,
        status: payment.status,
        method: payment.method,
        email: payment.email,
        contact: payment.contact,
        createdAt: payment.created_at
      }
    });

  } catch (error) {
    console.error('Error fetching payment:', error);
    res.status(500).json({ 
      error: 'Failed to fetch payment details',
      message: error.message 
    });
  }
});

// Webhook endpoint for Razorpay events
app.post('/api/webhook', (req, res) => {
  try {
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
    const signature = req.headers['x-razorpay-signature'];
    
    // Verify webhook signature
    if (webhookSecret) {
      const body = JSON.stringify(req.body);
      const expectedSignature = crypto
        .createHmac('sha256', webhookSecret)
        .update(body)
        .digest('hex');
      
      if (expectedSignature !== signature) {
        console.warn('Invalid webhook signature');
        return res.status(400).send('Invalid signature');
      }
    }
    
    // Process webhook event
    const event = req.body.event;
    const payload = req.body.payload;
    
    console.log('Webhook event received:', event);
    
    switch(event) {
      case 'payment.authorized':
        console.log('Payment authorized:', payload.payment.entity.id);
        // Handle payment authorized
        break;
        
      case 'payment.captured':
        console.log('Payment captured:', payload.payment.entity.id);
        // Handle payment captured
        break;
        
      case 'payment.failed':
        console.log('Payment failed:', payload.payment.entity.id);
        // Handle payment failed
        break;
        
      case 'order.paid':
        console.log('Order paid:', payload.order.entity.id);
        // Handle order paid
        break;
        
      default:
        console.log('Unhandled event:', event);
    }
    
    res.status(200).send('OK');
    
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).send('Webhook processing failed');
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Xibe Payment Backend running on port ${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔑 Razorpay Key ID: ${process.env.RAZORPAY_KEY_ID ? 'Configured' : 'Not configured'}`);
  console.log(`🔐 Razorpay Key Secret: ${process.env.RAZORPAY_KEY_SECRET ? 'Configured' : 'Not configured'}`);
});

module.exports = app;
