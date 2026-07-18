import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateConfig {
  final String minimumVersion;
  final String latestVersion;
  final String storeUrlAndroid;
  final String storeUrlIos;
  final String updateMessage;

  UpdateConfig({
    required this.minimumVersion,
    required this.latestVersion,
    required this.storeUrlAndroid,
    required this.storeUrlIos,
    required this.updateMessage,
  });

  factory UpdateConfig.fromJson(Map<String, dynamic> json) {
    return UpdateConfig(
      minimumVersion: json['minimum_version'] ?? '1.0.0',
      latestVersion: json['latest_version'] ?? '1.0.0',
      storeUrlAndroid: json['store_url_android'] ?? '',
      storeUrlIos: json['store_url_ios'] ?? '',
      updateMessage: json['update_message'] ?? 'A new version of the app is available. Please update to continue!',
    );
  }
}

class ForceUpdateService {
  // Configurable Remote JSON Endpoint
  // Example: 'https://raw.githubusercontent.com/username/repo/main/update_config.json'
  static String? remoteConfigUrl;

  // Toggle this to TRUE during testing to simulate update requirement without a backend
  static bool useMockConfig = false; 

  // The mocked update configuration for testing
  static final Map<String, dynamic> mockConfigData = {
    'minimum_version': '2.0.0', // Higher than current 1.0.0 to force update
    'latest_version': '2.0.0',
    'store_url_android': 'https://play.google.com/store/apps/details?id=com.littlespark.app',
    'store_url_ios': 'https://apps.apple.com/app/id123456789',
    'update_message': 'We have added magical new games, songs, and shapes! Please update to continue your learning adventure. ✨',
  };

  /// Fetches update configuration from remote URL or mock data.
  static Future<UpdateConfig> getUpdateConfig() async {
    if (useMockConfig) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency
      return UpdateConfig.fromJson(mockConfigData);
    }

    if (remoteConfigUrl == null || remoteConfigUrl!.isEmpty) {
      // Return a default configuration that doesn't trigger any updates
      return UpdateConfig(
        minimumVersion: '1.0.0',
        latestVersion: '1.0.0',
        storeUrlAndroid: '',
        storeUrlIos: '',
        updateMessage: '',
      );
    }

    try {
      final client = HttpClient();
      // Set a short connection timeout
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse(remoteConfigUrl!));
      final response = await request.close();
      
      if (response.statusCode == HttpStatus.ok) {
        final contents = await response.transform(utf8.decoder).join();
        final data = json.decode(contents) as Map<String, dynamic>;
        return UpdateConfig.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching force update config: $e');
    }

    // Return default empty config on error to allow user to enter app safely
    return UpdateConfig(
      minimumVersion: '1.0.0',
      latestVersion: '1.0.0',
      storeUrlAndroid: '',
      storeUrlIos: '',
      updateMessage: '',
    );
  }

  /// Checks if the app needs to be forcefully updated.
  /// Returns `true` if current version is less than [minimumVersion].
  static Future<bool> isUpdateRequired(UpdateConfig config) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      return isVersionLessThan(currentVersion, config.minimumVersion);
    } catch (e) {
      debugPrint('Error getting package info: $e');
      return false;
    }
  }

  /// Helper to compare two semantic version strings (e.g. "1.2.0" and "1.3.1").
  static bool isVersionLessThan(String current, String target) {
    try {
      final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final targetParts = target.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLength = currentParts.length > targetParts.length ? currentParts.length : targetParts.length;

      for (int i = 0; i < maxLength; i++) {
        final currentPart = i < currentParts.length ? currentParts[i] : 0;
        final targetPart = i < targetParts.length ? targetParts[i] : 0;

        if (currentPart < targetPart) return true;
        if (currentPart > targetPart) return false;
      }
    } catch (e) {
      debugPrint('Error comparing versions: $e');
    }
    return false;
  }

  /// Launches the platform-appropriate store URL.
  static Future<void> launchStore(UpdateConfig config) async {
    final urlString = Platform.isIOS ? config.storeUrlIos : config.storeUrlAndroid;
    if (urlString.isEmpty) return;

    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch store URL: $e');
    }
  }
}
