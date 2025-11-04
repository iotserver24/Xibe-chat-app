import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/update_service.dart';
import 'dart:io';

/// Dialog widget to display update information and prompt user to update
class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> updateInfo;
  final UpdateService updateService;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.updateService,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final version = widget.updateInfo['version'] ?? 'Unknown';
    final buildNumber = widget.updateInfo['buildNumber'] ?? '';
    final releaseNotes = widget.updateInfo['releaseNotes'] ?? '';
    final isPrerelease = widget.updateInfo['isPrerelease'] ?? false;
    
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Update Available'),
                if (buildNumber.isNotEmpty)
                  Text(
                    'Version $version-$buildNumber',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (isPrerelease)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Beta Version',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (releaseNotes.isNotEmpty) ...[
              Text(
                'Release Notes:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 300,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: SingleChildScrollView(
                  child: MarkdownBody(
                    data: releaseNotes,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Preparing download...',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDownloading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Later'),
        ),
        TextButton.icon(
          onPressed: _isDownloading ? null : _handleOpenDownloadPage,
          icon: const Icon(Icons.open_in_browser),
          label: const Text('Open Download Page'),
        ),
        FilledButton.icon(
          onPressed: _isDownloading ? null : _handleUpdate,
          icon: const Icon(Icons.download),
          label: Text(Platform.isAndroid ? 'Download APK' : 'Update Now'),
        ),
      ],
    );
  }

  Future<void> _handleUpdate() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = '';
    });

    try {
      final downloadUrl = widget.updateInfo['downloadUrl'] as String;
      final success = await widget.updateService.downloadAndInstall(downloadUrl);

      if (!mounted) return;

      if (success) {
        // Close dialog and show success message
        Navigator.of(context).pop(true);
        
        if (mounted) {
          if (Platform.isAndroid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Opening download page. After download completes, tap the APK to install.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 5),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Update downloaded! Please install it to complete the update.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to download update. Please try using "Open Download Page" button.';
          _isDownloading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isDownloading = false;
      });
    }
  }

  Future<void> _handleOpenDownloadPage() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = '';
    });

    try {
      final success = await widget.updateService.openDownloadPage(UpdateService.githubReleasesUrl);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.open_in_browser, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Opened GitHub releases page. Download the APK and install it.'),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to open download page. Please visit GitHub releases manually.';
          _isDownloading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isDownloading = false;
      });
    }
  }
}

/// Helper function to show the update dialog
Future<bool> showUpdateDialog(
  BuildContext context,
  Map<String, dynamic> updateInfo,
  UpdateService updateService,
) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => UpdateDialog(
      updateInfo: updateInfo,
      updateService: updateService,
    ),
  );
  
  return result ?? false;
}
