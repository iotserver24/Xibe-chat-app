import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../models/custom_provider.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          tooltip: 'Select AI Model',
          onSelected: (String modelId) {
            chatProvider.setSelectedModel(modelId);
          },
          itemBuilder: (BuildContext context) {
            return _buildModelMenuItems(context, chatProvider);
          },
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildModelMenuItems(
      BuildContext context, ChatProvider chatProvider) {
    final items = <PopupMenuEntry<String>>[];
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // Get all models grouped by provider
    final allModels = chatProvider.getAllModels();
    final xibeModels = allModels.where((m) => m['provider'] == 'Xibe').toList();

    // Get custom providers that have models
    final customProviders = <CustomProvider>[];
    for (var provider in settingsProvider.customProviders) {
      if (provider.id == 'xibe') continue; // Skip Xibe, handled separately
      final hasModels = allModels.any((m) => m['provider'] == provider.name);
      if (hasModels) {
        customProviders.add(provider);
      }
    }

    // Add Xibe models first
    if (xibeModels.isNotEmpty) {
      items.add(const PopupMenuDivider());
      items.add(const PopupMenuItem<String>(
        enabled: false,
        child:
            Text('Xibe Models', style: TextStyle(fontWeight: FontWeight.bold)),
      ));
      for (var model in xibeModels) {
        final isSelected = chatProvider.selectedModel == model['id'];
        items.add(PopupMenuItem<String>(
          value: model['id'],
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check, size: 16, color: Colors.green),
              if (isSelected) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  model['name'] ?? '',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
    }

    // Add custom providers with their models
    for (var provider in customProviders) {
      if (provider.id == 'xibe') continue; // Already added above

      final providerModels =
          allModels.where((m) => m['provider'] == provider.name).toList();

      if (providerModels.isEmpty) continue;

      items.add(const PopupMenuDivider());
      items.add(PopupMenuItem<String>(
        enabled: false,
        child: Row(
          children: [
            const Icon(Icons.cloud, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              provider.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ));

      for (var model in providerModels) {
        final isSelected = chatProvider.selectedModel == model['id'];
        items.add(PopupMenuItem<String>(
          value: model['id'],
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check, size: 16, color: Colors.green),
                if (isSelected) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    model['name'] ?? '',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }

    if (items.isEmpty) {
      return const [
        PopupMenuItem<String>(
          enabled: false,
          child: Text('Loading models...'),
        ),
      ];
    }

    return items;
  }
}
