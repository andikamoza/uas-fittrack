// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB2iHeh58xQo1LF5GGryIXECbENz4FXD58',
    authDomain: 'fittrack-fd3c9.firebaseapp.com',
    projectId: 'fittrack-fd3c9',
    storageBucket: 'fittrack-fd3c9.firebasestorage.app',
    messagingSenderId: '285741843512',
    appId: '1:285741843512:web:29e9891eacc0ab091fd2cd',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2iHeh58xQo1LF5GGryIXECbENz4FXD58',
    appId: '1:285741843512:web:29e9891eacc0ab091fd2cd',
    messagingSenderId: '285741843512',
    projectId: 'fittrack-fd3c9',
    storageBucket: 'fittrack-fd3c9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2iHeh58xQo1LF5GGryIXECbENz4FXD58',
    appId: '1:285741843512:web:29e9891eacc0ab091fd2cd',
    messagingSenderId: '285741843512',
    projectId: 'fittrack-fd3c9',
    storageBucket: 'fittrack-fd3c9.firebasestorage.app',
    iosBundleId: 'com.example.fittrack',
  );
}
