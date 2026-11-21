// File generated for AbsensiGo Firebase configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase belum dikonfigurasi untuk web. Jalankan flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase hanya dikonfigurasi untuk Android. Jalankan flutterfire configure untuk platform lain.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9f5y7AvIuicIx4se9vn53E3uS9Vhxbq4',
    appId: '1:144925243996:android:dc84324fdcc4a774260499',
    messagingSenderId: '144925243996',
    projectId: 'absensigo-pegawai-2611',
    storageBucket: 'absensigo-pegawai-2611.firebasestorage.app',
  );
}
