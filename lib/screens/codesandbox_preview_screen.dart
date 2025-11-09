import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;

class CodeSandboxPreviewScreen extends StatefulWidget {
  final String embedUrl;
  final String title;
  final String framework;

  const CodeSandboxPreviewScreen({
    super.key,
    required this.embedUrl,
    this.title = 'Preview',
    this.framework = 'Code',
  });

  @override
  State<CodeSandboxPreviewScreen> createState() => _CodeSandboxPreviewScreenState();
}

class _CodeSandboxPreviewScreenState extends State<CodeSandboxPreviewScreen> {
  bool _isLoading = true;
  late WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();

    // Initialize WebView controller for mobile/desktop
    if (!kIsWeb) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF0F0F0F))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView error: ${error.description}');
              // Show error state if page fails to load
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
          ),
        );
      
      // Load the URL after a short delay to ensure WebView is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        _webViewController?.loadRequest(Uri.parse(widget.embedUrl));
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if running on desktop
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            _buildAppBar(),
            // WebView content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: isDesktop 
                      ? BorderRadius.zero 
                      : const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: isDesktop 
                      ? BorderRadius.zero 
                      : const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      _buildWebView(),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10A37F),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Framework badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10A37F).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF10A37F).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.code,
                  size: 14,
                  color: Color(0xFF10A37F),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.framework.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10A37F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    if (kIsWeb) {
      // For Flutter Web, use HtmlElementView (requires web implementation)
      // This is a placeholder - full implementation would need web-specific code
      return Container(
        color: const Color(0xFF0F0F0F),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.open_in_new,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Preview in Browser',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.embedUrl,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Mobile and desktop platforms
    if (_webViewController != null) {
      return WebViewWidget(controller: _webViewController!);
    }

    return Container(
      color: const Color(0xFF0F0F0F),
      child: const Center(
        child: Text(
          'WebView not available',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
