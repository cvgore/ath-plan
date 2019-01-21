import 'dart:ui';
import 'package:flutter/material.dart';

import 'screens/home/screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomeScreen(),
      locale: window.locale,
    );
  }



}