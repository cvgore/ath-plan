import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:core';

import '../../group.dart';
import '../../timetable.dart';

String _addMinsToDate(String date, int mins) {
  var newDate = DateTime.parse('1970-01-01 $date:00').add(Duration(minutes: mins));
  return '${_getPaddedZero(newDate.hour)}:${_getPaddedZero(newDate.minute)}';
}

class _ExerciseTypes {
  static const String CONSERVATOIRE = "CONSERVATOIRE";
  static const String LECTURE = "LECTURE";
  static const String EXERCISE = "EXERCISE";
  static const String LABORATORY = "LABORATORY";
  static const String PROJECT = "PROJECT";
  static const String LANG_COURSE = "LANG_COURSE";
  static const String PRACTICAL_LANG = "PRACTICAL_LANG";
  static const String WORK = "WORK";
  static const String RESERVED_LECTURE = "RESERVED_LECTURE";
  static const List<String> list = [
    _ExerciseTypes.EXERCISE,
    _ExerciseTypes.CONSERVATOIRE,
    _ExerciseTypes.LABORATORY,
    _ExerciseTypes.LANG_COURSE,
    _ExerciseTypes.WORK,
    _ExerciseTypes.PRACTICAL_LANG,
    _ExerciseTypes.PROJECT,
    _ExerciseTypes.LECTURE,
    _ExerciseTypes.RESERVED_LECTURE,
  ];

  static IconData getIconByType(String type) {
    switch(type) {
      case _ExerciseTypes.CONSERVATOIRE:
        return Icons.forum;
      case _ExerciseTypes.LECTURE:
        return Icons.hearing;
      case _ExerciseTypes.EXERCISE:
        return Icons.edit;
      case _ExerciseTypes.LABORATORY:
        return Icons.desktop_windows;
      case _ExerciseTypes.PROJECT:
        return Icons.insert_drive_file;
      case _ExerciseTypes.LANG_COURSE:
        return Icons.translate;
      case _ExerciseTypes.PRACTICAL_LANG:
        return Icons.mic;
      case _ExerciseTypes.WORK:
        return Icons.work;
      case _ExerciseTypes.RESERVED_LECTURE:
        return Icons.book;
    }
    return Icons.error_outline;
  }

  static String getLocalizedNameByType(String type) {
    switch(type) {
      case _ExerciseTypes.CONSERVATOIRE:
        return 'konwersatorium';
      case _ExerciseTypes.LECTURE:
        return 'wykład';
      case _ExerciseTypes.EXERCISE:
        return 'ćwiczenia';
      case _ExerciseTypes.LABORATORY:
        return 'laboratorium';
      case _ExerciseTypes.PROJECT:
        return 'projekt';
      case _ExerciseTypes.LANG_COURSE:
        return 'lektorat';
      case _ExerciseTypes.PRACTICAL_LANG:
        return 'praktyczna nauka języka';
      case _ExerciseTypes.WORK:
        return 'praca';
      case _ExerciseTypes.RESERVED_LECTURE:
        return 'wykład rezerwowany';
    }
    return null;
  }
}

class TimetableScreen extends StatefulWidget {
  static const String routeName = "/timetable";

  final Group groupData;

  TimetableScreen({Key key, @required this.groupData}) : super(key: key);

  @override
  _TimetableScreenState createState() => _TimetableScreenState(this.groupData);
}

class _TimetableScreenState extends State<TimetableScreen> {
  final Group groupData;
  final List<Tab> _weekDaysTabs = <Tab>[
    Tab(text: 'Pon'),
    Tab(text: 'Wto'),
    Tab(text: 'Śro'),
    Tab(text: 'Czw'),
    Tab(text: 'Pią'),
    Tab(text: 'Sob'),
    Tab(text: 'Nie')
  ];
  int _selectedWeek = 1;
  Future<Map<String, List<TimetableEntry>>> _timetable;
  int _weekDayIdx;
  List<String> _dateKeys = List();

  _TimetableScreenState(this.groupData) : super();



  @override
  void initState() {
    super.initState();
    _timetable = _getTimetable();
  }

  List<Widget> _getTabViewChildren(Map<String, List<TimetableEntry>> data) {
    var temp = List<Widget>();
    for(int i = 0; i < _weekDaysTabs.length; i++) {
      var subData = data[_dateKeys[i]] ?? List();
      if (subData.length == 0) {
        temp.add(_noData());
      } else {
        temp.add(ListView.builder(
            itemCount: subData.length,
            itemBuilder: (BuildContext itemContext, int idx) {
              var timetable = subData[idx];
              return ListTile(
                title: Text('${timetable.slug}'),
                subtitle: Text('Sala: ${timetable.room}'),
                trailing: Column(
                  children: <Widget>[
                    Text(timetable.timespan.start, style: Theme.of(context).textTheme.title),
                    Text(_addMinsToDate(timetable.timespan.start, timetable.timespan.length)),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
//                leading: IconButton(
//                  icon: ),
//                  onPressed: () {
//                    showModalBottomSheet(
//                        context: itemContext,
//                        builder: (BuildContext context) {
//                          return Container(
//                            child: _iconsHelp(),
//                          );
//                        }
//                      );
////                    Scaffold.of(itemContext).hideCurrentSnackBar();
////                    Scaffold.of(itemContext).showSnackBar(SnackBar(content: Text('Typ zajęć: ${_getExerciseTypeName(timetable.type)}')));
//                  },
                leading: Icon(_ExerciseTypes.getIconByType(timetable.type),
                ),
                onLongPress: () {
                  assert(() {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext builder) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(timetable.toJson().toString()),
                            ),
                          );
                        });
                    return true;
                  }());
                },
              );
            }
        ));
      }
    }
    return temp;
  }

  Future<Map<String, List<TimetableEntry>>> _getTimetable() async {
    var data = await http.get('https://ath-plan.liquard.tk/?group=${groupData.id}');
    var json = jsonDecode(data.body);
    return Timetable.fromJson(json).entries;
  }

  @override
  Widget build(BuildContext context) {
    _dateKeys.clear();
    var week = 7 * (-_selectedWeek + 1);
    _weekDayIdx = DateTime.now().add(Duration(days: week)).weekday - 1;
    var firstDayOfWeek = DateTime.now().subtract(Duration(days: week + DateTime.now().weekday - 1));
    for(int i = 0; i < 7; i++) {
      var curr = firstDayOfWeek.add(Duration(days: i));
      _dateKeys.add('${curr.year}-${_getPaddedZero(curr.month)}-${_getPaddedZero(curr.day)}');
    }
    return DefaultTabController(
      initialIndex: _weekDayIdx,
      length: _weekDaysTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(groupData.name),
          leading: IconButton(
            icon: BackButtonIcon(),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext builder) {
                    return _iconsHelp();
                  }
                );
              },
            )
//            PopupMenuButton<int>(
//              icon: Icon(Icons.more_vert),
//              itemBuilder: (BuildContext _) => <PopupMenuEntry<int>>[
//                PopupMenuItem(
//                  child: Text('Zmień tydzień'),
//                  value: 1,
//                ),
//                PopupMenuItem(
//                  child: Text('Objaśnienia'),
//                  value: 2,
//                )
//              ],
//              onSelected: (int option) {
//                switch(option) {
//                  case 2: {
//                    showModalBottomSheet(
//                      context: context,
//                      builder: (BuildContext builder) {
//                        return _iconsHelp();
//                      });
//                  }
//                }
//              },
//            )
          ],
          bottom: TabBar(
            tabs: _weekDaysTabs,
          ),
        ),
        body: FutureBuilder<Map<String, List<TimetableEntry>>>(
            future: _timetable,
            builder: (futureContext, snapshot) {
              if (snapshot.hasError) {
//                Scaffold.of(context).showSnackBar(
//                  SnackBar(
//                      content: Text('Nieudane pobranie planu')
//                  )
//                );
//                Navigator.of(context).pop();
              //throw snapshot.error;
                return Container(
                  child: Center(
                    child: Text('Nie można pobrać planu - ${snapshot.error}'),
                  ),
                );
              } else if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return _noData();
                }

                return TabBarView(
                  children: _getTabViewChildren(snapshot.data),
                );
              }
              // By default, show a loading spinner
              return Center(child: CircularProgressIndicator());
            }),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), title: Text(_getWeekText(-1))),
            BottomNavigationBarItem(icon: Icon(Icons.today), title: Text(_getWeekText(0))),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), title: Text(_getWeekText(1))),
          ],
          currentIndex: _selectedWeek,
          onTap: _changeWeek,
        ),
      )
    );
  }

  Widget _noData() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('\u{1F914}',
                style: TextStyle(fontSize: 128.0)
            ),
            Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('Brak zajęć?')
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconsHelp() {
    ListTile _getListTile(String type) {
      return ListTile(
        leading: Icon(_ExerciseTypes.getIconByType(type)),
        title: Text(_ExerciseTypes.getLocalizedNameByType(type)),
      );
    }

    ListTile _getHeader() {
      return ListTile(
        title: Text('Objaśnienia piktogramów', style: Theme.of(context).textTheme.body2),
      );
    }
    List<ListTile> helpData = _ExerciseTypes.list.map((t) => _getListTile(t)).toList();
    helpData.insert(0, _getHeader());
    return ListView(children: helpData);
  }

  void _changeWeek(int value) {
    setState(() {
      _selectedWeek = value;
    });
  }

  String _getWeekText(int i) {
    var wkStart = DateTime.now();
    wkStart = wkStart.add(Duration(days: 7 * i - wkStart.weekday + 1));
    var wkEnd = wkStart.add(Duration(days: 6));
    return '${_getPrettyPrintDayMonth(wkStart)} - ${_getPrettyPrintDayMonth(wkEnd)}';
  }
  
  String _getPrettyPrintDayMonth(DateTime dt) {
    return '${_getPaddedZero(dt.day)}.${_getPaddedZero(dt.month)}';
  }
}

String _getPaddedZero(int day) {
  return day.toString().padLeft(2, '0');
}
