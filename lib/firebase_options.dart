// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA9jl_hJhZLqA9IFAkryANCZCILCRav0QY',
    appId: '1:457074159595:web:980778591a46ddede8b3ae',
    messagingSenderId: '457074159595',
    projectId: 'isql-4dce5',
    authDomain: 'isql-4dce5.firebaseapp.com',
    storageBucket: 'isql-4dce5.appspot.com',
    measurementId: 'G-WCDGJ5Q3YY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALwHeahkxA4eKGtu2408dGIrp-4VT6f4o',
    appId: '1:457074159595:android:80b9761ba9ec905be8b3ae',
    messagingSenderId: '457074159595',
    projectId: 'isql-4dce5',
    storageBucket: 'isql-4dce5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2XuUVDYhfYUslnuRte7fj1OMP5Fx8ewQ',
    appId: '1:457074159595:ios:c5ebf7fbaae6b32ee8b3ae',
    messagingSenderId: '457074159595',
    projectId: 'isql-4dce5',
    storageBucket: 'isql-4dce5.appspot.com',
    androidClientId: '457074159595-24n202ssngq7a5h2c6glef7cje5q2lnt.apps.googleusercontent.com',
    iosClientId: '457074159595-326plmlsn4bnu1v9oet8ojqfiffgfgk3.apps.googleusercontent.com',
    iosBundleId: 'com.example.testimage',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD2XuUVDYhfYUslnuRte7fj1OMP5Fx8ewQ',
    appId: '1:457074159595:ios:c5ebf7fbaae6b32ee8b3ae',
    messagingSenderId: '457074159595',
    projectId: 'isql-4dce5',
    storageBucket: 'isql-4dce5.appspot.com',
    androidClientId: '457074159595-24n202ssngq7a5h2c6glef7cje5q2lnt.apps.googleusercontent.com',
    iosClientId: '457074159595-326plmlsn4bnu1v9oet8ojqfiffgfgk3.apps.googleusercontent.com',
    iosBundleId: 'com.example.testimage',
  );
}
