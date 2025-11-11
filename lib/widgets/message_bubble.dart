import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import 'code_block.dart';
import 'donate_button.dart';

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
  Uint8List? _cachedImageBytes; // Cache decoded image bytes to avoid re-decoding

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
    
    // Pre-decode image if present to cache it
    if (widget.message.generatedImageBase64 != null &&
        widget.message.generatedImageBase64!.isNotEmpty) {
      _cachedImageBytes = base64Decode(widget.message.generatedImageBase64!);
    }
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-decode if the image actually changed
    if (widget.message.generatedImageBase64 != oldWidget.message.generatedImageBase64) {
      if (widget.message.generatedImageBase64 != null &&
          widget.message.generatedImageBase64!.isNotEmpty) {
        _cachedImageBytes = base64Decode(widget.message.generatedImageBase64!);
      } else {
        _cachedImageBytes = null;
      }
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _cachedImageBytes = null; // Clear cache on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    final timeFormat = DateFormat('HH:mm');
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 48 : 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              )
            : null,
        border: isUser
            ? Border(
                top: BorderSide(
                    color: Colors.white.withOpacity(0.06), width: 1),
                bottom: BorderSide(
                    color: Colors.white.withOpacity(0.06), width: 1),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 800 ? 24 : 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Web search badge
            if (widget.message.webSearchUsed) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 12),
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
                    const Icon(Icons.language,
                        size: 12, color: Color(0xFF10B981)),
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
            if (!isUser &&
                widget.message.thinkingContent != null &&
                widget.message.thinkingContent!.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
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
                        const Icon(Icons.psychology,
                            size: 14, color: Color(0xFF60A5FA)),
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
              if (widget.message.imagePath != null &&
                  widget.message.imagePath!.isNotEmpty) ...[
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
                            Icon(Icons.broken_image,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 6),
                            Text('Image unavailable',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.message.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ] else ...[
              MarkdownBody(
                data: widget.message.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                      color: const Color(0xFFE8EAED),
                      fontSize: 15,
                      height: 1.7,
                      letterSpacing: 0.1),
                  h1: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4),
                  h2: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.4),
                  h3: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.4),
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
                  'code': CodeBlockBuilder(isStreaming: widget.isStreaming),
                },
                extensionSet: md.ExtensionSet.gitHubFlavored,
              ),
              // Generated image display or loading animation
              // Show image if we have base64 data, or if we're generating
              if (widget.message.isGeneratingImage ||
                  (widget.message.generatedImageBase64 != null &&
                      widget.message.generatedImageBase64!.isNotEmpty)) ...[
                const SizedBox(height: 20),
                // Use stable condition to prevent flickering when state changes
                widget.message.isGeneratingImage
                    ? _buildImageLoadingAnimation(context)
                    : (widget.message.generatedImageBase64 != null &&
                            widget.message.generatedImageBase64!.isNotEmpty)
                        ? _buildGeneratedImage(context)
                        : const SizedBox.shrink(),
                const SizedBox(height: 16),
              ],
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
              // Donation prompt button
              if (widget.message.showDonationPrompt && !widget.isStreaming)
                const DonateButton(),
            ],
            // Footer with time, response time, reactions, and copy
            const SizedBox(height: 12),
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
                        isUser
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                  )
                else ...[
                  Text(
                    timeFormat.format(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // Show response time for assistant messages
                  if (!isUser && widget.message.responseTimeMs != null) ...[
                    const SizedBox(width: 8),
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
                  const SizedBox(width: 12),
                  // Reactions for assistant messages
                  if (!isUser && widget.message.id != null) ...[
                    _buildReactionButton(
                      context: context,
                      isSelected: widget.message.reaction == 'thumbs_up',
                      icon: Icons.thumb_up_outlined,
                      selectedIcon: Icons.thumb_up,
                      onTap: () => _handleReaction(context, 'thumbs_up'),
                    ),
                    const SizedBox(width: 8),
                    _buildReactionButton(
                      context: context,
                      isSelected: widget.message.reaction == 'thumbs_down',
                      icon: Icons.thumb_down_outlined,
                      selectedIcon: Icons.thumb_down,
                      onTap: () => _handleReaction(context, 'thumbs_down'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.message.content));
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
                      size: 16,
                      color: isUser
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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
          color:
              isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
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

  Widget _buildImageLoadingAnimation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEC4899).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loading animation box
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated spinner
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFFEC4899),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generating image...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.message.generatedImagePrompt != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.message.generatedImagePrompt!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Metadata section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                if (widget.message.generatedImageModel != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.message.generatedImageModel!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFEC4899),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedImage(BuildContext context) {
    // Use cached image bytes if available, otherwise decode (shouldn't happen)
    final imageBytes = _cachedImageBytes ?? 
        (widget.message.generatedImageBase64 != null 
            ? base64Decode(widget.message.generatedImageBase64!) 
            : Uint8List(0));

    if (imageBytes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey('generated_image_${widget.message.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFEC4899).withOpacity(0.6),
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview - use RepaintBoundary to prevent unnecessary repaints
          RepaintBoundary(
            child: GestureDetector(
            onTap: () => _showFullscreenImage(context, imageBytes),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              child: Stack(
                children: [
                  Image.memory(
                      key: ValueKey('image_memory_${widget.message.id}'),
                    imageBytes,
                    width: double.infinity,
                    fit: BoxFit.cover,
                      gaplessPlayback: true, // Prevent flicker when image updates
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.black.withOpacity(0.3),
                        child: const Row(
                          children: [
                            Icon(Icons.broken_image,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 6),
                            Text('Image unavailable',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                  // Fullscreen indicator overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
          // Image metadata and actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prompt
                if (widget.message.generatedImagePrompt != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: Color(0xFFEC4899),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.message.generatedImagePrompt!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                // Actions row
                Row(
                  children: [
                    // Model info
                    if (widget.message.generatedImageModel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.message.generatedImageModel!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFEC4899),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    // Download button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _downloadImage(context, imageBytes),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFEC4899).withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download,
                                size: 16,
                                color: Color(0xFFEC4899),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Download',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFEC4899),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Image
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            // Download button
            Positioned(
              top: 40,
              left: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _downloadImage(context, imageBytes),
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 24,
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

  Future<void> _downloadImage(
      BuildContext context, Uint8List imageBytes) async {
    try {
      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        directory = await getDownloadsDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not find download directory');
      }

      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'xibe_generated_image_$timestamp.png';
      final filePath = '${directory.path}/$filename';

      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to: $filePath'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1F1F1F),
            action: SnackBarAction(
              label: 'OK',
              textColor: const Color(0xFFEC4899),
              onPressed: () {},
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1F1F1F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}

// Custom markdown builder for code blocks
class CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isStreaming;

  CodeBlockBuilder({this.isStreaming = false});

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
      isStreaming: isStreaming,
    );
  }
}
