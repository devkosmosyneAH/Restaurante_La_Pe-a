import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/Presentation/core/firebase/firebase_initializer.dart';

Future<void> loadAnyAvailableEnvFile() async {
  final candidates = ['.env', 'assets/env.txt'];

  for (final path in candidates) {
    try {
      await dotenv.load(fileName: path);
      return;
    } on Object {
      // Intentionally ignored: the test will continue with the next candidate.
    }
  }
}

void main() {
  group('FirebaseAppInitializer', () {
    test('returns null options when dotenv is not initialized yet', () {
      expect(
        FirebaseAppInitializer.buildOptionsForCurrentPlatform(),
        isNull,
      );
    });

    test('loads env values when dotenv is available', () async {
      await loadAnyAvailableEnvFile();
      final options = FirebaseAppInitializer.buildOptionsForCurrentPlatform();
      expect(options, isNotNull);
    });
  });
}
