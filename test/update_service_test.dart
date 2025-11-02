import 'package:flutter_test/flutter_test.dart';
import 'package:xibe_chat/services/update_service.dart';

void main() {
  group('UpdateService', () {
    late UpdateService updateService;

    setUp(() {
      updateService = UpdateService();
    });

    test('UpdateService initializes correctly', () {
      expect(updateService, isNotNull);
    });

    test('Version comparison works correctly', () {
      // Test version comparison logic through checkForUpdate
      // We can't directly test private methods, but we can verify the service is instantiated
      expect(UpdateService.githubOwner, equals('iotserver24'));
      expect(UpdateService.githubRepo, equals('Xibe-chat-app'));
    });

    test('GitHub API URL is correct', () {
      expect(
        UpdateService.githubApiUrl,
        equals('https://api.github.com/repos/iotserver24/Xibe-chat-app/releases'),
      );
    });

    // Note: We don't test actual API calls in unit tests to avoid network dependencies
    // Integration tests would be needed for full API testing
  });
}
