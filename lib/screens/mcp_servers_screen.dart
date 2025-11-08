import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/mcp_config.dart';
import '../services/mcp_config_service.dart';
import '../providers/chat_provider.dart';

class McpServersScreen extends StatefulWidget {
  const McpServersScreen({super.key});

  @override
  State<McpServersScreen> createState() => _McpServersScreenState();
}

class _McpServersScreenState extends State<McpServersScreen> {
  final McpConfigService _configService = McpConfigService();
  Map<String, McpServerConfig> _servers = {};
  Map<String, bool> _serverStates = {}; // Track on/off state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    setState(() {
      _isLoading = true;
    });
    
    final config = await _configService.loadConfiguration();
    setState(() {
      _servers = config.mcpServers;
      // Load enabled state from configuration
      _serverStates = {
        for (var entry in _servers.entries)
          entry.key: entry.value.isEnabled
      };
      _isLoading = false;
    });
  }

  void _showAddServerDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add MCP Server',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Only hosted MCP servers (URL-based) are supported.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Server Name',
                  hintText: 'e.g., my-mcp-server',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'e.g., https://mcp.example.com',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final config = McpServerConfig(
                  url: urlController.text,
                  headers: {},
                );
                
                await _configService.addOrUpdateServer(nameController.text, config);
                await _loadServers();
                if (context.mounted) {
                  Navigator.pop(context);
                  // Reload MCP connections in ChatProvider
                  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                  await chatProvider.reloadMcpServers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Server added successfully')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportConfiguration() async {
    try {
      final jsonString = await _configService.exportConfiguration();
      await Clipboard.setData(ClipboardData(text: jsonString));
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Configuration Exported'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your MCP configuration has been copied to the clipboard!'),
                SizedBox(height: 12),
                Text(
                  'You can now paste it into other apps or save it to a file.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting configuration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImportDialog() async {
    final TextEditingController importController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.file_download, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Text('Import Configuration'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your MCP configuration JSON here:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: importController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '{\n  "mcpServers": {\n    ...\n  }\n}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will replace your current configuration.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final jsonString = importController.text.trim();
              if (jsonString.isNotEmpty) {
                final success = await _configService.importConfiguration(jsonString);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    await _loadServers();
                    // Reload MCP connections in ChatProvider
                    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                    await chatProvider.reloadMcpServers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuration imported successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to import configuration. Check JSON format.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfigFileLocation() async {
    final filePath = await _configService.getConfigFilePath();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.folder_open, color: Color(0xFF3B82F6)),
              SizedBox(width: 8),
              Text('Configuration File'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MCP servers are stored in a JSON configuration file:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: SelectableText(
                  filePath,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You can edit this file directly or use the app interface.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: filePath));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Path copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Copy Path'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP Servers'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) {
              switch (value) {
                case 'location':
                  _showConfigFileLocation();
                  break;
                case 'export':
                  _exportConfiguration();
                  break;
                case 'import':
                  _showImportDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'location',
                child: Row(
                  children: [
                    Icon(Icons.folder_open),
                    SizedBox(width: 8),
                    Text('Show File Location'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Export Configuration'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Import Configuration'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServerDialog,
            tooltip: 'Add MCP Server',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _servers.isEmpty
          ? Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.dns_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No MCP Servers configured',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'MCP (Model Context Protocol) servers provide additional context and tools for AI models.\n\nOnly hosted (URL-based) MCP servers are supported.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showAddServerDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Server'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : ListView.builder(
              itemCount: _servers.length,
              itemBuilder: (context, index) {
                final entry = _servers.entries.elementAt(index);
                final serverName = entry.key;
                final serverConfig = entry.value;
                final isEnabled = _serverStates[serverName] ?? true;
                
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isEnabled
                          ? Colors.green
                          : Colors.grey,
                      child: Icon(
                        isEnabled ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      serverName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      serverConfig.url?.isNotEmpty == true 
                          ? 'URL: ${serverConfig.url}'
                          : 'Invalid configuration',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: isEnabled,
                      onChanged: (value) async {
                        // Update the server config with new enabled state
                        final updatedConfig = serverConfig.copyWith(isEnabled: value);
                        await _configService.addOrUpdateServer(serverName, updatedConfig);
                        
                        setState(() {
                          _serverStates[serverName] = value;
                          _servers[serverName] = updatedConfig;
                        });
                        // Reload MCP connections in ChatProvider
                        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                        chatProvider.reloadMcpServers();
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (serverConfig.url?.isNotEmpty == true) ...[
                              _buildDetailRow('URL', serverConfig.url!),
                              if (serverConfig.headers?.isNotEmpty == true)
                                _buildDetailRow('Headers', serverConfig.headers.toString()),
                            ] else ...[
                              const Text(
                                'Invalid server configuration. Only URL-based servers are supported.',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Server'),
                                        content: Text(
                                          'Are you sure you want to delete "$serverName"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirm == true) {
                                      await _configService.removeServer(serverName);
                                      await _loadServers();
                                      if (context.mounted) {
                                        // Reload MCP connections in ChatProvider
                                        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                                        await chatProvider.reloadMcpServers();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Server deleted successfully'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
