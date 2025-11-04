import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ChatInput extends StatefulWidget {
  final Function(String, {String? imageBase64, String? imagePath, bool webSearch, bool reasoning}) onSendMessage;
  final bool isLoading;
  final bool supportsVision;
  final String? initialText;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.supportsVision = false,
    this.initialText,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardListenerFocusNode = FocusNode();
  bool _hasText = false;
  XFile? _selectedImage;
  String? _imageBase64;
  bool _webSearchEnabled = false;
  bool _reasoningEnabled = false;
  
  bool get _isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  void initState() {
    super.initState();
    // Set initial text if provided
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _controller.text = widget.initialText!;
      _hasText = true;
    }
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _keyboardListenerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Read the image file and convert to base64
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Read the image file and convert to base64
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take photo: $e')),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Reasoning Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'AI Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _reasoningEnabled 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: _reasoningEnabled ? const Color(0xFF10B981) : Colors.grey,
                  ),
                ),
                title: const Text('Think Mode'),
                subtitle: Text(
                  _reasoningEnabled 
                      ? 'Enabled - AI will show reasoning process'
                      : 'Disabled - Enable for deeper reasoning',
                ),
                trailing: Switch(
                  value: _reasoningEnabled,
                  onChanged: (value) {
                    setState(() {
                      _reasoningEnabled = value;
                      if (value) {
                        _webSearchEnabled = false; // Disable web search when thinking is enabled
                      }
                    });
                    Navigator.pop(context);
                  },
                  activeThumbColor: const Color(0xFF10B981),
                ),
                onTap: () {
                  setState(() {
                    _reasoningEnabled = !_reasoningEnabled;
                    if (_reasoningEnabled) {
                      _webSearchEnabled = false; // Disable web search when thinking is enabled
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _webSearchEnabled 
                        ? const Color(0xFF3B82F6).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language,
                    color: _webSearchEnabled ? const Color(0xFF3B82F6) : Colors.grey,
                  ),
                ),
                title: const Text('Web Search'),
                subtitle: Text(
                  _webSearchEnabled 
                      ? 'Enabled - AI will search the web for current information'
                      : 'Disabled - Enable to search the web',
                ),
                trailing: Switch(
                  value: _webSearchEnabled,
                  onChanged: (value) {
                    setState(() {
                      _webSearchEnabled = value;
                      if (value) {
                        _reasoningEnabled = false; // Disable thinking when web search is enabled
                      }
                    });
                    Navigator.pop(context);
                  },
                  activeThumbColor: const Color(0xFF3B82F6),
                ),
                onTap: () {
                  setState(() {
                    _webSearchEnabled = !_webSearchEnabled;
                    if (_webSearchEnabled) {
                      _reasoningEnabled = false; // Disable thinking when web search is enabled
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              if (widget.supportsVision) ...[
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Image Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  title: const Text('Choose from gallery'),
                  subtitle: const Text('Pick an image from your device'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  title: const Text('Take a photo'),
                  subtitle: const Text('Capture using camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                const Divider(height: 16),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MCP Connections',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dns_outlined,
                    color: Colors.purple,
                  ),
                ),
                title: const Text('Manage MCP Servers'),
                subtitle: const Text('Configure Model Context Protocol servers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/mcp-servers');
                },
              ),
              const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageBase64 = null;
    });
  }

  void _sendMessage() {
    if ((_hasText || _selectedImage != null) && !widget.isLoading) {
      widget.onSendMessage(
        _controller.text.trim(),
        imageBase64: _imageBase64,
        imagePath: _selectedImage?.path,
        webSearch: _webSearchEnabled,
        reasoning: _reasoningEnabled,
      );
      _controller.clear();
      setState(() {
        _selectedImage = null;
        _imageBase64 = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 32 : 20,
        vertical: isWideScreen ? 24 : 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reasoning mode indicator with animation
            if (_reasoningEnabled)
              TweenAnimationBuilder(
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
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Think Mode Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _reasoningEnabled = false;
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Web search mode indicator with animation
            if (_webSearchEnabled)
              TweenAnimationBuilder(
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
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Web Search Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _webSearchEnabled = false;
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Image preview with animation
            if (_selectedImage != null)
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 200),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.9 + (0.1 * value),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Image attached',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: _removeImage,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Remove image',
                      ),
                    ],
                  ),
                ),
              ),
            // Input row
            Row(
              children: [
                // Plus button for attachments and MCP connections
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isLoading ? null : _showAttachmentOptions,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A0A0A),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: widget.isLoading ? Colors.grey.withOpacity(0.5) : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Web search toggle button - commented out as per requirement
                // Container(
                //   margin: const EdgeInsets.only(right: 8),
                //   decoration: BoxDecoration(
                //     color: _webSearchEnabled 
                //         ? const Color(0xFF3B82F6).withOpacity(0.3)
                //         : const Color(0xFF1A1A1A),
                //     shape: BoxShape.circle,
                //   ),
                //   child: IconButton(
                //     icon: Icon(
                //       Icons.search,
                //       color: _webSearchEnabled 
                //           ? const Color(0xFF3B82F6)
                //           : Colors.white70,
                //     ),
                //     onPressed: widget.isLoading ? null : () {
                //       setState(() {
                //         _webSearchEnabled = !_webSearchEnabled;
                //       });
                //     },
                //     tooltip: _webSearchEnabled 
                //         ? 'Web search enabled' 
                //         : 'Enable web search',
                //   ),
                // ),
                Expanded(
                  child: KeyboardListener(
                    focusNode: _keyboardListenerFocusNode,
                    onKeyEvent: (KeyEvent event) {
                      // On desktop: Enter sends, Shift+Enter or Ctrl+Enter adds new line
                      if (_isDesktop && event is KeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          // If no modifier keys, send message
                          if (!HardwareKeyboard.instance.isShiftPressed && 
                              !HardwareKeyboard.instance.isControlPressed) {
                            _sendMessage();
                          }
                          // Otherwise allow default behavior (new line)
                        }
                      }
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !widget.isLoading,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: _isDesktop ? TextInputAction.newline : TextInputAction.send,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0A0A0A),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 24 : 20,
                          vertical: isWideScreen ? 18 : 16,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                      onSubmitted: (_) {
                        if (!_isDesktop) {
                          _sendMessage();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (_hasText || _selectedImage != null) && !widget.isLoading ? _sendMessage : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (_hasText || _selectedImage != null) && !widget.isLoading
                            ? theme.colorScheme.primary
                            : const Color(0xFF0A0A0A),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                        color: (_hasText || _selectedImage != null) && !widget.isLoading
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
