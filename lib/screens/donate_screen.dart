import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/payment_service.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final PaymentService _paymentService = PaymentService();
  Razorpay? _razorpay;
  bool _isProcessing = false;
  bool _isMobileSupported = false;
  String _selectedAmount = '100';
  final TextEditingController _customAmountController = TextEditingController();

  // Predefined donation amounts
  final List<String> _predefinedAmounts = ['50', '100', '200', '500', '1000'];

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    // Razorpay Flutter SDK only works on Android and iOS
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _isMobileSupported = true;
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _customAmountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);

    // Verify payment on server
    final isVerified = await _paymentService.verifyPaymentOnServer(
      orderId: response.orderId!,
      paymentId: response.paymentId!,
      signature: response.signature!,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      if (isVerified) {
        _showSuccessDialog(response.paymentId!);
      } else {
        _showErrorDialog('Payment verification failed. Please contact support.');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    
    String errorMessage = 'Payment failed';
    
    switch (response.code) {
      case Razorpay.NETWORK_ERROR:
        errorMessage = 'Network error. Please check your internet connection.';
        break;
      case Razorpay.INVALID_OPTIONS:
        errorMessage = 'Invalid payment options. Please try again.';
        break;
      case Razorpay.PAYMENT_CANCELLED:
        errorMessage = 'Payment cancelled by user.';
        break;
      case Razorpay.TLS_ERROR:
        errorMessage = 'TLS version not supported on this device.';
        break;
      default:
        errorMessage = response.message ?? 'Payment failed';
    }

    _showErrorDialog(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  Future<void> _initiatePayment() async {
    // Get amount
    int amount;
    if (_selectedAmount == 'custom') {
      final customAmount = int.tryParse(_customAmountController.text);
      if (customAmount == null || customAmount <= 0) {
        _showErrorDialog('Please enter a valid amount');
        return;
      }
      amount = customAmount;
    } else {
      amount = int.parse(_selectedAmount);
    }

    setState(() => _isProcessing = true);

    // Check if backend is reachable
    final isBackendHealthy = await _paymentService.checkBackendHealth();
    if (!isBackendHealthy) {
      setState(() => _isProcessing = false);
      _showErrorDialog(
        'Payment backend is not reachable. Please try again later or contact support.',
      );
      return;
    }

    // Create order
    final orderData = await _paymentService.createOrder(amount: amount);

    if (orderData == null) {
      setState(() => _isProcessing = false);
      _showErrorDialog('Failed to create order. Please try again.');
      return;
    }

    setState(() => _isProcessing = false);

    // Open payment gateway
    if (_isMobileSupported && _razorpay != null) {
      _openMobileCheckout(orderData, amount);
    } else {
      _openWebCheckout(orderData, amount);
    }
  }

  void _openMobileCheckout(Map<String, dynamic> orderData, int amount) {
    var options = {
      'key': orderData['keyId'],
      'amount': amount * 100,
      'order_id': orderData['orderId'],
      'name': 'Xibe Chat',
      'description': 'Support Xibe Chat Development',
      'timeout': 300,
      'prefill': {
        'contact': '',
        'email': '',
      },
      'theme': {
        'color': '#3399cc',
      },
      'external': {
        'wallets': ['paytm', 'phonepe', 'googlepay'],
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      _showErrorDialog('Error opening payment: $e');
    }
  }

  void _openWebCheckout(Map<String, dynamic> orderData, int amount) {
    // For web/desktop, show payment instructions with UPI and direct link
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Payment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount: ₹$amount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'To complete your donation on desktop/web, you have these options:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Open on Mobile Device',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Use your mobile device to scan a QR code or open the payment link directly.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              const Text(
                '2. UPI Payment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'You can also directly send payment via UPI to:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              const SelectableText(
                'your-upi-id@bank',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '3. Bank Transfer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Contact us for bank details.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Open Razorpay payment link in browser
              final url = Uri.parse(
                'https://razorpay.me/@yourusername/$amount',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Open Payment Link'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[400], size: 32),
            const SizedBox(width: 12),
            const Text('Thank You!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your donation has been received successfully!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your support helps us continue developing and improving Xibe Chat.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              'Payment ID: $paymentId',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 32),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Xibe Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWideScreen ? 600 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.favorite,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Support Xibe Chat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your donation helps us maintain servers, pay for API costs, and continue developing new features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 32),

                // Amount selection
                const Text(
                  'Select Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Predefined amounts
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _predefinedAmounts.map((amount) {
                    final isSelected = _selectedAmount == amount;
                    return ChoiceChip(
                      label: Text('₹$amount'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedAmount = amount;
                        });
                      },
                    );
                  }).toList()
                    ..add(
                      ChoiceChip(
                        label: const Text('Custom'),
                        selected: _selectedAmount == 'custom',
                        onSelected: (selected) {
                          setState(() {
                            _selectedAmount = 'custom';
                          });
                        },
                      ),
                    ),
                ),

                // Custom amount input
                if (_selectedAmount == 'custom') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Amount (₹)',
                      hintText: 'e.g., 250',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Payment button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment),
                            SizedBox(width: 8),
                            Text(
                              'Proceed to Payment',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                // Payment methods info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Accepted Payment Methods',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentMethodRow(Icons.credit_card, 'Credit/Debit Cards'),
                        _buildPaymentMethodRow(Icons.account_balance, 'Net Banking'),
                        _buildPaymentMethodRow(Icons.payment, 'UPI'),
                        _buildPaymentMethodRow(Icons.account_balance_wallet, 'Wallets'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Security note
                Row(
                  children: [
                    Icon(Icons.security, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Secured by Razorpay • Your payment information is encrypted',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Other support options
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Other Ways to Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSupportOptionTile(
                  Icons.star,
                  'Rate the App',
                  'Leave a review on the app store',
                  () {
                    // Open app store
                  },
                ),
                _buildSupportOptionTile(
                  Icons.share,
                  'Share with Friends',
                  'Help others discover Xibe Chat',
                  () {
                    // Share functionality
                  },
                ),
                _buildSupportOptionTile(
                  Icons.code,
                  'Contribute on GitHub',
                  'Help improve the codebase',
                  () async {
                    final uri = Uri.parse('https://github.com/iotserver24');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
