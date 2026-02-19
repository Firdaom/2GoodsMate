// ไฟล์นี้ถูกสร้างโดยอัตโนมัติจากคำสั่ง:
// `flutterfire configure`
// 
// ควรรันคำสั่งนี้ใหม่เพื่ออัพเดต Firebase configuration ตามโปรเจคของคุณ

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

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
        throw UnsupportedError('DefaultFirebaseOptions has not been configured for linux - please reconfigure this and try again.');
      default:
        throw UnsupportedError('DefaultFirebaseOptions.currentPlatform is not supported on this platform.');
    }
  }

  // ⚠️ สำหรับการพัฒนา Android — ต้องเพิ่มค่า Android Firebase options ที่นี่

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBV6wxCpzCJBecaExcIBK0o23nTvgQEEUA',
    appId: '1:713509545032:android:b3508e70fe0b62a6b8a47d',
    messagingSenderId: '713509545032',
    projectId: 'goodsmate-94866',
    storageBucket: 'goodsmate-94866.firebasestorage.app',
  );

  // ใช้คำสั่ง: flutterfire configure

  // ⚠️ สำหรับการพัฒนา Web — ต้องเพิ่มค่า Web Firebase options ที่นี่

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBk7S93P1HZihDXZSb4YujWf-xswNmu7Vc',
    appId: '1:713509545032:web:28ddd0455bb1e864b8a47d',
    messagingSenderId: '713509545032',
    projectId: 'goodsmate-94866',
    authDomain: 'goodsmate-94866.firebaseapp.com',
    storageBucket: 'goodsmate-94866.firebasestorage.app',
    measurementId: 'G-QLS0RMR7BY',
  );

  // ใช้คำสั่ง: flutterfire configure

  // ⚠️ สำหรับการพัฒนา iOS — ต้องเพิ่มค่า iOS Firebase options ที่นี่
  // ใช้คำสั่ง: flutterfire configure
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    databaseURL: 'YOUR_DATABASE_URL',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  // ⚠️ สำหรับการพัฒนา macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    databaseURL: 'YOUR_DATABASE_URL',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'YOUR_MACOS_BUNDLE_ID',
  );

  // ⚠️ สำหรับการพัฒนา Windows
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    databaseURL: 'YOUR_DATABASE_URL',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}