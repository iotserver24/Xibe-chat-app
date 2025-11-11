import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/mcp_servers_screen.dart';
import 'screens/memory_screen.dart';
import 'screens/ai_profiles_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/custom_providers_screen.dart';
import 'screens/auth_screen.dart';
import 'services/mcp_config_service.dart';
import 'services/update_service.dart';
import 'services/deep_link_service.dart';
import 'services/database_service.dart';
import 'services/cloud_sync_service.dart';
import 'widgets/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization failed - app can still work offline
    print('Firebase initialization failed: $e');
    print('App will continue without cloud sync features.');
  }

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider2<AuthProvider, SettingsProvider,
            ChatProvider>(
          create: (_) => ChatProvider(apiKey: null, systemPrompt: null),
          update: (_, auth, settings, previous) {
            // Update database service with user ID
            final databaseService = DatabaseService();
            databaseService.setUserId(auth.user?.uid);
            
            // Update settings provider with user ID for cloud sync
            settings.setUserId(auth.user?.uid);
            
            // Save user profile to cloud when authenticated
            if (auth.isAuthenticated && auth.user != null) {
              final cloudSyncService = CloudSyncService();
              final appUser = auth.user!;
              // User profile is already in app_user.User format from AuthProvider
              cloudSyncService.saveUserProfile(appUser.uid, appUser);
            }
            
            // Sync data when user logs in
            if (auth.isAuthenticated && auth.user != null && previous != null) {
              // Load from cloud and sync local to cloud
              databaseService.loadFromCloud().then((_) {
                databaseService.syncAllToCloud();
                // Sync settings to cloud
                settings.syncSettingsToCloud();
              }).catchError((e) {
                print('Error syncing data: $e');
              });
            }
            
            if (previous != null) {
              previous.updateApiKey(settings.apiKey);
              previous.updateSystemPrompt(settings.getCombinedSystemPrompt());
              previous.updateCustomProviders(
                  settings.customProviders, settings.customModels);
              return previous;
            }
            return ChatProvider(
              apiKey: settings.apiKey,
              systemPrompt: settings.getCombinedSystemPrompt(),
            );
          },
        ),
      ],
      child: Consumer3<ThemeProvider, SettingsProvider, AuthProvider>(
        builder: (context, themeProvider, settingsProvider, authProvider, child) {
          // Connect memory context getter and memory extraction callback to chat provider
          final chatProvider =
              Provider.of<ChatProvider>(context, listen: false);
          chatProvider.setMemoryContextGetter(
              () => settingsProvider.getMemoriesContext());
          chatProvider.setOnMemoryExtracted((memory) async {
            // Check if adding this memory would exceed the limit
            final currentTotal = settingsProvider.getTotalMemoryCharacters();
            if (currentTotal + memory.length <=
                SettingsProvider.maxTotalMemoryCharacters) {
              await settingsProvider.addMemory(memory);
            }
          });

          // Show auth screen if not authenticated
          Widget home = const SplashWrapper();
          if (!authProvider.isAuthenticated) {
            home = const AuthScreen();
          }

          return MaterialApp(
            key: const ValueKey('xibe_chat_app'),
            title: 'Xibe Chat',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: home,
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/mcp-servers': (context) => const McpServersScreen(),
              '/memory': (context) => const MemoryScreen(),
              '/ai-profiles': (context) => const AiProfilesScreen(),
              '/custom-providers': (context) => const CustomProvidersScreen(),
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
  final DeepLinkService _deepLinkService = DeepLinkService();
  String? _pendingPrompt;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
    // Check for updates after the splash screen is shown
    _checkForUpdatesAfterDelay();
  }

  Future<void> _initializeDeepLinks() async {
    try {
      // Set up deep link callback
      _deepLinkService.onDeepLinkReceived = (Uri uri) {
        _handleDeepLink(uri);
      };

      // Initialize the service
      await _deepLinkService.initialize();
    } catch (e) {
      debugPrint('Error initializing deep links: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    final deepLinkData = _deepLinkService.parseDeepLink(uri);

    if (deepLinkData == null) {
      debugPrint('Could not parse deep link: $uri');
      return;
    }

    debugPrint('Handling deep link: $deepLinkData');

    // If splash is still showing, store the data for later
    if (_showSplash) {
      if (deepLinkData.type == DeepLinkType.message &&
          deepLinkData.messagePrompt != null) {
        _pendingPrompt = deepLinkData.messagePrompt;
      }
      return;
    }

    // Handle different deep link types
    switch (deepLinkData.type) {
      case DeepLinkType.newChat:
        _navigateToNewChat();
        break;
      case DeepLinkType.message:
        if (deepLinkData.messagePrompt != null) {
          _navigateToNewChatWithPrompt(deepLinkData.messagePrompt!);
        }
        break;
      case DeepLinkType.settings:
        Navigator.of(context).pushNamed('/settings');
        break;
      case DeepLinkType.chat:
        // TODO: Implement chat navigation by ID
        _navigateToNewChat();
        break;
    }
  }

  void _navigateToNewChat() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    chatProvider.createNewChat(defaultModel: settingsProvider.defaultModel);
  }

  void _navigateToNewChatWithPrompt(String prompt) {
    // Create a new chat and set the prompt
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    chatProvider
        .createNewChat(defaultModel: settingsProvider.defaultModel)
        .then((_) {
      // The prompt will be set in ChatScreen via the provider
      chatProvider.setPendingPrompt(prompt);
    });
  }

  Future<void> _checkForUpdatesAfterDelay() async {
    // Wait for splash screen to complete
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      // Get the user's preferred update channel from settings
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final updateChannel = settingsProvider.updateChannel;

      final updateService = UpdateService();
      final updateInfo =
          await updateService.checkForUpdate(channel: updateChannel);

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
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onAnimationComplete: () {
          setState(() {
            _showSplash = false;
          });

          // Handle any pending deep link after splash
          if (_pendingPrompt != null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _navigateToNewChatWithPrompt(_pendingPrompt!);
                _pendingPrompt = null;
              }
            });
          } else {
            // Always create a new chat when opening the app
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _navigateToNewChat();
              }
            });
          }
        },
      );
    }
    return const ChatScreen();
  }
}
