import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'chat_screen.dart';

/// A split-view screen that shows the chat on the left
/// and the CodeSandbox preview on the right (for desktop/larger screens)
class SplitViewPreviewScreen extends StatefulWidget {
  final String embedUrl;
  final String previewUrl;
  final String title;
  final String framework;

  const SplitViewPreviewScreen({
    super.key,
    required this.embedUrl,
    required this.previewUrl,
    required this.title,
    required this.framework,
  });

  @override
  State<SplitViewPreviewScreen> createState() => _SplitViewPreviewScreenState();
}

class _SplitViewPreviewScreenState extends State<SplitViewPreviewScreen> {
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
              if (mounted) {
                setState(() => _isLoading = true);
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
      
      // Load the URL after a short delay to ensure WebView is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        _webViewController?.loadRequest(Uri.parse(widget.embedUrl));
      });
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.previewUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open URL in browser'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening browser: $e'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          // Left side - Chat/App content
          Expanded(
            flex: 1,
            child: const ChatScreen(),
          ),
          // Divider
          Container(
            width: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          // Right side - Preview
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildPreviewHeader(),
                Expanded(
                  child: _buildWebView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeader() {
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
          const SizedBox(width: 12),
          // Open in browser button
          Tooltip(
            message: 'Open in Browser',
            child: GestureDetector(
              onTap: _openInBrowser,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Close button
          Tooltip(
            message: 'Close Preview',
            child: GestureDetector(
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
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    if (kIsWeb) {
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openInBrowser,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in Browser'),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile and desktop platforms
    if (_webViewController != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _webViewController!),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF10A37F),
                ),
              ),
            ),
        ],
      );
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
