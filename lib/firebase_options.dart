// firebase_options.dart

// firebase_options.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return FirebaseOptions(
        apiKey: 'AIzaSyDzxC3C3-_FItemd9z1EWwyUxV7PJeMONY',
        appId: '1:484192560115:android:6d281f843e432f58cea886',
        messagingSenderId: '484192560115',
        projectId: 'schrittzaehler-app',
        storageBucket: 'schrittzaehler-app.firebasestorage.app',
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return FirebaseOptions(
        apiKey: 'AIzaSyC7UZ3JkskPOSdtHuL8utQT3uHBLlAzId0',
        appId: '1:484192560115:ios:51f06af487b9bef3cea886',
        messagingSenderId: '484192560115',
        projectId: 'schrittzaehler-app',
        storageBucket: 'schrittzaehler-app.firebasestorage.app',
      );
    }
    throw UnsupportedError('Unsupported platform');
  }
}
