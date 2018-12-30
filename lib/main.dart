import 'package:flutter/material.dart';
import 'dart:ui';

import 'screens/home.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: HomeScreen(),
    locale: window.locale
  ));
}
