import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/payment_service.dart';
import '../widgets/razorpay_payment_overlay.dart';

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
  String _selectedCurrency = 'INR';
  final TextEditingController _customAmountController = TextEditingController();

  // Predefined donation amounts for each currency
  final Map<String, List<String>> _predefinedAmounts = {
    'INR': ['50', '100', '200', '500', '1000'],
    'USD': ['1', '5', '10', '25', '50'],
  };

  // Currency symbols
  final Map<String, String> _currencySymbols = {
    'INR': '₹',
    'USD': '\$',
  };

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
        _showErrorDialog(
            'Payment verification failed. Please contact support.');
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

    // Create order with selected currency
    final orderData = await _paymentService.createOrder(
      amount: amount,
      currency: _selectedCurrency,
    );

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
      // For desktop/web, open Razorpay in WebView overlay
      _openDesktopCheckout(orderData, amount);
    }
  }

  void _openMobileCheckout(Map<String, dynamic> orderData, int amount) {
    // Convert amount based on currency (Razorpay expects amount in smallest unit)
    final razorpayAmount = _selectedCurrency == 'INR'
        ? amount * 100 // Paise for INR
        : amount * 100; // Cents for USD

    var options = {
      'key': orderData['keyId'],
      'amount': razorpayAmount,
      'order_id': orderData['orderId'],
      'currency': _selectedCurrency,
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

  void _openDesktopCheckout(Map<String, dynamic> orderData, int amount) {
    // Open Razorpay checkout in fullscreen WebView overlay for desktop (like Android)
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RazorpayPaymentOverlay(
          orderData: orderData,
          amount: amount,
          currency: _selectedCurrency,
          onSuccess: (paymentId, orderId, signature) async {
            Navigator.of(context).pop(); // Close overlay first
            // Verify payment on server
            final isVerified = await _paymentService.verifyPaymentOnServer(
              orderId: orderId,
              paymentId: paymentId,
              signature: signature,
            );

            if (mounted) {
              if (isVerified) {
                _showSuccessDialog(paymentId);
              } else {
                _showErrorDialog(
                    'Payment verification failed. Please contact support.');
              }
            }
          },
          onError: (error) {
            Navigator.of(context).pop(); // Close overlay first
            if (mounted) {
              _showErrorDialog(error);
            }
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close overlay
          },
        ),
        fullscreenDialog: true,
        opaque: false,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
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
    final currencySymbol = _currencySymbols[_selectedCurrency]!;
    final amounts = _predefinedAmounts[_selectedCurrency]!;

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
                  'Created by R3AP3Reditz (Anish Kumar)\n\nYour donation helps maintain servers, pay for API costs, and continue developing new features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 32),

                // Currency selection
                const Text(
                  'Select Currency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text('₹ INR'),
                        selected: _selectedCurrency == 'INR',
                        onSelected: (selected) {
                          setState(() {
                            _selectedCurrency = 'INR';
                            _selectedAmount =
                                '100'; // Reset to default for currency
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: Text('\$ USD'),
                        selected: _selectedCurrency == 'USD',
                        onSelected: (selected) {
                          setState(() {
                            _selectedCurrency = 'USD';
                            _selectedAmount =
                                '5'; // Reset to default for currency
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

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
                  children: amounts.map((amount) {
                    final isSelected = _selectedAmount == amount;
                    return ChoiceChip(
                      label: Text('$currencySymbol$amount'),
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
                    decoration: InputDecoration(
                      labelText: 'Enter Amount ($currencySymbol)',
                      hintText:
                          _selectedCurrency == 'INR' ? 'e.g., 250' : 'e.g., 10',
                      prefixText: '$currencySymbol ',
                      border: const OutlineInputBorder(),
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
                        _buildPaymentMethodRow(
                            Icons.credit_card, 'Credit/Debit Cards'),
                        _buildPaymentMethodRow(
                            Icons.account_balance, 'Net Banking'),
                        if (_selectedCurrency == 'INR')
                          _buildPaymentMethodRow(Icons.payment, 'UPI'),
                        _buildPaymentMethodRow(
                            Icons.account_balance_wallet, 'Wallets'),
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

                // Additional support options
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Other Ways to Support',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSupportOptionTile(
                          Icons.star,
                          'Star on GitHub',
                          'Show your support by starring our repository',
                          () async {
                            final url = Uri.parse(
                                'https://github.com/iotserver24/xibe-chat-app');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        const Divider(height: 1),
                        _buildSupportOptionTile(
                          Icons.bug_report,
                          'Report Issues',
                          'Help us improve by reporting bugs',
                          () async {
                            final url = Uri.parse(
                                'https://github.com/iotserver24/xibe-chat-app/issues');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        const Divider(height: 1),
                        _buildSupportOptionTile(
                          Icons.forum,
                          'Discussions',
                          'Join community discussions',
                          () async {
                            final url = Uri.parse(
                                'https://github.com/iotserver24/xibe-chat-app/discussions');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        const Divider(height: 1),
                        _buildSupportOptionTile(
                          Icons.lightbulb_outline,
                          'Feature Requests',
                          'Suggest new features',
                          () async {
                            final url = Uri.parse(
                                'https://github.com/iotserver24/xibe-chat-app/discussions/categories/ideas');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[300]),
          const SizedBox(width: 12),
          Text(
            label,
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
