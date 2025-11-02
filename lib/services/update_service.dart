import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for checking and handling application updates from GitHub releases
class UpdateService {
  static const String githubOwner = 'iotserver24';
  static const String githubRepo = 'Xibe-chat-app';
  static const String githubApiUrl = 'https://api.github.com/repos/$githubOwner/$githubRepo/releases';

  /// Check if an update is available
  /// [channel] can be 'stable' (default) or 'beta'
  /// Returns a map with 'available' (bool), 'version' (String), 'downloadUrl' (String), and 'releaseType' (String)
  Future<Map<String, dynamic>> checkForUpdate({String channel = 'stable'}) async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;
      
      // Fetch latest release from GitHub based on channel preference
      final latestRelease = await _fetchLatestRelease(channel: channel);
      
      if (latestRelease == null) {
        return {'available': false};
      }
      
      // Parse release version
      final releaseTag = latestRelease['tag_name'] as String;
      final versionInfo = _parseVersionTag(releaseTag);
      
      if (versionInfo == null) {
        return {'available': false};
      }
      
      // Compare versions
      final isNewer = _isVersionNewer(
        currentVersion,
        currentBuildNumber,
        versionInfo['version'] ?? '0.0.0',
        versionInfo['buildNumber'] ?? '0',
      );
      
      if (!isNewer) {
        return {'available': false};
      }
      
      // Get appropriate download URL for the current platform
      final downloadUrl = _getDownloadUrlForPlatform(latestRelease);
      
      if (downloadUrl == null) {
        return {'available': false};
      }
      
      return {
        'available': true,
        'version': versionInfo['version'],
        'buildNumber': versionInfo['buildNumber'],
        'downloadUrl': downloadUrl,
        'releaseNotes': latestRelease['body'] as String? ?? '',
        'isPrerelease': latestRelease['prerelease'] as bool? ?? false,
      };
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return {'available': false};
    }
  }

  /// Fetch the latest release from GitHub
  /// [channel] can be 'stable' (default) or 'beta'
  /// - 'stable': Returns only non-prerelease releases (excludes drafts and prereleases)
  /// - 'beta': Returns only prerelease releases (excludes drafts)
  Future<Map<String, dynamic>?> _fetchLatestRelease({String channel = 'stable'}) async {
    try {
      final response = await http.get(Uri.parse(githubApiUrl));
      
      if (response.statusCode != 200) {
        return null;
      }
      
      final List<dynamic> releases = json.decode(response.body);
      
      if (releases.isEmpty) {
        return null;
      }
      
      // Filter releases based on channel preference
      for (var release in releases) {
        final isDraft = release['draft'] == true;
        final isPrerelease = release['prerelease'] == true;
        
        // Skip drafts
        if (isDraft) continue;
        
        if (channel == 'stable') {
          // For stable channel, only return non-prerelease releases
          if (!isPrerelease) {
            return release as Map<String, dynamic>;
          }
        } else if (channel == 'beta') {
          // For beta channel, only return prerelease releases
          if (isPrerelease) {
            return release as Map<String, dynamic>;
          }
        }
      }
      
      // If no release found for the selected channel, return null
      return null;
    } catch (e) {
      debugPrint('Error fetching releases: $e');
      return null;
    }
  }

  /// Parse version tag (e.g., "v1.0.3-3" -> {version: "1.0.3", buildNumber: "3"})
  Map<String, String>? _parseVersionTag(String tag) {
    try {
      // Remove 'v' prefix if present
      final cleanTag = tag.startsWith('v') ? tag.substring(1) : tag;
      
      // Split by '-' to separate version and build number
      final parts = cleanTag.split('-');
      
      if (parts.isEmpty) {
        return null;
      }
      
      return {
        'version': parts[0],
        'buildNumber': parts.length > 1 ? parts[1] : '0',
      };
    } catch (e) {
      return null;
    }
  }

  /// Compare version strings to check if new version is newer
  bool _isVersionNewer(
    String currentVersion,
    String currentBuildNumber,
    String newVersion,
    String newBuildNumber,
  ) {
    try {
      // Split versions into parts
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final newParts = newVersion.split('.').map(int.parse).toList();
      
      // Ensure both have at least 3 parts (major.minor.patch)
      while (currentParts.length < 3) currentParts.add(0);
      while (newParts.length < 3) newParts.add(0);
      
      // Compare major, minor, patch
      for (int i = 0; i < 3; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }
      
      // If versions are equal, compare build numbers
      final currentBuild = int.tryParse(currentBuildNumber) ?? 0;
      final newBuild = int.tryParse(newBuildNumber) ?? 0;
      
      return newBuild > currentBuild;
    } catch (e) {
      return false;
    }
  }

  /// Get the appropriate download URL for the current platform
  String? _getDownloadUrlForPlatform(Map<String, dynamic> release) {
    try {
      final assets = release['assets'] as List<dynamic>;
      
      if (assets.isEmpty) {
        return null;
      }
      
      String? assetName;
      
      // Determine which asset to download based on platform
      if (Platform.isWindows) {
        // Prefer NSIS installer for Windows x64
        assetName = _findAsset(assets, ['installer-x64', '.exe']);
        assetName ??= _findAsset(assets, ['windows-x64', '.zip']);
        assetName ??= _findAsset(assets, ['windows-x64', '.msix']);
      } else if (Platform.isLinux) {
        // Prefer AppImage for Linux
        assetName = _findAsset(assets, ['linux-x64', '.AppImage']);
        assetName ??= _findAsset(assets, ['linux-x64', '.deb']);
        assetName ??= _findAsset(assets, ['linux-x64', '.tar.gz']);
      } else if (Platform.isMacOS) {
        // Prefer DMG for macOS (detect architecture)
        final isArm = _isAppleSilicon();
        if (isArm) {
          assetName = _findAsset(assets, ['macos-arm64', '.dmg']);
          assetName ??= _findAsset(assets, ['macos-arm64', '.zip']);
        } else {
          assetName = _findAsset(assets, ['macos-x64', '.dmg']);
          assetName ??= _findAsset(assets, ['macos-x64', '.zip']);
        }
      } else if (Platform.isAndroid) {
        assetName = _findAsset(assets, ['.apk']);
      } else if (Platform.isIOS) {
        assetName = _findAsset(assets, ['.ipa']);
      }
      
      if (assetName == null) {
        return null;
      }
      
      // Find the asset with this name
      for (var asset in assets) {
        if (asset['name'] == assetName) {
          return asset['browser_download_url'] as String;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      return null;
    }
  }

  /// Find an asset name that matches all patterns
  String? _findAsset(List<dynamic> assets, List<String> patterns) {
    for (var asset in assets) {
      final name = asset['name'] as String;
      if (patterns.every((pattern) => name.contains(pattern))) {
        return name;
      }
    }
    return null;
  }

  /// Check if running on Apple Silicon
  bool _isAppleSilicon() {
    try {
      // Check the architecture
      final result = Process.runSync('uname', ['-m']);
      final arch = result.stdout.toString().trim();
      return arch == 'arm64';
    } catch (e) {
      return false;
    }
  }

  /// Download and install update
  Future<bool> downloadAndInstall(String downloadUrl) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // For mobile, open the download URL in browser
        final uri = Uri.parse(downloadUrl);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return false;
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop, download the file and open it
        return await _downloadAndOpenDesktop(downloadUrl);
      }
      
      return false;
    } catch (e) {
      debugPrint('Error downloading update: $e');
      return false;
    }
  }

  /// Download installer for desktop platforms and open it
  Future<bool> _downloadAndOpenDesktop(String downloadUrl) async {
    try {
      // Download the file
      final response = await http.get(Uri.parse(downloadUrl));
      
      if (response.statusCode != 200) {
        return false;
      }
      
      // Get downloads directory
      final dir = await getDownloadsDirectory();
      if (dir == null) {
        return false;
      }
      
      // Extract filename from URL
      final uri = Uri.parse(downloadUrl);
      final filename = uri.pathSegments.last;
      
      // Save the file
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);
      
      // Open the file with the default application
      final uri2 = Uri.file(file.path);
      if (await canLaunchUrl(uri2)) {
        await launchUrl(uri2);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error in desktop download: $e');
      return false;
    }
  }

  /// Just open the download URL in browser (fallback method)
  Future<bool> openDownloadPage(String downloadUrl) async {
    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('Error opening download page: $e');
      return false;
    }
  }
}
