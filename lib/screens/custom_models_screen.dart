import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/settings_provider.dart';
import '../models/custom_model.dart';

class CustomModelsScreen extends StatefulWidget {
  final String providerId;
  final String providerName;

  const CustomModelsScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<CustomModelsScreen> createState() => _CustomModelsScreenState();
}

class _CustomModelsScreenState extends State<CustomModelsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final models = settingsProvider.getModelsByProvider(widget.providerId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Models - ${widget.providerName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddModelDialog(context),
          ),
        ],
      ),
      body: models.isEmpty
          ? const Center(
              child: Text('No models configured. Add one to get started.'),
            )
          : ListView.builder(
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.smart_toy, color: Colors.purple),
                    title: Text(model.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Model ID: ${model.modelId}'),
                        Text(
                          model.description,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Wrap(
                          spacing: 4,
                          children: [
                            if (model.supportsVision)
                              const Chip(
                                label: Text('Vision',
                                    style: TextStyle(fontSize: 10)),
                                padding: EdgeInsets.all(2),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            if (model.supportsStreaming)
                              const Chip(
                                label: Text('Streaming',
                                    style: TextStyle(fontSize: 10)),
                                padding: EdgeInsets.all(2),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            if (model.supportsTools)
                              const Chip(
                                label: Text('Tools',
                                    style: TextStyle(fontSize: 10)),
                                padding: EdgeInsets.all(2),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditModelDialog(context, model),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, model),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddModelDialog(BuildContext context) {
    final nameController = TextEditingController();
    final modelIdController = TextEditingController();
    final descriptionController = TextEditingController();
    final endpointUrlController = TextEditingController();
    bool supportsVision = false;
    bool supportsStreaming = true;
    bool supportsTools = false;

    // Get provider to show example endpoint URL
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final provider = settingsProvider.getProviderById(widget.providerId);
    final exampleUrl = provider?.type == 'anthropic'
        ? '${provider?.baseUrl}/messages'
        : '${provider?.baseUrl}/chat/completions';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Custom Model'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'e.g., GPT-4 Turbo',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: modelIdController,
                  decoration: const InputDecoration(
                    labelText: 'Model ID',
                    hintText: 'e.g., gpt-4-turbo-preview',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endpointUrlController,
                  decoration: InputDecoration(
                    labelText: 'Custom Endpoint URL (Optional)',
                    hintText: exampleUrl,
                    helperText:
                        'Leave empty to auto-generate from provider base URL. Only specify if this model uses a different endpoint than the provider default.',
                    helperMaxLines: 3,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description of the model',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Supports Vision'),
                  value: supportsVision,
                  onChanged: (value) {
                    setState(() {
                      supportsVision = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Supports Streaming'),
                  value: supportsStreaming,
                  onChanged: (value) {
                    setState(() {
                      supportsStreaming = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Supports Tools'),
                  value: supportsTools,
                  onChanged: (value) {
                    setState(() {
                      supportsTools = value ?? false;
                    });
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
                if (nameController.text.isNotEmpty &&
                    modelIdController.text.isNotEmpty) {
                  final model = CustomModel(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    modelId: modelIdController.text,
                    providerId: widget.providerId,
                    description: descriptionController.text,
                    endpointUrl: endpointUrlController.text
                        .trim(), // Optional - will use provider base URL if empty
                    supportsVision: supportsVision,
                    supportsStreaming: supportsStreaming,
                    supportsTools: supportsTools,
                  );
                  Provider.of<SettingsProvider>(context, listen: false)
                      .addCustomModel(model);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModelDialog(BuildContext context, CustomModel model) {
    final nameController = TextEditingController(text: model.name);
    final modelIdController = TextEditingController(text: model.modelId);
    final descriptionController =
        TextEditingController(text: model.description);
    final endpointUrlController =
        TextEditingController(text: model.endpointUrl);
    bool supportsVision = model.supportsVision;
    bool supportsStreaming = model.supportsStreaming;
    bool supportsTools = model.supportsTools;

    // Get provider to show example endpoint URL
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final provider = settingsProvider.getProviderById(widget.providerId);
    final exampleUrl = provider?.type == 'anthropic'
        ? '${provider?.baseUrl}/messages'
        : '${provider?.baseUrl}/chat/completions';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Model'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: modelIdController,
                  decoration: const InputDecoration(labelText: 'Model ID'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endpointUrlController,
                  decoration: InputDecoration(
                    labelText: 'Custom Endpoint URL (Optional)',
                    hintText: exampleUrl,
                    helperText:
                        'Leave empty to auto-generate from provider base URL. Only specify if this model uses a different endpoint than the provider default.',
                    helperMaxLines: 3,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Supports Vision'),
                  value: supportsVision,
                  onChanged: (value) {
                    setState(() {
                      supportsVision = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Supports Streaming'),
                  value: supportsStreaming,
                  onChanged: (value) {
                    setState(() {
                      supportsStreaming = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Supports Tools'),
                  value: supportsTools,
                  onChanged: (value) {
                    setState(() {
                      supportsTools = value ?? false;
                    });
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
                if (nameController.text.isNotEmpty &&
                    modelIdController.text.isNotEmpty) {
                  final updatedModel = model.copyWith(
                    name: nameController.text,
                    modelId: modelIdController.text,
                    description: descriptionController.text,
                    endpointUrl: endpointUrlController.text
                        .trim(), // Optional - will use provider base URL if empty
                    supportsVision: supportsVision,
                    supportsStreaming: supportsStreaming,
                    supportsTools: supportsTools,
                  );
                  Provider.of<SettingsProvider>(context, listen: false)
                      .updateCustomModel(updatedModel);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CustomModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: Text('Are you sure you want to delete ${model.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<SettingsProvider>(context, listen: false)
                  .deleteCustomModel(model.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
