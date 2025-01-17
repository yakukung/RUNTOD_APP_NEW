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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyA-tj1o0KovqtUDFdjs2lK5pXvUJRkwSW4',
    appId: '1:863376903260:web:e72065d12fa4dde426aa99',
    messagingSenderId: '863376903260',
    projectId: 'runtod-delivery',
    authDomain: 'runtod-delivery.firebaseapp.com',
    storageBucket: 'runtod-delivery.appspot.com',
    measurementId: 'G-JN2XFFHMQE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZ1Fdj9T62UBzR8t0TrThiZbu9ETvClNM',
    appId: '1:863376903260:android:6e75fd708ee6b9c126aa99',
    messagingSenderId: '863376903260',
    projectId: 'runtod-delivery',
    storageBucket: 'runtod-delivery.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOoz-Uz33y4CPDvyN_dDf4grbboGTMPhg',
    appId: '1:863376903260:ios:c4c16903cc02f36126aa99',
    messagingSenderId: '863376903260',
    projectId: 'runtod-delivery',
    storageBucket: 'runtod-delivery.appspot.com',
    iosBundleId: 'com.example.runtodApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBOoz-Uz33y4CPDvyN_dDf4grbboGTMPhg',
    appId: '1:863376903260:ios:c4c16903cc02f36126aa99',
    messagingSenderId: '863376903260',
    projectId: 'runtod-delivery',
    storageBucket: 'runtod-delivery.appspot.com',
    iosBundleId: 'com.example.runtodApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA-tj1o0KovqtUDFdjs2lK5pXvUJRkwSW4',
    appId: '1:863376903260:web:fd73a6f4d1b9278e26aa99',
    messagingSenderId: '863376903260',
    projectId: 'runtod-delivery',
    authDomain: 'runtod-delivery.firebaseapp.com',
    storageBucket: 'runtod-delivery.appspot.com',
    measurementId: 'G-MGDCT26XTG',
  );
}
