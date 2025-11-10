import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/settings_screen.dart';
import '../models/chat.dart';
import 'chat_side_panel.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({super.key});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  Chat? _selectedChatForSidePanel;

  void _showSidePanel(Chat chat) {
    setState(() {
      _selectedChatForSidePanel = chat;
    });
  }

  void _hideSidePanel() {
    setState(() {
      _selectedChatForSidePanel = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth > 600 ? 320.0 : 280.0;

    return Stack(
      children: [
        SizedBox(
            width: drawerWidth,
            child: Drawer(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Xibe Chat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.more_vert,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 20),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            tooltip: 'Settings',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final chatProvider = Provider.of<ChatProvider>(
                                context,
                                listen: false);
                            final settingsProvider =
                                Provider.of<SettingsProvider>(context,
                                    listen: false);
                            await chatProvider.createNewChat(
                                defaultModel: settingsProvider.defaultModel);
                            if (context.mounted && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'New Chat',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chat History',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          if (chatProvider.chats.isEmpty) {
                            return const Center(
                              child: Text(
                                'No chats yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: chatProvider.chats.length,
                            itemBuilder: (context, index) {
                              final chat = chatProvider.chats[index];
                              final isSelected =
                                  chatProvider.currentChat?.id == chat.id;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          chat.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Color(0xFF9AA0A6),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _showSidePanel(chat);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  onTap: () {
                                    chatProvider.selectChat(chat);
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
        // Side panel overlay - positioned to cover drawer area
        if (_selectedChatForSidePanel != null)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: ChatSidePanel(
                chat: _selectedChatForSidePanel!,
                onClose: _hideSidePanel,
              ),
            ),
          ),
      ],
    );
  }
}
