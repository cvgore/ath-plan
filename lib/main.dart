import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui';

import 'screens/home/screen.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void main() {
  //_firebaseMessaging.requestNotificationPermissions();
  _getFCMToken();
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: HomeScreen(),
    locale: window.locale
  ));
}

Future<void> _getFCMToken() async {
  var token = await _firebaseMessaging.getToken();
  print('FCM token: $token');
}
