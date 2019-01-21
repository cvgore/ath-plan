import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home/screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    ErrorWidget.builder = (FlutterErrorDetails err) {
      var head = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28.0, decoration: TextDecoration.none, fontFamily: "Roboto");
      var para = TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 16.0, decoration: TextDecoration.none, fontFamily: "Roboto");
      return Container(
        padding: EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0, bottom: 8.0),
        child: Column(
          children: <Widget>[
            Text('Coś poszło nie tak', style: head),
            Text('Exception: ${err.exceptionAsString()}', style: para),
            Text('Library: ${err.library}', style: para),
            Text('Context: ${err.context}', style: para),
            Text('Sample stack trace:', style: para),
            RichText(
              text: TextSpan(
                text: err.stack.toString(),
              ),
              maxLines: 20,
              overflow: TextOverflow.fade,
            ),
            FlatButton(
              child: Text('Zamknij'),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
            FlatButton(
              child: Text('Kopiuj błąd do schowka'),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: err.toString()),
                );
              },
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        )
      );
    };

    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomeScreen(),
      locale: window.locale,
    );
  }

}