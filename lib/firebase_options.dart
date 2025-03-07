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
    apiKey: 'AIzaSyDB-nTSoJYNEb-OVY9VtgICnZcSFtdTVbw',
    appId: '1:428973781436:web:11094c041b660f814cfbb9',
    messagingSenderId: '428973781436',
    projectId: 'tour-management-app-29401',
    authDomain: 'tour-management-app-29401.firebaseapp.com',
    storageBucket: 'tour-management-app-29401.firebasestorage.app',
    measurementId: 'G-GVSDPS5HKC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmexmMfixlfeudw8jaXr6ofVSMZHSeO5I',
    appId: '1:428973781436:android:1e762d66dce3d9ea4cfbb9',
    messagingSenderId: '428973781436',
    projectId: 'tour-management-app-29401',
    storageBucket: 'tour-management-app-29401.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCKfE9OGA65nfGIxKxDiE8T_jOYBn1yDhU',
    appId: '1:428973781436:ios:968edf8358c349094cfbb9',
    messagingSenderId: '428973781436',
    projectId: 'tour-management-app-29401',
    storageBucket: 'tour-management-app-29401.firebasestorage.app',
    iosBundleId: 'com.tourmanagement.tourManagementApp',
  );
}
