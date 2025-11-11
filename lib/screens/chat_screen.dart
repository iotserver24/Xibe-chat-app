import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/model_selector.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  bool _isStreaming = false;
  int? _lastChatId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  bool get _isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    // On desktop, use a side-by-side layout if screen is wide enough
    final screenWidth = MediaQuery.of(context).size.width;
    final useDesktopLayout = _isDesktop && screenWidth > 800;

    if (useDesktopLayout) {
      return _buildDesktopLayout(context);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chatProvider.currentChat?.title ?? 'Xibe Chat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (chatProvider.selectedModel.isNotEmpty)
                  Text(
                    chatProvider.selectedModel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
              ],
            );
          },
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          const ModelSelector(),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.currentChat == null) {
                return IconButton(
                  icon: const Icon(Icons.add_rounded,
                      color: Color(0xFF9AA0A6), size: 22),
                  onPressed: () {
                    final settingsProvider =
                        Provider.of<SettingsProvider>(context, listen: false);
                    chatProvider.createNewChat(
                        defaultModel: settingsProvider.defaultModel);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: const ChatDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.currentChat == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.12),
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.04),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No chat selected',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Select a chat or create a new one',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    final settingsProvider =
                                        Provider.of<SettingsProvider>(context,
                                            listen: false);
                                    chatProvider.createNewChat(
                                        defaultModel:
                                            settingsProvider.defaultModel);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Start New Chat',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Reset tracking if chat changed
                  final currentChatId = chatProvider.currentChat?.id;
                  if (currentChatId != _lastChatId) {
                    _lastChatId = currentChatId;
                    _lastMessageCount = chatProvider.messages.length;
                    _isStreaming = chatProvider.isStreaming;
                  }
                  
                  // Only scroll to bottom when:
                  // 1. New message is added (message count increased)
                  // 2. Streaming is active (user is typing)
                  // 3. Loading state changes (typing indicator appears)
                  final currentMessageCount = chatProvider.messages.length;
                  final currentlyStreaming = chatProvider.isStreaming;
                  final shouldScroll = currentMessageCount > _lastMessageCount ||
                      currentlyStreaming != _isStreaming ||
                      (chatProvider.isLoading && !currentlyStreaming);
                  
                  if (shouldScroll) {
                    _lastMessageCount = currentMessageCount;
                    _isStreaming = currentlyStreaming;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                  }

                  // Show greeting for new chats (no messages yet)
                  // Always show greeting when we have a chat but no messages
                  final shouldShowGreeting = chatProvider.currentChat != null &&
                      chatProvider.messages.isEmpty;
                  final itemCount = (shouldShowGreeting ? 1 : 0) +
                      chatProvider.messages.length +
                      (chatProvider.isStreaming ? 1 : 0) +
                      (chatProvider.isLoading && !chatProvider.isStreaming
                          ? 1
                          : 0);

                  // Ensure we always show at least 1 item if we have a chat (the greeting)
                  final finalItemCount =
                      chatProvider.currentChat != null && itemCount == 0
                          ? 1
                          : itemCount;

                  // If only showing greeting, center it vertically
                  if (chatProvider.currentChat != null &&
                      chatProvider.messages.isEmpty &&
                      finalItemCount == 1) {
                    return Center(
                      child: TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.12),
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.15),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 40,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.8),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  chatProvider.getGreeting(),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.9),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  chatProvider.getGreetingSubtitle(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        cacheExtent: 500, // Cache 500 pixels worth of items for better performance
                        itemCount: finalItemCount,
                        itemBuilder: (context, index) {

                          final messageIndex =
                              shouldShowGreeting ? index - 1 : index;

                          // Show streaming message
                          if (chatProvider.isStreaming &&
                              messageIndex == chatProvider.messages.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: MessageBubble(
                                message: Message(
                                  role: 'assistant',
                                  content: chatProvider.streamingContent,
                                  timestamp: DateTime.now(),
                                  chatId: chatProvider.currentChat!.id!,
                                ),
                                isStreaming: true,
                              ),
                            );
                          }

                          // Show typing indicator
                          if (chatProvider.isLoading &&
                              !chatProvider.isStreaming &&
                              messageIndex == chatProvider.messages.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: TypingIndicator(),
                            );
                          }

                          // Show normal message
                          final message = chatProvider.messages[messageIndex];
                          final messageWidget = MessageBubble(
                            key: ValueKey('message_${message.id}'),
                            message: message,
                          );
                          
                          // Only animate messages that are newly added (last 2 messages)
                          // This prevents animation restart when existing messages are updated (e.g., image generation completes)
                          final shouldAnimate = messageIndex >= chatProvider.messages.length - 2;
                          
                          if (shouldAnimate) {
                          return TweenAnimationBuilder(
                              key: ValueKey('anim_${message.id}'),
                            duration: const Duration(milliseconds: 400),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 15 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                              child: messageWidget,
                          );
                          } else {
                            // For existing messages, just show without animation to prevent jumping
                            return messageWidget;
                          }
                        },
                      ),
                      if (chatProvider.error != null)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Error',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        chatProvider.error!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    chatProvider.clearError();
                                  },
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              // Get pending prompt and clear it
              final pendingPrompt = chatProvider.pendingPrompt;
              if (pendingPrompt != null) {
                // Clear it after reading to avoid reusing
                Future.microtask(() => chatProvider.clearPendingPrompt());
              }

              return ChatInput(
                onSendMessage: (message,
                    {String? imageBase64,
                    String? imagePath,
                    bool webSearch = false,
                    bool reasoning = false,
                    bool imageGeneration = false}) {
                  final settingsProvider =
                      Provider.of<SettingsProvider>(context, listen: false);
                  chatProvider.sendMessage(
                    message,
                    imageBase64: imageBase64,
                    imagePath: imagePath,
                    webSearch: webSearch,
                    reasoning: reasoning,
                    imageGeneration: imageGeneration,
                    imageGenerationModel: settingsProvider.imageGenerationModel,
                  );
                },
                isLoading: chatProvider.isLoading,
                supportsVision: chatProvider.selectedModelSupportsVision,
                initialText: pendingPrompt,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
      BuildContext context, String label, VoidCallback onTap) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar with chat list - always visible on desktop
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: const ChatDrawer(),
          ),
          // Main chat area
          Expanded(
            child: Column(
              children: [
                // Modern header with gradient
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A0A0A),
                        const Color(0xFF0A0A0A).withOpacity(0.95),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      Expanded(
                        child: Consumer<ChatProvider>(
                          builder: (context, chatProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.2),
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        chatProvider.currentChat?.title ??
                                            'New Chat',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFE8EAED),
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (chatProvider.selectedModel.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        chatProvider.selectedModel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFF8A8A8A),
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                      // Model selection
                      const ModelSelector(),
                      const SizedBox(width: 8),
                      // New chat button
                      Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          if (chatProvider.currentChat == null) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    final settingsProvider =
                                        Provider.of<SettingsProvider>(context,
                                            listen: false);
                                    await chatProvider.createNewChat(
                                        defaultModel:
                                            settingsProvider.defaultModel);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'New Chat',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Settings
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.settings_outlined,
                                color: Colors.white70, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                // Chat messages with gradient background
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0A0A0A),
                          const Color(0xFF0D0D0D),
                          const Color(0xFF0A0A0A),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        if (chatProvider.currentChat == null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.15),
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No chat selected',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Select a chat from the sidebar or create a new one',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          final settingsProvider =
                                              Provider.of<SettingsProvider>(
                                                  context,
                                                  listen: false);
                                          await chatProvider.createNewChat(
                                              defaultModel:
                                                  settingsProvider.defaultModel);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 14),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add,
                                                  color: Colors.white, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Start New Chat',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Reset tracking if chat changed
                        final currentChatId = chatProvider.currentChat?.id;
                        if (currentChatId != _lastChatId) {
                          _lastChatId = currentChatId;
                          _lastMessageCount = chatProvider.messages.length;
                          _isStreaming = chatProvider.isStreaming;
                        }
                        
                        // Only scroll to bottom when:
                        // 1. New message is added (message count increased)
                        // 2. Streaming is active (user is typing)
                        // 3. Loading state changes (typing indicator appears)
                        final currentMessageCount = chatProvider.messages.length;
                        final currentlyStreaming = chatProvider.isStreaming;
                        final shouldScroll = currentMessageCount > _lastMessageCount ||
                            currentlyStreaming != _isStreaming ||
                            (chatProvider.isLoading && !currentlyStreaming);
                        
                        if (shouldScroll) {
                          _lastMessageCount = currentMessageCount;
                          _isStreaming = currentlyStreaming;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                        }

                        // Show greeting for new chats (no messages yet)
                        // Always show greeting when we have a chat but no messages
                        final hasCurrentChat = chatProvider.currentChat != null;
                        final hasNoMessages = chatProvider.messages.isEmpty;
                        final shouldShowGreeting =
                            hasCurrentChat && hasNoMessages;

                        final itemCount = (shouldShowGreeting ? 1 : 0) +
                            chatProvider.messages.length +
                            (chatProvider.isStreaming ? 1 : 0) +
                            (chatProvider.isLoading && !chatProvider.isStreaming
                                ? 1
                                : 0);

                        // Ensure we always show at least 1 item if we have a chat (the greeting)
                        final finalItemCount =
                            hasCurrentChat && itemCount == 0 ? 1 : itemCount;

                        // If we have a chat but itemCount is still 0, force show greeting
                        if (hasCurrentChat && finalItemCount == 0) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chatProvider.getGreeting(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'How can I help you today?',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Try asking me about:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildSuggestionChip(
                                        context,
                                        '💡 Explain a concept',
                                        () => chatProvider.sendMessage(
                                            'Explain quantum computing in simple terms'),
                                      ),
                                      _buildSuggestionChip(
                                        context,
                                        '✍️ Write something',
                                        () => chatProvider.sendMessage(
                                            'Write a creative short story'),
                                      ),
                                      _buildSuggestionChip(
                                        context,
                                        '🔍 Research help',
                                        () => chatProvider.sendMessage(
                                            'Help me research renewable energy'),
                                      ),
                                      _buildSuggestionChip(
                                        context,
                                        '💻 Code assistance',
                                        () => chatProvider.sendMessage(
                                            'Help me debug my Python code'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // If only showing greeting, center it vertically
                        if (hasCurrentChat && hasNoMessages && finalItemCount == 1) {
                          return Center(
                            child: TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutCubic,
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.15),
                                        Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 48,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.8),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        chatProvider.getGreeting(),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        chatProvider.getGreetingSubtitle(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          key: ValueKey(
                              'chat_${chatProvider.currentChat?.id ?? 'none'}_${chatProvider.messages.length}'),
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          cacheExtent: 500, // Cache 500 pixels worth of items for better performance
                          itemCount: finalItemCount,
                          itemBuilder: (context, index) {

                            final messageIndex =
                                shouldShowGreeting ? index - 1 : index;

                            if (chatProvider.isStreaming &&
                                messageIndex == chatProvider.messages.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: MessageBubble(
                                  message: Message(
                                    role: 'assistant',
                                    content: chatProvider.streamingContent,
                                    timestamp: DateTime.now(),
                                    webSearchUsed: false,
                                    chatId: chatProvider.currentChat?.id ?? 0,
                                  ),
                                ),
                              );
                            }

                            if (chatProvider.isLoading &&
                                !chatProvider.isStreaming &&
                                messageIndex == chatProvider.messages.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: TypingIndicator(),
                              );
                            }

                            // Safety check to prevent index out of bounds
                            if (messageIndex >= 0 &&
                                messageIndex < chatProvider.messages.length) {
                              final message =
                                  chatProvider.messages[messageIndex];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: MessageBubble(message: message),
                              );
                            }

                            // Fallback - shouldn't reach here, but just in case
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Input area
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    // Get pending prompt and clear it
                    final pendingPrompt = chatProvider.pendingPrompt;
                    if (pendingPrompt != null) {
                      // Clear it after reading to avoid reusing
                      Future.microtask(() => chatProvider.clearPendingPrompt());
                    }

                    return ChatInput(
                      onSendMessage: (message,
                          {String? imageBase64,
                          String? imagePath,
                          bool webSearch = false,
                          bool reasoning = false,
                          bool imageGeneration = false}) {
                        final settingsProvider = Provider.of<SettingsProvider>(
                            context,
                            listen: false);
                        chatProvider.sendMessage(
                          message,
                          imageBase64: imageBase64,
                          imagePath: imagePath,
                          webSearch: webSearch,
                          reasoning: reasoning,
                          imageGeneration: imageGeneration,
                          imageGenerationModel:
                              settingsProvider.imageGenerationModel,
                        );
                      },
                      isLoading: chatProvider.isLoading,
                      supportsVision: chatProvider.selectedModelSupportsVision,
                      initialText: pendingPrompt,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
