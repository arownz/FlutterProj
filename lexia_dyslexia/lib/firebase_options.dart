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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBoVgYeTEpEkqrH0OA_UMbl1oZLvTuWMA0",
    authDomain: "teamlexia-46228.firebaseapp.com",
    databaseURL: "https://teamlexia-46228-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "teamlexia-46228",
    storageBucket: "teamlexia-46228.firebasestorage.app",
    messagingSenderId: "746497205021",
    appId: "1:746497205021:android:1615d063c9d8c03522b7f4",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBoVgYeTEpEkqrH0OA_UMbl1oZLvTuWMA0",
    appId: "1:746497205021:android:1615d063c9d8c03522b7f4",
    messagingSenderId: "746497205021",
    projectId: "teamlexia-46228",
    databaseURL: "https://teamlexia-46228-default-rtdb.asia-southeast1.firebasedatabase.app",
    storageBucket: "teamlexia-46228.firebasestorage.app",
  );
}
