import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ Web configuration - CORRECT API KEY
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCTHKCUrJfJxzGkaln3_KPfZb3lLMqHuiU',
    appId: '1:360447188575:web:71364c643097f653e905ea',
    messagingSenderId: '360447188575',
    projectId: 'arabic-grammar-app-fa40d',
    authDomain: 'arabic-grammar-app-fa40d.firebaseapp.com',
    storageBucket: 'arabic-grammar-app-fa40d.firebasestorage.app',
    measurementId: 'G-8P6CBH7G3W',
  );

  // Android configuration (keep your existing values)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTHKCUrJfJxzGkaln3_KPfZb3lLMqHuiU',
    appId: '1:360447188575:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '360447188575',
    projectId: 'arabic-grammar-app-fa40d',
    storageBucket: 'arabic-grammar-app-fa40d.firebasestorage.app',
  );

  // iOS configuration (keep your existing values)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTHKCUrJfJxzGkaln3_KPfZb3lLMqHuiU',
    appId: '1:360447188575:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '360447188575',
    projectId: 'arabic-grammar-app-fa40d',
    storageBucket: 'arabic-grammar-app-fa40d.firebasestorage.app',
    iosBundleId: 'com.example.arabicGrammarApp',
  );

  // macOS configuration (same as iOS)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCTHKCUrJfJxzGkaln3_KPfZb3lLMqHuiU',
    appId: '1:360447188575:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: '360447188575',
    projectId: 'arabic-grammar-app-fa40d',
    storageBucket: 'arabic-grammar-app-fa40d.firebasestorage.app',
    iosBundleId: 'com.example.arabicGrammarApp',
  );
}