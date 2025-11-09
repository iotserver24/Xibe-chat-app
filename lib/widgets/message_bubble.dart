import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import 'code_block.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    final timeFormat = DateFormat('HH:mm');
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 800 ? 680.0 : screenWidth * 0.85;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 40 : 20,
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF10A37F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
              child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF0A0A0A) : const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Web search badge
                  if (widget.message.webSearchUsed) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 12, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            'Web Search',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Thinking content
                  if (!isUser && widget.message.thinkingContent != null && widget.message.thinkingContent!.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology, size: 14, color: Color(0xFF60A5FA)),
                              const SizedBox(width: 6),
                              Text(
                                'Thinking',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFF60A5FA),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.message.thinkingContent!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Message content
                  if (isUser) ...[
                    if (widget.message.imagePath != null && widget.message.imagePath!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(widget.message.imagePath!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.black.withOpacity(0.3),
                              child: const Row(
                                children: [
                                  Icon(Icons.broken_image, color: Colors.white70, size: 16),
                                  SizedBox(width: 6),
                                  Text('Image unavailable', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      widget.message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ]
                  else ...[
                    MarkdownBody(
                      data: widget.message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: const Color(0xFFE8EAED), fontSize: 15, height: 1.7, letterSpacing: 0.1),
                        h1: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                        h2: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                        h3: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                        listBullet: TextStyle(color: Colors.white.withOpacity(0.9)),
                        tableBody: TextStyle(color: Colors.white.withOpacity(0.9)),
                        code: TextStyle(
                          backgroundColor: Colors.black.withOpacity(0.3),
                          color: const Color(0xFF34D399),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      builders: {
                        'code': CodeBlockBuilder(),
                      },
                      extensionSet: md.ExtensionSet.gitHubFlavored,
                    ),
                    if (widget.isStreaming)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AnimatedBuilder(
                          animation: _cursorController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _cursorController.value,
                              child: Container(
                                width: 2,
                                height: 16,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                  // Footer with time, response time, reactions, and copy
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isStreaming)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isUser ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.6),
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          timeFormat.format(widget.message.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isUser ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        // Show response time for assistant messages
                        if (!isUser && widget.message.responseTimeMs != null) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.speed,
                            size: 11,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${(widget.message.responseTimeMs! / 1000).toStringAsFixed(1)}s',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.4),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        // Reactions for assistant messages
                        if (!isUser && widget.message.id != null) ...[
                          _buildReactionButton(
                            context: context,
                            isSelected: widget.message.reaction == 'thumbs_up',
                            icon: Icons.thumb_up_outlined,
                            selectedIcon: Icons.thumb_up,
                            onTap: () => _handleReaction(context, 'thumbs_up'),
                          ),
                          const SizedBox(width: 4),
                          _buildReactionButton(
                            context: context,
                            isSelected: widget.message.reaction == 'thumbs_down',
                            icon: Icons.thumb_down_outlined,
                            selectedIcon: Icons.thumb_down,
                            onTap: () => _handleReaction(context, 'thumbs_down'),
                          ),
                          const SizedBox(width: 6),
                        ],
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: widget.message.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Copied to clipboard'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF1F1F1F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy_outlined,
                            size: 14,
                            color: isUser ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required BuildContext context,
    required bool isSelected,
    required IconData icon,
    required IconData selectedIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          isSelected ? selectedIcon : icon,
          size: 14,
          color: isSelected 
              ? const Color(0xFF10B981)
              : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  void _handleReaction(BuildContext context, String reaction) {
    if (widget.message.id == null) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final isCurrentlySelected = widget.message.reaction == reaction;
    final newReaction = isCurrentlySelected ? null : reaction;
    chatProvider.setMessageReaction(widget.message.id!, newReaction);
  }
}

// Custom markdown builder for code blocks
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent;
    
    // Extract language from info string if available
    String? language;
    if (element.attributes['class'] != null) {
      final classes = element.attributes['class']!.split(' ');
      for (var cls in classes) {
        if (cls.startsWith('language-')) {
          language = cls.substring(9); // Remove 'language-' prefix
          break;
        }
      }
    }

    return CodeBlock(
      code: textContent,
      language: language,
    );
  }
}
