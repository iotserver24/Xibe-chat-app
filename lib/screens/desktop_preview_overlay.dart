import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:webview_windows/webview_windows.dart' as webview_windows;

/// Desktop overlay that shows preview on the right side of the screen
class DesktopPreviewOverlay extends StatefulWidget {
  final String embedUrl;
  final String previewUrl;
  final String title;
  final String framework;

  const DesktopPreviewOverlay({
    super.key,
    required this.embedUrl,
    required this.previewUrl,
    this.title = 'Preview',
    this.framework = 'Code',
  });

  @override
  State<DesktopPreviewOverlay> createState() => _DesktopPreviewOverlayState();
}

class _DesktopPreviewOverlayState extends State<DesktopPreviewOverlay>
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

  double _widthFraction = 0.5; // Default to 50% of screen width
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // Slide in from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Start the slide-in animation
    _slideController.forward();

    // Initialize appropriate WebView based on platform
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        // Initialize Windows WebView
        try {
          // Check if WebView2 runtime is available
          final version =
              await webview_windows.WebviewController.getWebViewVersion();
          debugPrint('WebView2 version: $version');

          if (version == null || version.isEmpty) {
            throw Exception(
                'WebView2 runtime is not installed. Please install Microsoft Edge WebView2 runtime.');
          }

          await _windowsWebViewController.initialize();
          await _windowsWebViewController.loadUrl(widget.embedUrl);

          _windowsWebViewController.loadingState.listen((state) {
            if (mounted) {
              setState(() {
                _isLoading = state == webview_windows.LoadingState.loading;
              });
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
          ..setBackgroundColor(const Color(0xFF0F0F0F))
          ..enableZoom(true)
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

        // Load the URL
        await _mobileWebViewController?.loadRequest(Uri.parse(widget.embedUrl));
      }
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

  void _close() {
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final previewWidth = screenWidth * _widthFraction;

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
          // Preview panel on the right
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: _slideAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Resize handle
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _isResizing = true;
                        // Calculate new width fraction
                        final delta = -details.primaryDelta! / screenWidth;
                        _widthFraction =
                            (_widthFraction + delta).clamp(0.3, 0.8);
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      setState(() => _isResizing = false);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      child: Container(
                        width: 8,
                        height: double.infinity,
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            width: 2,
                            height: double.infinity,
                            color: _isResizing
                                ? const Color(0xFF10A37F)
                                : Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Preview content
                  Container(
                    width: previewWidth - 8,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: _buildWebView(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            child: InkWell(
              onTap: _openInBrowser,
              borderRadius: BorderRadius.circular(8),
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
            child: InkWell(
              onTap: _close,
              borderRadius: BorderRadius.circular(8),
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
    if (!kIsWeb) {
      if (Platform.isWindows) {
        // Windows WebView
        if (_isWindowsWebViewInitialized) {
          return Stack(
            children: [
              Container(
                color: const Color(0xFF0F0F0F),
                child: webview_windows.Webview(_windowsWebViewController),
              ),
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
        } else if (_webViewError != null) {
          // Error initializing WebView
          return Container(
            color: const Color(0xFF0F0F0F),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'WebView initialization failed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _webViewError!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Make sure WebView2 runtime is installed',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _openInBrowser,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in Browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10A37F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Still initializing
          return Container(
            color: const Color(0xFF0F0F0F),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF10A37F),
                ),
              ),
            ),
          );
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile WebView
        if (_mobileWebViewController != null) {
          return Stack(
            children: [
              Container(
                color: const Color(0xFF0F0F0F),
                child: WebViewWidget(controller: _mobileWebViewController!),
              ),
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
      }
    }

    // Fallback UI for unsupported platforms
    return Container(
      color: const Color(0xFF0F0F0F),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.web,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Preview not available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'WebView is not supported on this platform',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in Browser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10A37F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
