import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'groups_screen.dart';
import 'info_screen.dart';
import 'my_groups_screen.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _screenIndex = 0;

  final List<Widget> _cacheOfSubScreens = <Widget>[
    GroupsSubScreen(),
    MyGroupsSubScreen(),
    InfoSubScreen()
  ];

  _openRepo() async {
    const url = 'https://github.com/cvgore/ath-plan';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ATH Plan'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationVersion: '0.1.0',
                applicationName: 'ATH Plan',
                children: <Widget>[
                  Text('\u00A9 2018 cvgore'),
                  Text('Licensed under GPLv3.0'),
                  FlatButton(
                    child: Text('https://github.com/cvgore/ath-plan'),
                    onPressed: _openRepo,
                  )
                ]
              );
            },
          )
        ],
      ),
      body: _cacheOfSubScreens[_screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.group), title: Text('Grupy')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Moje grupy')),
          BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('Informacje')),
        ],
        currentIndex: _screenIndex,
        onTap: (int index) {
          setState(() {
            _screenIndex = index;
          });
        },
      ),
    );
  }
}