import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/mcp_servers_screen.dart';
import 'screens/memory_screen.dart';
import 'screens/ai_profiles_screen.dart';
import 'screens/splash_screen.dart';
import 'services/mcp_config_service.dart';
import 'services/update_service.dart';
import 'widgets/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MCP configuration with defaults
  final mcpConfigService = McpConfigService();
  await mcpConfigService.initializeDefaultConfig();
  
  // Configure window for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    
    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Color(0xFF0D0D0D),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Xibe Chat',
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  runApp(const XibeChatApp());
}

class XibeChatApp extends StatelessWidget {
  const XibeChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, ChatProvider>(
          create: (_) => ChatProvider(apiKey: null, systemPrompt: null),
          update: (_, settings, previous) {
            if (previous != null) {
              previous.updateApiKey(settings.apiKey);
              previous.updateSystemPrompt(settings.getCombinedSystemPrompt());
              return previous;
            }
            return ChatProvider(
              apiKey: settings.apiKey,
              systemPrompt: settings.getCombinedSystemPrompt(),
            );
          },
        ),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, child) {
          // Connect memory context getter and memory extraction callback to chat provider
          final chatProvider = Provider.of<ChatProvider>(context, listen: false);
          chatProvider.setMemoryContextGetter(() => settingsProvider.getMemoriesContext());
          chatProvider.setOnMemoryExtracted((memory) async {
            // Check if adding this memory would exceed the limit
            final currentTotal = settingsProvider.getTotalMemoryCharacters();
            if (currentTotal + memory.length <= SettingsProvider.maxTotalMemoryCharacters) {
              await settingsProvider.addMemory(memory);
            }
          });
          
          return MaterialApp(
            key: const ValueKey('xibe_chat_app'),
            title: 'Xibe Chat',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const SplashWrapper(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/mcp-servers': (context) => const McpServersScreen(),
              '/memory': (context) => const MemoryScreen(),
              '/ai-profiles': (context) => const AiProfilesScreen(),
            },
            onUnknownRoute: (settings) {
              // Handle unknown routes - always return to home
              return MaterialPageRoute(
                builder: (_) => const SplashWrapper(),
              );
            },
          );
        },
      ),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Check for updates after the splash screen is shown
    _checkForUpdatesAfterDelay();
  }

  Future<void> _checkForUpdatesAfterDelay() async {
    // Wait for splash screen to complete
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final updateService = UpdateService();
      final updateInfo = await updateService.checkForUpdate();
      
      if (!mounted) return;
      
      if (updateInfo['available'] == true) {
        // Show update dialog
        showUpdateDialog(context, updateInfo, updateService);
      }
    } catch (e) {
      // Silently fail - don't interrupt user experience
      debugPrint('Update check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onAnimationComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }
    return const ChatScreen();
  }
}
