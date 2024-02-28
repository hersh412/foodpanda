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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjBNUuVJCQtFOxcxIzc9vn486H7vZskI0',
    appId: '1:15378492872:android:857abeeefeb77a83e0a4fd',
    messagingSenderId: '15378492872',
    projectId: 'food-panda-af406',
    storageBucket: 'food-panda-af406.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRuSeUgMAdXj68r0SOwAG7aJ4xsCu2-rw',
    appId: '1:15378492872:ios:63a319b1ed78439be0a4fd',
    messagingSenderId: '15378492872',
    projectId: 'food-panda-af406',
    storageBucket: 'food-panda-af406.appspot.com',
    iosBundleId: 'com.example.sellerApp1234',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRuSeUgMAdXj68r0SOwAG7aJ4xsCu2-rw',
    appId: '1:15378492872:ios:317eb3e37234d4f1e0a4fd',
    messagingSenderId: '15378492872',
    projectId: 'food-panda-af406',
    storageBucket: 'food-panda-af406.appspot.com',
    iosBundleId: 'com.example.sellerApp.RunnerTests',
  );
}