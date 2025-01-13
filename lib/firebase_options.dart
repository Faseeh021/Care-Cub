// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyAWMk9TCWycDJtQ-eUPbIPp46C18nV-TO8',
    appId: '1:913168016292:web:44cbb02a5689f63c511731',
    messagingSenderId: '913168016292',
    projectId: 'care-cub',
    authDomain: 'care-cub.firebaseapp.com',
    storageBucket: 'care-cub.firebasestorage.app',
    measurementId: 'G-SYG7B0K1K6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDW8FMwcbYcO4xNVq0e4trdjSFCW_B-W5s',
    appId: '1:913168016292:android:addb1b427a11f995511731',
    messagingSenderId: '913168016292',
    projectId: 'care-cub',
    storageBucket: 'care-cub.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrd9hRyU5SxgjRh4zEihEC0ou5u_we1kQ',
    appId: '1:913168016292:ios:61b2858076e74a59511731',
    messagingSenderId: '913168016292',
    projectId: 'care-cub',
    storageBucket: 'care-cub.firebasestorage.app',
    iosBundleId: 'com.example.carecub',
  );
}
