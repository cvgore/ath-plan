import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'groups_screen.dart';
import 'info_screen.dart';
import 'my_groups_screen.dart';
import '../../fcm.dart';
import '../../common.dart';

bool get consentAgreed {
  return HomeScreen._consentAgreed;
}

String get fcmToken {
  return HomeScreen._fcmToken ?? "";
}

const String GDPR_CONSENT_PREFS_KEY = 'gdpr_consent';

class HomeScreen extends StatefulWidget {
  static bool _consentAgreed = false;
  static String _fcmToken;

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
  void initState() {
    super.initState();
    tryGetFcmToken();
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

  Future<void> tryGetFcmToken() async {
    var prefs = await SharedPreferences.getInstance();
    var consent = prefs.getBool(GDPR_CONSENT_PREFS_KEY);
    if (consent == null) {
      debugPrint('Consent agreement required to FCM work, nor no notifications!');
      HomeScreen._consentAgreed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Zgoda RODO'),
            content: RichText(
                text: TextSpan(
                    text: 'Zgodnie z RODO musisz zostać poinformowany o przetwarzaniu danych.',
                    children: <TextSpan>[
                      TextSpan(text: 'Abyś mógł otrzymywać powiadomienia na swoje urządzenie, '
                          'musisz wyrazić zgodę na przetwarzanie danych osobowych (co za kuriozum).'),
                      TextSpan(text: 'W celu dostarczenia powiadomienia zostaje użyty twój identyfikator instancji aplikacji.'),
                      TextSpan(text: 'Swoją zgodę możesz zawsze cofnąć w Ustawieniach.'),
                    ]
                )
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Akceptuję'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              FlatButton(
                child: Text('Odrzucam'),
                onPressed: () => Navigator.of(context).pop(false),
              )
            ],
          );
        }
      );
      prefs.setBool(GDPR_CONSENT_PREFS_KEY, consentAgreed);
    } else {
      HomeScreen._consentAgreed = consent;
    }
    if (consentAgreed) {
      handleNotifications();
    }
  }

  Future<void> handleNotifications() async {
    g_firebaseMessaging.onTokenRefresh.listen((token) {
      HomeScreen._fcmToken = token;
      debugPrint('FCM token: $fcmToken');
    });
    g_firebaseMessaging.setAutoInitEnabled(true);
    g_firebaseMessaging.configure(
      onMessage: (fcmMsg) {
        if (fcmMsg.containsKey('notification')) {
          Map<String, dynamic> notification = fcmMsg['notification'];
          _showNotificationDlg(notification);
        }
        else if (fcmMsg.containsKey('data')) {
          Map<String, dynamic> data = fcmMsg['data'];
          if (data.containsKey('updateIndexes')) {
            //updateIndexes();
          }
        }
      }
    );
  }

  void _showNotificationDlg(Map<String, dynamic> data) {
    Scaffold.of(context).showSnackBar(
      SnackBar(content: Text(data['body']))
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text.rich(TextSpan(text: data['body'])),
          title: Text('Info: ${truncateIfExceeds(data['title'], 20)}'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      }
    );
  }
}