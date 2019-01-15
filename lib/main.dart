import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'fcm.dart';
import 'dart:ui';

import 'screens/home/screen.dart';

void main() {
  _getFCMToken();
  g_firebaseMessaging.configure(
    onMessage: (fcmMsg) {
      if (fcmMsg.containsKey('data')) {
        Map<String, dynamic> recvData = fcmMsg['data'];
        if (recvData.containsKey('updateIndexes')) {
          //updateIndexes();
        }
      }
    }
  );
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: HomeScreen(),
    locale: window.locale
  ));
}

Future<void> _getFCMToken() async {
  var token = await g_firebaseMessaging.getToken();
  debugPrint('FCM token: $token');
}
