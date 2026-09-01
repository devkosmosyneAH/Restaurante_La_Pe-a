import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/Presentation/core/firebase/firebase_initializer.dart';

void main() {
  group('FirebaseAppInitializer', () {
    test('returns null options when dotenv is not initialized yet', () {
      expect(
        FirebaseAppInitializer.buildOptionsForCurrentPlatform(),
        isNull,
      );
    });

    test('loads env values when dotenv is available', () async {
      await dotenv.load(fileName: '.env');
      final options = FirebaseAppInitializer.buildOptionsForCurrentPlatform();
      expect(options, isNotNull);
    });
  });
}
