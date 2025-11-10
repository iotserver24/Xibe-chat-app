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
          icon: const Icon(Icons.psychology, color: Colors.white, size: 20),
          tooltip: 'Select AI Model',
          onSelected: (String value) {
            // If value starts with "provider:", show models for that provider
            if (value.startsWith('provider:')) {
              final providerName =
                  value.substring(9); // Remove "provider:" prefix
              _showProviderModels(context, chatProvider, providerName);
            } else {
              // It's a model ID, select it
              chatProvider.setSelectedModel(value);
            }
          },
          itemBuilder: (BuildContext context) {
            return _buildProviderMenuItems(context, chatProvider);
          },
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildProviderMenuItems(
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

    // Add Xibe provider
    if (xibeModels.isNotEmpty) {
      items.add(PopupMenuItem<String>(
        value: 'provider:Xibe',
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: 18, color: Colors.blue),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Xibe',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              '${xibeModels.length}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ));
    }

    // Add custom providers
    for (var provider in customProviders) {
      if (provider.id == 'xibe') continue; // Already added above

      final providerModels =
          allModels.where((m) => m['provider'] == provider.name).toList();

      if (providerModels.isEmpty) continue;

      items.add(PopupMenuItem<String>(
        value: 'provider:${provider.name}',
        child: Row(
          children: [
            const Icon(Icons.cloud, size: 18, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              '${providerModels.length}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ));
    }

    if (items.isEmpty) {
      return const [
        PopupMenuItem<String>(
          enabled: false,
          child: Text('Loading providers...'),
        ),
      ];
    }

    return items;
  }

  void _showProviderModels(
      BuildContext context, ChatProvider chatProvider, String providerName) {
    final allModels = chatProvider.getAllModels();
    final providerModels =
        allModels.where((m) => m['provider'] == providerName).toList();

    if (providerModels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No models available for $providerName'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get the button's position to show menu near it
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (button != null && overlay != null) {
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero),
              ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      // Show models menu
      showMenu<String>(
        context: context,
        position: position,
        items: _buildModelMenuItems(context, chatProvider, providerName),
      ).then((modelId) {
        if (modelId != null && modelId.isNotEmpty) {
          chatProvider.setSelectedModel(modelId);
        }
      });
    }
  }

  List<PopupMenuEntry<String>> _buildModelMenuItems(
      BuildContext context, ChatProvider chatProvider, String providerName) {
    final items = <PopupMenuEntry<String>>[];
    final allModels = chatProvider.getAllModels();
    final providerModels =
        allModels.where((m) => m['provider'] == providerName).toList();

    // Add provider header
    items.add(PopupMenuItem<String>(
      enabled: false,
      child: Row(
        children: [
          Icon(
            providerName == 'Xibe' ? Icons.auto_awesome : Icons.cloud,
            size: 16,
            color: providerName == 'Xibe' ? Colors.blue : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            '$providerName Models',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ));

    items.add(const PopupMenuDivider());

    // Add models
    for (var model in providerModels) {
      final isSelected = chatProvider.selectedModel == model['id'];
      items.add(PopupMenuItem<String>(
        value: model['id'] ?? '',
        child: Row(
          children: [
            if (isSelected)
              const Icon(Icons.check, size: 16, color: Colors.green),
            if (isSelected) const SizedBox(width: 8),
            Expanded(
              child: Text(
                model['name'] ?? '',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ));
    }

    return items;
  }
}
