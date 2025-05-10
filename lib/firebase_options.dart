import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Bu platform için Firebase ayarları yok: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDC66qSzlDgskMhZolsoJIbc9IS9V7f-WM",
    authDomain: "akilli-doktor-asistani-2a135.firebaseapp.com",
    projectId: "akilli-doktor-asistani-2a135",
    storageBucket: "akilli-doktor-asistani-2a135.appspot.com",
    messagingSenderId: "279388429798",
    appId: "1:279388429798:web:3cb621f6455afc4c32a827",
    measurementId: "G-4EQL08FNL",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDC66qSzlDgskMhZolsoJIbc9IS9V7f-WM",
    appId: "1:279388429798:android:8e0e7e5d7e4b3328a27",
    messagingSenderId: "279388429798",
    projectId: "akilli-doktor-asistani-2a135",
    storageBucket: "akilli-doktor-asistani-2a135.appspot.com",
  );
}
