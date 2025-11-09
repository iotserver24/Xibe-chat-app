import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class PaymentService {
  // Update this URL with your deployed backend URL
  static const String _backendUrl = 'http://localhost:3000';
  
  // Create order on backend
  Future<Map<String, dynamic>?> createOrder({
    required int amount,
    String currency = 'INR',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        debugPrint('Failed to create order: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  // Verify payment on backend
  Future<bool> verifyPaymentOnServer({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['verified'] == true;
      }
    } catch (e) {
      debugPrint('Verification error: $e');
    }
    return false;
  }

  // Client-side signature verification (as backup)
  bool verifySignatureLocally({
    required String orderId,
    required String paymentId,
    required String signature,
    required String keySecret,
  }) {
    try {
      String data = '$orderId|$paymentId';
      var key = utf8.encode(keySecret);
      var bytes = utf8.encode(data);
      var hmac = Hmac(sha256, key);
      var digest = hmac.convert(bytes);
      return digest.toString() == signature;
    } catch (e) {
      debugPrint('Local verification error: $e');
      return false;
    }
  }

  // Get payment details (optional)
  Future<Map<String, dynamic>?> getPaymentDetails(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/payment/$paymentId'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payment'];
      }
    } catch (e) {
      debugPrint('Error fetching payment details: $e');
    }
    return null;
  }

  // Check backend health
  Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/health'),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend health check failed: $e');
      return false;
    }
  }
}
