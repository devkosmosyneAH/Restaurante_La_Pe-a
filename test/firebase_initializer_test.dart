import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/Presentation/core/firebase/firebase_initializer.dart';

void main() {
  group('FirebaseAppInitializer', () {
    test('returns default Firebase options for the current platform', () {
      final options = FirebaseAppInitializer.buildOptionsForCurrentPlatform();
      expect(options, isNotNull);
      expect(options.apiKey, isNotEmpty);
      expect(options.projectId, isNotEmpty);
    });
  });
}
