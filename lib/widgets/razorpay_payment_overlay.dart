import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as webview_windows;
import 'package:url_launcher/url_launcher.dart';

class RazorpayPaymentOverlay extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final int amount;
  final String currency;
  final Function(String paymentId, String orderId, String signature) onSuccess;
  final Function(String error) onError;
  final Function() onCancel;

  const RazorpayPaymentOverlay({
    super.key,
    required this.orderData,
    required this.amount,
    required this.currency,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
  });

  @override
  State<RazorpayPaymentOverlay> createState() => _RazorpayPaymentOverlayState();
}

class _RazorpayPaymentOverlayState extends State<RazorpayPaymentOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;

  // For mobile platforms (iOS, Android)
  WebViewController? _mobileWebViewController;

  // For Windows desktop
  final webview_windows.WebviewController _windowsWebViewController =
      webview_windows.WebviewController();
  bool _isWindowsWebViewInitialized = false;
  String? _webViewError;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Slide in from bottom (fullscreen)
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        // Initialize Windows WebView
        try {
          final version =
              await webview_windows.WebviewController.getWebViewVersion();
          if (version == null || version.isEmpty) {
            throw Exception('WebView2 runtime is not installed.');
          }

          await _windowsWebViewController.initialize();

          // Create Razorpay checkout HTML and load it
          // For Windows, we need to use a data URI or load from a URL
          // Since we can't load HTML directly, we'll create a temporary HTML file approach
          // or use Razorpay's hosted checkout page
          final checkoutUrl = _buildRazorpayCheckoutUrl();
          await _windowsWebViewController.loadUrl(checkoutUrl);

          _windowsWebViewController.loadingState.listen((state) {
            if (mounted) {
              setState(() {
                _isLoading = state == webview_windows.LoadingState.loading;
              });
            }
          });

          // Listen for URL changes to detect payment success/failure
          _windowsWebViewController.url.listen((url) {
            if (url.isNotEmpty) {
              _handleUrlChange(url);
            }
          });

          if (mounted) {
            setState(() {
              _isWindowsWebViewInitialized = true;
              _isLoading = false;
            });
          }
        } catch (e) {
          debugPrint('Error initializing Windows WebView: $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isWindowsWebViewInitialized = false;
              _webViewError = e.toString();
            });
          }
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Initialize mobile WebView
        _mobileWebViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..enableZoom(true)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() => _isLoading = true);
                  _handleUrlChange(url);
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              },
            ),
          );

        // Create Razorpay checkout HTML
        final checkoutHtml = _buildRazorpayCheckoutHtml();
        await _mobileWebViewController?.loadHtmlString(checkoutHtml);
      }
    }
  }

  String _buildRazorpayCheckoutUrl() {
    // Create a data URI with the checkout HTML
    final html = _buildRazorpayCheckoutHtml();
    final encodedHtml = Uri.encodeComponent(html);
    return 'data:text/html;charset=utf-8,$encodedHtml';
  }

  String _buildRazorpayCheckoutHtml() {
    final razorpayAmount = widget.currency == 'INR'
        ? widget.amount * 100 // Paise for INR
        : widget.amount * 100; // Cents for USD

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            margin: 0;
            padding: 0;
            width: 100vw;
            height: 100vh;
            overflow: hidden;
            background: transparent;
        }
        html {
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
    </style>
</head>
<body>
    <script>
        var options = {
            "key": "${widget.orderData['keyId']}",
            "amount": $razorpayAmount,
            "currency": "${widget.currency}",
            "name": "Xibe Chat",
            "description": "Support Xibe Chat Development",
            "order_id": "${widget.orderData['orderId']}",
            "handler": function (response) {
                // Payment success - redirect to custom URL scheme
                window.location.href = "razorpay://success?payment_id=" + encodeURIComponent(response.razorpay_payment_id) + 
                    "&order_id=" + encodeURIComponent(response.razorpay_order_id) + 
                    "&signature=" + encodeURIComponent(response.razorpay_signature);
            },
            "prefill": {
                "contact": "",
                "email": ""
            },
            "theme": {
                "color": "#3399cc"
            },
            "modal": {
                "ondismiss": function() {
                    window.location.href = "razorpay://cancel";
                }
            }
        };
        
        // Auto-open Razorpay checkout immediately
        window.onload = function() {
            var rzp = new Razorpay(options);
            rzp.open();
        };
    </script>
</body>
</html>
''';
  }

  void _handleUrlChange(String url) {
    if (url.contains('razorpay://success')) {
      final uri = Uri.parse(url);
      final paymentId = uri.queryParameters['payment_id'];
      final orderId = uri.queryParameters['order_id'];
      final signature = uri.queryParameters['signature'];

      if (paymentId != null && orderId != null && signature != null) {
        widget.onSuccess(paymentId, orderId, signature);
        _close();
      }
    } else if (url.contains('razorpay://cancel')) {
      widget.onCancel();
      _close();
    } else if (url.contains('razorpay://error')) {
      final uri = Uri.parse(url);
      final error = uri.queryParameters['error'] ?? 'Payment failed';
      widget.onError(error);
      _close();
    }
  }

  void _close() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    if (!kIsWeb && Platform.isWindows && _isWindowsWebViewInitialized) {
      _windowsWebViewController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final overlayHeight = screenHeight * 0.75; // 3/4 of screen height

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dimmed background - tap to close
          GestureDetector(
            onTap: _close,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Payment overlay - 3/4 of screen at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                height: overlayHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _buildWebView(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        // Windows WebView - transparent background, Razorpay UI directly
        if (_isWindowsWebViewInitialized) {
          return Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                webview_windows.Webview(_windowsWebViewController),
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        } else if (_webViewError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('WebView initialization failed'),
                const SizedBox(height: 8),
                Text(
                  _webViewError!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse(
                        'https://razorpay.com/payment-button/pl_${widget.orderData['orderId']}/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text('Open in Browser'),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile WebView - transparent background, Razorpay UI directly
        if (_mobileWebViewController != null) {
          return Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                WebViewWidget(controller: _mobileWebViewController!),
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        }
      }
    }

    // Fallback
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final url = Uri.parse(
              'https://razorpay.com/payment-button/pl_${widget.orderData['orderId']}/');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: const Text('Open Payment in Browser'),
      ),
    );
  }
}
