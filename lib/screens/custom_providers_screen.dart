import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/settings_provider.dart';
import '../models/custom_provider.dart';
import 'custom_models_screen.dart';

class CustomProvidersScreen extends StatefulWidget {
  const CustomProvidersScreen({super.key});

  @override
  State<CustomProvidersScreen> createState() => _CustomProvidersScreenState();
}

class _CustomProvidersScreenState extends State<CustomProvidersScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final providers = settingsProvider.customProviders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom API Providers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProviderDialog(context),
          ),
        ],
      ),
      body: providers.isEmpty
          ? const Center(
              child: Text('No providers configured. Add one to get started.'),
            )
          : ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      provider.isBuiltIn ? Icons.verified : Icons.cloud,
                      color: provider.isBuiltIn ? Colors.blue : Colors.orange,
                    ),
                    title: Text(provider.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider.baseUrl),
                        Text(
                          'Type: ${provider.type}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'API Key: ${provider.apiKey.isEmpty ? "Not set" : "••••••"}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.list),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomModelsScreen(
                                  providerId: provider.id,
                                  providerName: provider.name,
                                ),
                              ),
                            );
                          },
                          tooltip: 'View Models',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditProviderDialog(context, provider),
                        ),
                        if (!provider.isBuiltIn)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, provider),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddProviderDialog(BuildContext context) {
    final nameController = TextEditingController();
    final baseUrlController = TextEditingController();
    final apiKeyController = TextEditingController();
    String selectedType = 'openai';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Provider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Provider Name',
                  hintText: 'e.g., My Custom Provider',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'e.g., https://api.example.com/v1',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your API key',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'API Type',
                ),
                items: const [
                  DropdownMenuItem(value: 'openai', child: Text('OpenAI Compatible')),
                  DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && baseUrlController.text.isNotEmpty) {
                final provider = CustomProvider(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  baseUrl: baseUrlController.text,
                  apiKey: apiKeyController.text,
                  type: selectedType,
                  isBuiltIn: false,
                );
                Provider.of<SettingsProvider>(context, listen: false).addCustomProvider(provider);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProviderDialog(BuildContext context, CustomProvider provider) {
    final nameController = TextEditingController(text: provider.name);
    final baseUrlController = TextEditingController(text: provider.baseUrl);
    final apiKeyController = TextEditingController(text: provider.apiKey);
    String selectedType = provider.type;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Provider'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Provider Name'),
                enabled: !provider.isBuiltIn,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: baseUrlController,
                decoration: const InputDecoration(labelText: 'Base URL'),
                enabled: !provider.isBuiltIn,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your API key',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'API Type'),
                items: const [
                  DropdownMenuItem(value: 'openai', child: Text('OpenAI Compatible')),
                  DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
                ],
                onChanged: provider.isBuiltIn ? null : (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProvider = provider.copyWith(
                name: nameController.text,
                baseUrl: baseUrlController.text,
                apiKey: apiKeyController.text,
                type: selectedType,
              );
              Provider.of<SettingsProvider>(context, listen: false).updateCustomProvider(updatedProvider);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CustomProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Provider'),
        content: Text('Are you sure you want to delete ${provider.name}? This will also delete all associated custom models.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<SettingsProvider>(context, listen: false).deleteCustomProvider(provider.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
