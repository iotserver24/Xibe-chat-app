import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  
  // Callback for when a deep link is received
  Function(Uri)? onDeepLinkReceived;

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Handle initial deep link if app was launched from one
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error handling initial app link: $e');
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('App link error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');
    
    // Call the registered callback if available
    if (onDeepLinkReceived != null) {
      onDeepLinkReceived!(uri);
    }
  }

  /// Parse a deep link URI and extract relevant information
  DeepLinkData? parseDeepLink(Uri uri) {
    debugPrint('Parsing deep link: $uri');
    debugPrint('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    
    // Handle custom scheme: xibechat://
    if (uri.scheme == 'xibechat') {
      return _parseCustomScheme(uri);
    }
    
    // Handle HTTP/HTTPS scheme: https://chat.xibe.app/app/...
    if ((uri.scheme == 'http' || uri.scheme == 'https') && 
        (uri.host.contains('chat.xibe.app') || uri.host.contains('xibechat'))) {
      return _parseHttpScheme(uri);
    }
    
    return null;
  }

  DeepLinkData? _parseCustomScheme(Uri uri) {
    final path = uri.host + uri.path;
    
    // Handle Google OAuth callback: xibechat://auth/google?token=...
    if (path.startsWith('auth/google')) {
      return DeepLinkData(
        type: DeepLinkType.googleOAuthCallback,
        oauthParams: uri.queryParameters,
      );
    }
    
    // Check for query parameters first (more user-friendly for website buttons)
    final messageParam = uri.queryParameters['message'];
    final textParam = uri.queryParameters['text'];
    final promptParam = uri.queryParameters['prompt'];
    final message = messageParam ?? textParam ?? promptParam;
    
    // xibechat://mes/{prompt} - Open with message (path-based)
    // Note: Query parameters are ignored for mes/ paths to maintain path-based behavior
    if (path.startsWith('mes/')) {
      final prompt = Uri.decodeComponent(path.substring(4));
      return DeepLinkData(
        type: DeepLinkType.message,
        messagePrompt: prompt,
      );
    }
    
    // xibechat://new?message=text - Create new chat with pre-filled message (query-based)
    // This only applies to 'new' or empty paths, not to mes/ paths
    if ((path == 'new' || path.isEmpty) && message != null && message.isNotEmpty) {
      return DeepLinkData(
        type: DeepLinkType.message,
        messagePrompt: Uri.decodeComponent(message),
      );
    }
    
    // xibechat://chat/{chatId} - Open specific chat
    if (path.startsWith('chat/')) {
      final chatId = path.substring(5);
      return DeepLinkData(
        type: DeepLinkType.chat,
        chatId: chatId,
      );
    }
    
    // xibechat://settings - Open settings
    if (path == 'settings') {
      return DeepLinkData(type: DeepLinkType.settings);
    }
    
    // xibechat://donate - Open donate screen
    if (path == 'donate') {
      return DeepLinkData(type: DeepLinkType.donate);
    }
    
    // xibechat://new - Create new chat
    if (path == 'new' || path.isEmpty) {
      return DeepLinkData(type: DeepLinkType.newChat);
    }
    
    return null;
  }

  DeepLinkData? _parseHttpScheme(Uri uri) {
    // Check for query parameters first (more user-friendly for website buttons)
    final messageParam = uri.queryParameters['message'];
    final textParam = uri.queryParameters['text'];
    final promptParam = uri.queryParameters['prompt'];
    final message = messageParam ?? textParam ?? promptParam;
    
    // https://chat.xibe.app/app/mes/{prompt} - Path-based message
    if (uri.pathSegments.length >= 3 && 
        uri.pathSegments[0] == 'app' && 
        uri.pathSegments[1] == 'mes') {
      final prompt = Uri.decodeComponent(uri.pathSegments.sublist(2).join('/'));
      return DeepLinkData(
        type: DeepLinkType.message,
        messagePrompt: prompt,
      );
    }
    
    // https://chat.xibe.app/app/new?message=text - Query-based message (preferred for buttons)
    if (uri.pathSegments.length >= 1 && uri.pathSegments[0] == 'app') {
      if ((uri.pathSegments.length == 1 || 
          (uri.pathSegments.length >= 2 && uri.pathSegments[1] == 'new')) &&
          message != null && message.isNotEmpty) {
        return DeepLinkData(
          type: DeepLinkType.message,
          messagePrompt: Uri.decodeComponent(message),
        );
      }
    }
    
    // https://chat.xibe.app/app/chat/{chatId}
    if (uri.pathSegments.length >= 3 && 
        uri.pathSegments[0] == 'app' && 
        uri.pathSegments[1] == 'chat') {
      final chatId = uri.pathSegments[2];
      return DeepLinkData(
        type: DeepLinkType.chat,
        chatId: chatId,
      );
    }
    
    // https://chat.xibe.app/app/settings
    if (uri.pathSegments.length >= 2 && 
        uri.pathSegments[0] == 'app' && 
        uri.pathSegments[1] == 'settings') {
      return DeepLinkData(type: DeepLinkType.settings);
    }
    
    // https://chat.xibe.app/app/donate
    if (uri.pathSegments.length >= 2 && 
        uri.pathSegments[0] == 'app' && 
        uri.pathSegments[1] == 'donate') {
      return DeepLinkData(type: DeepLinkType.donate);
    }
    
    // https://chat.xibe.app/app/new or https://chat.xibe.app/app
    if (uri.pathSegments.length >= 1 && uri.pathSegments[0] == 'app') {
      if (uri.pathSegments.length == 1 || 
          (uri.pathSegments.length >= 2 && uri.pathSegments[1] == 'new')) {
        return DeepLinkData(type: DeepLinkType.newChat);
      }
    }
    
    return null;
  }

  /// Dispose of resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}

enum DeepLinkType {
  newChat,
  chat,
  message,
  settings,
  donate,
  googleOAuthCallback,
}

class DeepLinkData {
  final DeepLinkType type;
  final String? chatId;
  final String? messagePrompt;
  final Map<String, String>? oauthParams;

  DeepLinkData({
    required this.type,
    this.chatId,
    this.messagePrompt,
    this.oauthParams,
  });

  @override
  String toString() {
    return 'DeepLinkData(type: $type, chatId: $chatId, messagePrompt: $messagePrompt, oauthParams: $oauthParams)';
  }
}
