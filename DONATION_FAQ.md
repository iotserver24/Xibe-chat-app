# Donation Feature - Frequently Asked Questions

## General Questions

### Q1: What is the donation feature?
The donation feature allows users to support Xibe Chat development through secure payments via Razorpay. Users can donate any amount they wish through various payment methods.

### Q2: Is the donation feature mandatory?
No, Xibe Chat is completely free and open source. Donations are optional and purely voluntary.

### Q3: Where can I find the donation option?
Open the app → Settings → Support → Donate

### Q4: What payment methods are supported?
- Credit/Debit Cards (Visa, Mastercard, Amex, etc.)
- UPI (GPay, PhonePe, Paytm, etc.)
- Net Banking (all major banks)
- Digital Wallets (Paytm, PhonePe, etc.)

### Q5: Is it safe to donate through the app?
Yes! All payments are processed through Razorpay, a certified PCI DSS Level 1 compliant payment gateway. Your payment information is encrypted and secure.

---

## For Users

### Q6: What platforms support in-app donations?
- ✅ **Android** - Full support with native Razorpay
- ✅ **iOS** - Full support with native Razorpay
- ⚠️ **Web** - Shows payment link (opens in browser)
- ⚠️ **Windows/macOS/Linux** - Shows payment link (opens in browser)

### Q7: Can I donate from desktop?
Yes! On desktop, you'll be shown a payment link that opens in your browser or you can use alternative payment methods like UPI.

### Q8: What happens after I donate?
You'll see a "Thank You" message with your payment ID. Your support helps maintain servers, pay for API costs, and develop new features.

### Q9: Will I get a receipt?
Yes, Razorpay automatically sends a payment receipt to your email (if provided during payment).

### Q10: Can I get a refund?
Contact support with your payment ID if you need a refund. Refunds are processed through Razorpay.

### Q11: Can I donate multiple times?
Yes! You can donate as many times as you want.

### Q12: What's the minimum donation amount?
The minimum is ₹1, but we suggest at least ₹50 to cover transaction fees.

### Q13: Can I donate in other currencies?
Currently, the system is set up for INR (Indian Rupees). For other currencies, contact support.

---

## For Developers

### Q14: How do I set up the donation feature in my fork?
1. Read [DONATION_QUICKSTART.md](DONATION_QUICKSTART.md) for quick setup
2. Sign up for Razorpay account
3. Deploy the Node.js backend
4. Configure environment variables
5. Update Flutter app with backend URL

### Q15: Do I need a Razorpay account?
Yes, you need a Razorpay account to accept payments. Sign up at https://dashboard.razorpay.com

### Q16: Is KYC required?
For live payments, yes. Razorpay requires KYC verification. You can use Test Mode without KYC for development.

### Q17: How do I test payments without real money?
Use Razorpay Test Mode with test cards:
- Card: `4111 1111 1111 1111`
- CVV: `123`
- Expiry: Any future date

### Q18: Where should I deploy the backend?
Popular options:
- **Free**: Vercel, Railway (limited)
- **Paid**: Heroku ($7/month), DigitalOcean ($6/month)
- See [payment-backend/DEPLOYMENT.md](payment-backend/DEPLOYMENT.md)

### Q19: Can I use a different payment gateway?
Yes! The code is modular. You can replace Razorpay with Stripe, PayPal, or any other gateway by modifying the backend and Flutter service.

### Q20: How do I change donation amounts?
Edit `lib/screens/donate_screen.dart`:
```dart
final List<String> _predefinedAmounts = ['50', '100', '200', '500', '1000'];
```

### Q21: Can I customize the donation screen?
Yes! The entire UI is in `lib/screens/donate_screen.dart`. You can customize:
- Colors and theme
- Text and descriptions
- Logo and branding
- Payment amounts
- Additional features

---

## Technical Questions

### Q22: How is payment security ensured?
1. **Server-side order creation** - Orders created on backend
2. **Signature verification** - HMAC SHA256 signature verification
3. **HTTPS encryption** - All API calls encrypted
4. **PCI compliance** - Razorpay is PCI DSS Level 1 certified
5. **No sensitive data storage** - API keys in environment variables only

### Q23: What's the payment flow?
```
User → Flutter App → Backend Server → Razorpay API
                 ← Payment Gateway ←
Payment → Razorpay → Flutter App → Backend (verify)
                   → Show Success
```

### Q24: How is payment verified?
Backend verifies using HMAC SHA256:
```
signature = HMAC_SHA256(key_secret, orderId|paymentId)
```
If signature matches, payment is authentic.

### Q25: What happens if verification fails?
The payment is still captured by Razorpay, but the app shows an error. Contact support with payment ID to resolve.

### Q26: Are webhooks required?
No, they're optional. Webhooks provide real-time payment notifications from Razorpay for better tracking.

### Q27: How do I set up webhooks?
1. Go to Razorpay Dashboard → Settings → Webhooks
2. Add URL: `https://your-backend.com/api/webhook`
3. Select events: payment.captured, payment.failed, etc.
4. Copy webhook secret
5. Add to backend `.env`: `RAZORPAY_WEBHOOK_SECRET=xxx`

### Q28: What API endpoints does the backend provide?
- `GET /health` - Health check
- `POST /api/create-order` - Create payment order
- `POST /api/verify-payment` - Verify payment
- `GET /api/payment/:id` - Get payment details
- `POST /api/webhook` - Webhook handler

### Q29: Can I run backend and Flutter on same domain?
Yes, but they should be separate services. Backend handles payments, Flutter is the app.

### Q30: How do I monitor payments?
- **Razorpay Dashboard**: View all payments, refunds, disputes
- **Backend Logs**: Monitor API calls and errors
- **Webhooks**: Get real-time payment events

---

## Troubleshooting

### Q31: "Backend not reachable" error
**Solutions:**
1. Check if backend is running
2. Verify backend URL in `payment_service.dart`
3. Check firewall/CORS settings
4. Test with: `curl https://your-backend.com/health`

### Q32: "Payment verification failed" error
**Solutions:**
1. Check API keys are correct in backend `.env`
2. Verify no extra spaces in environment variables
3. Check backend logs for signature mismatch
4. Ensure order ID matches

### Q33: Razorpay not opening on Android
**Solutions:**
1. Run `flutter clean && flutter pub get`
2. Check `minSdkVersion` is 21 in `android/app/build.gradle`
3. Rebuild app: `flutter build apk --release`
4. Check ProGuard rules are in place

### Q34: Payment successful but showing error
**Cause:** Verification issue or network timeout

**Solutions:**
1. Check Razorpay Dashboard - payment may be captured
2. Verify backend logs
3. Contact user with payment ID

### Q35: Web version not showing payment gateway
**Expected Behavior:** Web shows payment instructions and link instead of native SDK (not supported by Razorpay Flutter package).

**Solutions:**
1. User can click "Open Payment Link"
2. Or use mobile device for better experience
3. Or implement custom web integration with Razorpay Checkout.js

### Q36: Test payment not working
**Solutions:**
1. Verify using Test Mode API keys (starts with `rzp_test_`)
2. Use test card: `4111 1111 1111 1111`
3. Check backend is using test keys
4. Check Razorpay Dashboard → Test Mode → Payments

### Q37: Production payment failing
**Solutions:**
1. Complete KYC in Razorpay Dashboard
2. Ensure using Live API keys (starts with `rzp_live_`)
3. Check payment method is enabled in Dashboard
4. Verify backend is deployed correctly

---

## Support & Contact

### Q38: Where can I get help?
- **Documentation**: Check all DONATION_*.md files
- **Razorpay Support**: support@razorpay.com
- **Razorpay Docs**: https://razorpay.com/docs/
- **GitHub Issues**: https://github.com/iotserver24/xibe-chat/issues

### Q39: How do I report a payment issue?
1. Note your payment ID (shown after payment)
2. Take screenshot of error (if any)
3. Contact support with details:
   - Payment ID
   - Amount
   - Date & time
   - Error message (if any)

### Q40: Can I contribute to this feature?
Yes! Xibe Chat is open source. You can:
- Report bugs
- Suggest improvements
- Submit pull requests
- Improve documentation

---

## Best Practices

### For Developers

1. **Always test in Test Mode first**
   - Use test keys for development
   - Test all payment flows
   - Test error scenarios

2. **Never commit secrets**
   - Use environment variables
   - Add `.env` to `.gitignore`
   - Use different keys for dev/prod

3. **Verify payments on server**
   - Don't trust client-side verification
   - Always verify signature on backend

4. **Use HTTPS in production**
   - Get SSL certificate
   - Encrypt all communication

5. **Monitor payments regularly**
   - Check Razorpay Dashboard
   - Set up alerts
   - Review backend logs

6. **Handle errors gracefully**
   - Show user-friendly messages
   - Log errors for debugging
   - Provide support contact

7. **Keep documentation updated**
   - Update backend URL in docs
   - Document any custom changes
   - Keep version numbers current

### For Users

1. **Verify app authenticity**
   - Download from official sources
   - Check SSL certificate (web)
   - Verify payment gateway is Razorpay

2. **Use secure network**
   - Avoid public WiFi for payments
   - Use trusted internet connection

3. **Save payment ID**
   - Note payment ID after successful payment
   - Keep receipt email
   - Take screenshot

4. **Contact support if issues**
   - Don't retry multiple times
   - Wait for confirmation
   - Contact with payment ID

---

## Future Enhancements

### Planned Features

1. **Subscription Support**
   - Monthly/yearly recurring donations
   - Premium features for subscribers

2. **Payment History**
   - View past donations in app
   - Download receipts

3. **Multiple Currencies**
   - Support USD, EUR, etc.
   - Auto-detect user location

4. **Enhanced Analytics**
   - Track donation patterns
   - Show impact to users

5. **Social Features**
   - Share donation on social media
   - Thank you badges
   - Leaderboards (optional)

---

## Quick Reference

### Test Credentials
```
Card: 4111 1111 1111 1111
CVV: 123
Expiry: 12/25
UPI: success@razorpay
```

### Backend URLs
```
Local: http://localhost:3000
Android Emulator: http://10.0.2.2:3000
Production: https://your-backend.com
```

### Important Files
```
Backend: payment-backend/server.js
Service: lib/services/payment_service.dart
Screen: lib/screens/donate_screen.dart
Docs: DONATION_*.md files
```

### Support Contacts
```
Razorpay: support@razorpay.com
Docs: https://razorpay.com/docs/
GitHub: https://github.com/iotserver24/xibe-chat
```

---

**Last Updated:** January 2024  
**Version:** 1.0.0
