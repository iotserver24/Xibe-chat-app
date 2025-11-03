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
    
    // Handle HTTP/HTTPS scheme: https://xibechat.app/app/...
    if ((uri.scheme == 'http' || uri.scheme == 'https') && 
        uri.host.contains('xibechat')) {
      return _parseHttpScheme(uri);
    }
    
    return null;
  }

  DeepLinkData? _parseCustomScheme(Uri uri) {
    final path = uri.host + uri.path;
    
    // xibechat://mes/{prompt} - Open with message
    if (path.startsWith('mes/')) {
      final prompt = Uri.decodeComponent(path.substring(4));
      return DeepLinkData(
        type: DeepLinkType.message,
        messagePrompt: prompt,
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
    
    // xibechat://new - Create new chat
    if (path == 'new' || path.isEmpty) {
      return DeepLinkData(type: DeepLinkType.newChat);
    }
    
    return null;
  }

  DeepLinkData? _parseHttpScheme(Uri uri) {
    // https://xibechat.app/app/mes/{prompt}
    if (uri.pathSegments.length >= 3 && 
        uri.pathSegments[0] == 'app' && 
        uri.pathSegments[1] == 'mes') {
      final prompt = Uri.decodeComponent(uri.pathSegments.sublist(2).join('/'));
      return DeepLinkData(
        type: DeepLinkType.message,
        messagePrompt: prompt,
      );
    }
    
    // https://xibechat.app/app/chat/{chatId}
    if (uri.pathSegments.length >= 3 && 
        uri.pathSegments[0] == 'app' && 
        uri.pathSegments[1] == 'chat') {
      final chatId = uri.pathSegments[2];
      return DeepLinkData(
        type: DeepLinkType.chat,
        chatId: chatId,
      );
    }
    
    // https://xibechat.app/app/settings
    if (uri.pathSegments.length >= 2 && 
        uri.pathSegments[0] == 'app' && 
        uri.pathSegments[1] == 'settings') {
      return DeepLinkData(type: DeepLinkType.settings);
    }
    
    // https://xibechat.app/app/new or https://xibechat.app/app
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
}

class DeepLinkData {
  final DeepLinkType type;
  final String? chatId;
  final String? messagePrompt;

  DeepLinkData({
    required this.type,
    this.chatId,
    this.messagePrompt,
  });

  @override
  String toString() {
    return 'DeepLinkData(type: $type, chatId: $chatId, messagePrompt: $messagePrompt)';
  }
}
