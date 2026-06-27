import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions have not been configured for windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web - Real data from Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCTHKCUrJfJxzGkaIn3_KPZDb3LLMqHuiU',
    appId: '1:360447188575:web:71364c643097f653e905ea',
    messagingSenderId: '360447188575',
    projectId: 'arabic-grammar-app-fa40d',
    authDomain: 'arabic-grammar-app-fa40d.firebaseapp.com',
    storageBucket: 'arabic-grammar-app-fa40d.firebasestorage.app',
    measurementId: 'G-8P6CBH7G3W',
  );

  // Android (placeholder until we add Android app)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTHKCUrJfJxzGkaIn3_KPZDb3LLMqHuiU',
    appId: '1:360447188575:android:placeholder',
    messagingSenderId: '360447188575',
    projectId: 'arabic-grammar-app-fa40d',
    storageBucket: 'arabic-grammar-app-fa40d.firebasestorage.app',
  );

  // iOS (placeholder until we add iOS app)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTHKCUrJfJxzGkaIn3_KPZDb3LLMqHuiU',
    appId: '1:360447188575:ios:placeholder',
    messagingSenderId: '360447188575',
    projectId: 'arabic-grammar-app-fa40d',
    storageBucket: 'arabic-grammar-app-fa40d.firebasestorage.app',
    iosBundleId: 'com.yourcompany.arabicGrammarApp',
  );

  // macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCTHKCUrJfJxzGkaIn3_KPZDb3LLMqHuiU',
    appId: '1:360447188575:ios:placeholder',
    messagingSenderId: '360447188575',
    projectId: 'arabic-grammar-app-fa40d',
    storageBucket: 'arabic-grammar-app-fa40d.firebasestorage.app',
    iosBundleId: 'com.yourcompany.arabicGrammarApp',
  );
}