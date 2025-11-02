import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart' show ThemeProvider, AppTheme;
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import 'mcp_servers_screen.dart';
import 'memory_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _systemPromptController = TextEditingController();
  final TextEditingController _e2bApiKeyController = TextEditingController();
  bool _isObscured = true;
  bool _isE2bObscured = true;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      _apiKeyController.text = settingsProvider.apiKey ?? '';
      _systemPromptController.text = settingsProvider.systemPrompt ?? '';
      _e2bApiKeyController.text = settingsProvider.e2bApiKey ?? '';
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _systemPromptController.dispose();
    _e2bApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWideScreen ? 800 : double.infinity,
          ),
          child: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            context,
            'API Configuration',
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xibe API Key',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your Xibe API key. If left empty, the app will use the default key from environment.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        hintText: 'Enter API key (optional)',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isObscured ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              onPressed: () async {
                                final apiKey = _apiKeyController.text.trim();
                                final settingsProvider =
                                    Provider.of<SettingsProvider>(context, listen: false);
                                final chatProvider =
                                    Provider.of<ChatProvider>(context, listen: false);
                                
                                await settingsProvider.setApiKey(
                                  apiKey.isEmpty ? null : apiKey,
                                );
                                chatProvider.updateApiKey(
                                  apiKey.isEmpty ? null : apiKey,
                                );
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('API key saved successfully'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Custom System Prompt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set a custom system prompt to define AI behavior (max 1000 characters). Leave empty to use default.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _systemPromptController,
                      maxLength: 1000,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'e.g., You are a helpful assistant that...',
                        counterText: '${_systemPromptController.text.length}/1000',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save, color: Colors.green),
                          onPressed: () async {
                            final prompt = _systemPromptController.text.trim();
                            final settingsProvider =
                                Provider.of<SettingsProvider>(context, listen: false);
                            final chatProvider =
                                Provider.of<ChatProvider>(context, listen: false);
                            
                            await settingsProvider.setSystemPrompt(
                              prompt.isEmpty ? null : prompt,
                            );
                            chatProvider.updateSystemPrompt(
                              prompt.isEmpty ? null : prompt,
                            );
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('System prompt saved successfully'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      onChanged: (value) {
                        // Trigger rebuild to update the character counter display
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'E2B API Key',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your E2B API key to enable code execution sandbox. Get your key from https://e2b.dev',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _e2bApiKeyController,
                      obscureText: _isE2bObscured,
                      decoration: InputDecoration(
                        hintText: 'Enter E2B API key (optional)',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isE2bObscured ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isE2bObscured = !_isE2bObscured;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              onPressed: () async {
                                final apiKey = _e2bApiKeyController.text.trim();
                                final settingsProvider =
                                    Provider.of<SettingsProvider>(context, listen: false);
                                
                                await settingsProvider.setE2bApiKey(
                                  apiKey.isEmpty ? null : apiKey,
                                );
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('E2B API key saved successfully'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'Appearance',
            [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Column(
                    children: [
                      ListTile(
                        title: const Text('Theme'),
                        subtitle: Text(_getThemeName(themeProvider.currentTheme)),
                        leading: const Icon(Icons.palette),
                        onTap: () {
                          _showThemePickerDialog(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'Advanced AI Settings',
            [
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Column(
                    children: [
                      ListTile(
                        title: const Text('Temperature'),
                        subtitle: Text('${settingsProvider.temperature.toStringAsFixed(2)} - Controls randomness'),
                        trailing: SizedBox(
                          width: 200,
                          child: Slider(
                            value: settingsProvider.temperature,
                            min: 0.0,
                            max: 2.0,
                            divisions: 20,
                            label: settingsProvider.temperature.toStringAsFixed(2),
                            onChanged: (value) {
                              settingsProvider.setTemperature(value);
                            },
                          ),
                        ),
                      ),
                      // Max Tokens setting removed as per requirement
                      ListTile(
                        title: const Text('Top P'),
                        subtitle: Text('${settingsProvider.topP.toStringAsFixed(2)} - Nucleus sampling'),
                        trailing: SizedBox(
                          width: 200,
                          child: Slider(
                            value: settingsProvider.topP,
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            label: settingsProvider.topP.toStringAsFixed(2),
                            onChanged: (value) {
                              settingsProvider.setTopP(value);
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Frequency Penalty'),
                        subtitle: Text('${settingsProvider.frequencyPenalty.toStringAsFixed(2)} - Reduces repetition'),
                        trailing: SizedBox(
                          width: 200,
                          child: Slider(
                            value: settingsProvider.frequencyPenalty,
                            min: 0.0,
                            max: 2.0,
                            divisions: 20,
                            label: settingsProvider.frequencyPenalty.toStringAsFixed(2),
                            onChanged: (value) {
                              settingsProvider.setFrequencyPenalty(value);
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Presence Penalty'),
                        subtitle: Text('${settingsProvider.presencePenalty.toStringAsFixed(2)} - Encourages new topics'),
                        trailing: SizedBox(
                          width: 200,
                          child: Slider(
                            value: settingsProvider.presencePenalty,
                            min: 0.0,
                            max: 2.0,
                            divisions: 20,
                            label: settingsProvider.presencePenalty.toStringAsFixed(2),
                            onChanged: (value) {
                              settingsProvider.setPresencePenalty(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'Data',
            [
              ListTile(
                title: const Text('Clear All Chats'),
                subtitle: const Text('Delete all chat history'),
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text(
                        'Clear All Chats',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to delete all chats? This action cannot be undone.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<ChatProvider>(context, listen: false)
                                .deleteAllChats();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete All',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'AI Memory',
            [
              ListTile(
                title: const Text('Long-Term Memory'),
                subtitle: Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    final memoryCount = settings.memories.length;
                    final totalChars = settings.getTotalMemoryCharacters();
                    return Text(
                      '$memoryCount memory points • $totalChars/1000 characters used',
                      style: TextStyle(
                        color: totalChars > 900 ? Colors.orange : Colors.grey,
                      ),
                    );
                  },
                ),
                leading: const Icon(Icons.psychology_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'Integrations',
            [
              ListTile(
                title: const Text('MCP Servers'),
                subtitle: const Text('Manage Model Context Protocol servers'),
                leading: const Icon(Icons.dns_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const McpServersScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Code Execution (E2B)'),
                subtitle: Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    final hasKey = settings.e2bApiKey != null && 
                                   settings.e2bApiKey!.isNotEmpty;
                    return Text(
                      hasKey 
                          ? 'Configured - Code execution enabled'
                          : 'Not configured - Add E2B API key above',
                      style: TextStyle(
                        color: hasKey ? Colors.green : Colors.orange,
                      ),
                    );
                  },
                ),
                leading: const Icon(Icons.code),
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'About',
            [
              ListTile(
                title: const Text('App Version'),
                subtitle: Text(_appVersion),
                leading: const Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('Check for Updates'),
                subtitle: const Text('Check if a new version is available'),
                leading: const Icon(Icons.system_update),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _checkForUpdates(),
              ),
              ListTile(
                title: const Text('Xibe Chat'),
                subtitle: const Text('AI Chat Application'),
                leading: const Icon(Icons.chat_bubble_outline),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Developer'),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text('R3AP3Reditz'),
                    SizedBox(height: 2),
                    Text(
                      'A.K.A Anish Kumar - A dev from India',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                leading: const Icon(Icons.person),
              ),
              ListTile(
                title: const Text('GitHub'),
                subtitle: const Text('github.com/iotserver24'),
                leading: const Icon(Icons.code),
                onTap: () async {
                  final uri = Uri.parse('https://github.com/iotserver24');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              ListTile(
                title: const Text('Portfolio'),
                subtitle: const Text('anishkumar.tech'),
                leading: const Icon(Icons.public),
                onTap: () async {
                  final uri = Uri.parse('https://anishkumar.tech');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  String _getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return 'Dark Theme';
      case AppTheme.light:
        return 'Light Theme';
      case AppTheme.blue:
        return 'Blue Ocean Theme';
      case AppTheme.purple:
        return 'Purple Galaxy Theme';
      case AppTheme.green:
        return 'Forest Green Theme';
    }
  }

  void _showThemePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: SingleChildScrollView(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: AppTheme.values.map((theme) {
                    final isSelected = themeProvider.currentTheme == theme;
                    return RadioListTile<AppTheme>(
                      title: Text(_getThemeName(theme)),
                      value: theme,
                      groupValue: themeProvider.currentTheme,
                      onChanged: (AppTheme? value) {
                        if (value != null) {
                          themeProvider.setTheme(value);
                          Navigator.pop(dialogContext);
                        }
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      selected: isSelected,
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkForUpdates() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final updateService = UpdateService();
      final updateInfo = await updateService.checkForUpdate();

      if (!mounted) return;

      // Close loading indicator
      Navigator.of(context).pop();

      if (updateInfo['available'] == true) {
        // Show update dialog
        await showUpdateDialog(context, updateInfo, updateService);
      } else {
        // Show "no updates available" message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('You are using the latest version!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      // Close loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Failed to check for updates: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
