import "package:firebase_core/firebase_core.dart" show FirebaseOptions;
import "package:flutter/foundation.dart"
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
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          "DefaultFirebaseOptions are not supported for this platform.",
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
  apiKey: "AIzaSyDhkwlNstB1_urQIR-MuFXuhWoLVbBnxOE",
  authDomain: "gemechis-cef27.firebaseapp.com",
  projectId: "gemechis-cef27",
  storageBucket: "gemechis-cef27.firebasestorage.app",
  messagingSenderId: "923218740500",
  appId: "1:923218740500:web:b89d56691dcb227883ee01",
  measurementId: "G-LE4F7YVHVS"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDOCAbC123dEf456GhI789jKl012-MnO",
    appId: "1:000000000000:android:0000000000000000000000",
    messagingSenderId: "000000000000",
    projectId: "gemechis-cef27",
    storageBucket: "gemechis-cef27.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDOCAbC123dEf456GhI789jKl012-MnO",
    appId: "1:000000000000:ios:0000000000000000000000",
    messagingSenderId: "000000000000",
    projectId: "gemechis-cef27",
    storageBucket: "gemechis-cef27.appspot.com",
    iosBundleId: "com.example.weedduagalataa",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyDOCAbC123dEf456GhI789jKl012-MnO",
    appId: "1:000000000000:macos:0000000000000000000000",
    messagingSenderId: "000000000000",
    projectId: "gemechis-cef27",
    storageBucket: "gemechis-cef27.appspot.com",
  );
}
