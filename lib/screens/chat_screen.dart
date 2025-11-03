import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

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
        backgroundColor: Colors.black,
        elevation: 0,
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chatProvider.currentChat?.title ?? 'Xibe Chat',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE8EAED),
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
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                tooltip: 'Select AI Model',
                onSelected: (String model) {
                  chatProvider.setSelectedModel(model);
                },
                itemBuilder: (BuildContext context) {
                  if (chatProvider.availableModels.isEmpty) {
                    return const [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text('Loading models...'),
                      ),
                    ];
                  }
                  return chatProvider.availableModels.map((model) {
                    final isSelected = chatProvider.selectedModel == model.name;
                    return PopupMenuItem<String>(
                      value: model.name,
                      child: Row(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check, size: 16, color: Colors.green),
                          if (isSelected) const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  model.description,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              );
            },
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.currentChat == null) {
                return IconButton(
                  icon: const Icon(Icons.add_rounded, color: Color(0xFF9AA0A6), size: 22),
                  onPressed: () {
                    chatProvider.createNewChat();
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
              color: const Color(0xFF0D1521),
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.currentChat == null) {
                    return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No chat selected',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            chatProvider.createNewChat();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                          ),
                          child: const Text(
                            'Start New Chat',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                // Show greeting for new chats (no messages yet)
                // Always show greeting when we have a chat but no messages
                final shouldShowGreeting = chatProvider.currentChat != null && 
                                         chatProvider.messages.isEmpty;
                final itemCount = (shouldShowGreeting ? 1 : 0) +
                    chatProvider.messages.length +
                    (chatProvider.isStreaming ? 1 : 0) +
                    (chatProvider.isLoading && !chatProvider.isStreaming ? 1 : 0);

                // Ensure we always show at least 1 item if we have a chat (the greeting)
                final finalItemCount = chatProvider.currentChat != null && itemCount == 0 ? 1 : itemCount;

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: finalItemCount,
                      itemBuilder: (context, index) {
                        // Show greeting at the top for new chats (when no messages and chat exists)
                        if (chatProvider.currentChat != null && 
                            chatProvider.messages.isEmpty && 
                            index == 0) {
                          return TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                             child: Center(
                               child: Text(
                                 'Ready when you are.',
                                 style: TextStyle(
                                   fontSize: 24,
                                   fontWeight: FontWeight.w400,
                                   color: Colors.white.withOpacity(0.7),
                                 ),
                               ),
                             ),
                          );
                        }

                        final messageIndex = shouldShowGreeting ? index - 1 : index;
                        
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
                        return TweenAnimationBuilder(
                          key: ValueKey('${message.id}_${message.timestamp.millisecondsSinceEpoch}'),
                          duration: const Duration(milliseconds: 300),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: MessageBubble(
                            message: message,
                          ),
                        );
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                onSendMessage: (message, {String? imageBase64, String? imagePath, bool webSearch = false, bool reasoning = false}) {
                  chatProvider.sendMessage(
                    message,
                    imageBase64: imageBase64,
                    imagePath: imagePath,
                    webSearch: webSearch,
                    reasoning: reasoning,
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

  Widget _buildSuggestionChip(BuildContext context, String label, VoidCallback onTap) {
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
                // Browser-like header
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF1A1A1A),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Consumer<ChatProvider>(
                          builder: (context, chatProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  chatProvider.currentChat?.title ?? 'Xibe Chat',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFE8EAED),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (chatProvider.selectedModel.isNotEmpty)
                                  Text(
                                    chatProvider.selectedModel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8A8A8A),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Model selection
                      Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          return PopupMenuButton<String>(
                            icon: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                            tooltip: 'Select AI Model',
                            onSelected: (String model) {
                              chatProvider.setSelectedModel(model);
                            },
                            itemBuilder: (BuildContext context) {
                              if (chatProvider.availableModels.isEmpty) {
                                return [
                                  const PopupMenuItem<String>(
                                    enabled: false,
                                    child: Text('Loading models...'),
                                  ),
                                ];
                              }
                              return chatProvider.availableModels.map((model) {
                                final isSelected = model.name == chatProvider.selectedModel;
                                return PopupMenuItem<String>(
                                  value: model.name,
                                  child: Row(
                                    children: [
                                      if (isSelected)
                                        const Icon(Icons.check, size: 16)
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              model.name,
                                              style: TextStyle(
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                            Text(
                                              model.description,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                          );
                        },
                      ),
                      // New chat button
                      Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          if (chatProvider.currentChat == null) {
                            return IconButton(
                              icon: const Icon(Icons.add, color: Colors.white, size: 20),
                              onPressed: () async {
                                await chatProvider.createNewChat();
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Settings
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                // Chat messages
                Expanded(
                  child: Container(
                    color: const Color(0xFF0D1521),
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        if (chatProvider.currentChat == null) {
                          return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No chat selected',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  await chatProvider.createNewChat();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                ),
                                child: const Text(
                                  'Start New Chat',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      // Show greeting for new chats (no messages yet)
                      // Always show greeting when we have a chat but no messages
                      final hasCurrentChat = chatProvider.currentChat != null;
                      final hasNoMessages = chatProvider.messages.isEmpty;
                      final shouldShowGreeting = hasCurrentChat && hasNoMessages;
                      
                      final itemCount = (shouldShowGreeting ? 1 : 0) +
                          chatProvider.messages.length +
                          (chatProvider.isStreaming ? 1 : 0) +
                          (chatProvider.isLoading && !chatProvider.isStreaming ? 1 : 0);

                      // Ensure we always show at least 1 item if we have a chat (the greeting)
                      final finalItemCount = hasCurrentChat && itemCount == 0 ? 1 : itemCount;

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
                                        Theme.of(context).primaryColor.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      () => chatProvider.sendMessage('Explain quantum computing in simple terms'),
                                    ),
                                    _buildSuggestionChip(
                                      context,
                                      '✍️ Write something',
                                      () => chatProvider.sendMessage('Write a creative short story'),
                                    ),
                                    _buildSuggestionChip(
                                      context,
                                      '🔍 Research help',
                                      () => chatProvider.sendMessage('Help me research renewable energy'),
                                    ),
                                    _buildSuggestionChip(
                                      context,
                                      '💻 Code assistance',
                                      () => chatProvider.sendMessage('Help me debug my Python code'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        key: ValueKey('chat_${chatProvider.currentChat?.id ?? 'none'}_${chatProvider.messages.length}'),
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: finalItemCount,
                        itemBuilder: (context, index) {
                          // Show greeting at the top for new chats (when no messages and chat exists)
                          if (hasCurrentChat && hasNoMessages && index == 0) {
                            return Center(
                              child: Text(
                                'Ready when you are.',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            );
                          }

                          final messageIndex = shouldShowGreeting ? index - 1 : index;

                          if (chatProvider.isStreaming &&
                              messageIndex == chatProvider.messages.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                          if (messageIndex >= 0 && messageIndex < chatProvider.messages.length) {
                            final message = chatProvider.messages[messageIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                      onSendMessage: (message, {String? imageBase64, String? imagePath, bool webSearch = false, bool reasoning = false}) {
                        chatProvider.sendMessage(
                          message,
                          imageBase64: imageBase64,
                          imagePath: imagePath,
                          webSearch: webSearch,
                          reasoning: reasoning,
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
