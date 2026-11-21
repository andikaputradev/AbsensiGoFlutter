// File generated for AbsensiGo Firebase configuration.
// ignore_for_file: type=lint
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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgquQR1D-dFQqY4U8-4smLj2LE8jO2FpA',
    appId: '1:773384333750:android:f5ad31f926b0fdd4103917',
    messagingSenderId: '773384333750',
    projectId: 'absensigo-8291f',
    storageBucket: 'absensigo-8291f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgquQR1D-dFQqY4U8-4smLj2LE8jO2FpA',
    appId: '1:773384333750:ios:f5ad31f926b0fdd4103917',
    messagingSenderId: '773384333750',
    projectId: 'absensigo-8291f',
    storageBucket: 'absensigo-8291f.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgquQR1D-dFQqY4U8-4smLj2LE8jO2FpA',
    appId: '1:773384333750:web:f5ad31f926b0fdd4103917',
    messagingSenderId: '773384333750',
    projectId: 'absensigo-8291f',
    storageBucket: 'absensigo-8291f.appspot.com',
  );
}
