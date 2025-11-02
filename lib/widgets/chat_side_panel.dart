import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat.dart';
import '../providers/chat_provider.dart';

class ChatSidePanel extends StatelessWidget {
  final Chat chat;
  final VoidCallback onClose;

  const ChatSidePanel({
    super.key,
    required this.chat,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onClose, // Close when tapping outside
        child: Container(
          color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on panel
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF343541), // Dark grey background
                  borderRadius: BorderRadius.circular(12),
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildOption(
                    context: context,
                    icon: Icons.edit_outlined,
                    label: 'Rename',
                    onTap: () {
                      onClose();
                      _showRenameDialog(context);
                    },
                  ),
                  // _buildOption(
                  //   context: context,
                  //   icon: Icons.folder_outlined,
                  //   label: 'Add to project',
                  //   onTap: () {
                  //     onClose();
                  //     _showAddToProjectDialog(context);
                  //   },
                  // ),
                  // _buildOption(
                  //   context: context,
                  //   icon: Icons.archive_outlined,
                  //   label: 'Archive',
                  //   onTap: () {
                  //     onClose();
                  //     _archiveChat(context);
                  //   },
                  // ),
                  _buildOption(
                    context: context,
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    isDestructive: true,
                    onTap: () {
                      onClose();
                      _showDeleteDialog(context);
                    },
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDestructive ? Colors.red : Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final textController = TextEditingController(text: chat.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF343541),
        title: const Text(
          'Rename Chat',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF565869)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF10A37F)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              final newTitle = textController.text.trim();
              if (newTitle.isNotEmpty && newTitle != chat.title) {
                Provider.of<ChatProvider>(context, listen: false)
                    .renameChat(chat.id!, newTitle);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Rename',
              style: TextStyle(color: Color(0xFF10A37F)),
            ),
          ),
        ],
      ),
    );
  }

  // void _showAddToProjectDialog(BuildContext context) {
  //   // TODO: Implement project functionality
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Add to project feature coming soon'),
  //       backgroundColor: Color(0xFF343541),
  //       duration: Duration(seconds: 2),
  //     ),
  //   );
  // }

  // void _archiveChat(BuildContext context) {
  //   // TODO: Implement archive functionality
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Archive feature coming soon'),
  //       backgroundColor: Color(0xFF343541),
  //       duration: Duration(seconds: 2),
  //     ),
  //   );
  // }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF343541),
        title: const Text(
          'Delete Chat',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this chat?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false)
                  .deleteChat(chat.id!);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
