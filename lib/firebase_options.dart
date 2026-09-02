import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform: '
          '${defaultTargetPlatform.name}',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCyMYO7DLe4WlJeGeBkOJqjV5uHXHClFHQ',
    appId: '1:1062396228506:web:9ae562109a517ed7a38023',
    messagingSenderId: '1062396228506',
    projectId: 'restaura-a1e34',
    authDomain: 'restaura-a1e34.firebaseapp.com',
    databaseURL: 'https://restaura-a1e34-default-rtdb.firebaseio.com',
    storageBucket: 'restaura-a1e34.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCyMYO7DLe4WlJeGeBkOJqjV5uHXHClFHQ',
    appId: '1:1062396228506:android:9ae562109a517ed7a38023',
    messagingSenderId: '1062396228506',
    projectId: 'restaura-a1e34',
    storageBucket: 'restaura-a1e34.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKgFAFSMnds9QtrYug-lmvHIxozPqiX-E',
    appId: '1:1062396228506:ios:c605dc09121f94aaa38023',
    messagingSenderId: '1062396228506',
    projectId: 'restaura-a1e34',
    authDomain: 'restaura-a1e34.firebaseapp.com',
    databaseURL: 'https://restaura-a1e34-default-rtdb.firebaseio.com',
    storageBucket: 'restaura-a1e34.firebasestorage.app',
    iosBundleId: 'com.codigorestaurant.dev.codigoRestaurant',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCyMYO7DLe4WlJeGeBkOJqjV5uHXHClFHQ',
    appId: '1:1062396228506:web:9ae562109a517ed7a38023',
    messagingSenderId: '1062396228506',
    projectId: 'restaura-a1e34',
    authDomain: 'restaura-a1e34.firebaseapp.com',
    databaseURL: 'https://restaura-a1e34-default-rtdb.firebaseio.com',
    storageBucket: 'restaura-a1e34.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCyMYO7DLe4WlJeGeBkOJqjV5uHXHClFHQ',
    appId: '1:1062396228506:web:9ae562109a517ed7a38023',
    messagingSenderId: '1062396228506',
    projectId: 'restaura-a1e34',
    authDomain: 'restaura-a1e34.firebaseapp.com',
    databaseURL: 'https://restaura-a1e34-default-rtdb.firebaseio.com',
    storageBucket: 'restaura-a1e34.firebasestorage.app',
  );
}
