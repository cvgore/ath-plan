import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'groups_screen.dart';
// TODO: import 'info_screen.dart';
import 'my_groups_screen.dart';
import '../../fcm.dart';
import '../../common.dart';
import '../settings/screen.dart';

String _fcmToken = "";
bool _consentAgreed = false;

bool get consentAgreed {
  return _consentAgreed;
}

String get fcmToken {
  return _fcmToken ?? "";
}

const String GDPR_CONSENT_PREFS_KEY = 'gdpr_consent';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _screenIndex = 1;

  List<Widget> _cacheOfSubScreens = <Widget>[
    GroupsSubScreen(),
    MyGroupsSubScreen(),
    // TODO: InfoSubScreen()
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
          Builder(
            builder: (context) {
              return PopupMenuButton<_ActionPopupButton>(
                itemBuilder: (context) {
                  makeItem(String title, IconData icon, _ActionPopupButton option) => PopupMenuItem(
                    child: Row(children: <Widget>[
                      Icon(icon),
                      Padding(
                        child: Text(title),
                        padding: EdgeInsets.only(left: 4.0),
                      )
                    ]),
                    value: option,
                  );
                  return <PopupMenuItem<_ActionPopupButton>>[
                    makeItem('O aplikacji', Icons.info, _ActionPopupButton.SHOW_ABOUT_BOX),
                    makeItem('Wyczyść cache', Icons.delete_sweep, _ActionPopupButton.DROP_WHOLE_CACHE),
                    makeItem('Ustawienia', Icons.settings, _ActionPopupButton.SHOW_SETTINGS),
                  ];
                },
                onSelected: (value) {
                  switch(value) {
                    case _ActionPopupButton.DROP_WHOLE_CACHE:
                      FileCache.dropCache();
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pamięć podręczna została wyczyszczona')
                        )
                      );
                      return null;
                    case _ActionPopupButton.SHOW_ABOUT_BOX:
                      showAboutDialog(
                        context: context,
                        applicationVersion: '0.2.2',
                        applicationName: 'ATH Plan',
                        children: <Widget>[
                          Text('\u00A9 2019 cvgore'),
                          Text('Licensed under GPLv3.0'),
                          FlatButton(
                            child: Text('https://github.com/cvgore/ath-plan'),
                            onPressed: _openRepo,
                          )
                        ]
                      );
                      return null;
                    case _ActionPopupButton.SHOW_SETTINGS:
                      setState(() {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen()
                          ));
                      });
                      return null;
                  }
                },
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
          // TODO: BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('Informacje')),
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
      _consentAgreed = await showDialog<bool>(
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
                          'musisz wyrazić zgodę na przetwarzanie danych osobowych.'),
                      TextSpan(text: 'W celu dostarczenia powiadomienia zostaje użyty twój unikalny identyfikator instancji aplikacji.'),
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
      _consentAgreed = consent;
    }
    if (consentAgreed) {
      handleNotifications();
    }
  }

  Future<void> handleNotifications() async {
    g_firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
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
          if (data.containsKey('fullRefresh')) {
            FileCache.dropCache();
            setState(() {
              _cacheOfSubScreens = [
                GroupsSubScreen(),
                MyGroupsSubScreen(),
                // InfoSubScreen()
              ];
            });
          }
        }
      }, onLaunch: (fcmMsg) {}, onResume: (fcmMsg) {}
    );
  }

  void _showNotificationDlg(Map<String, dynamic> data) {
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

enum _ActionPopupButton {
  SHOW_ABOUT_BOX,
  SHOW_SETTINGS,
  DROP_WHOLE_CACHE
}