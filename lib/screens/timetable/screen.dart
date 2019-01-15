import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:core';

import '../../group.dart';
import '../../timetable.dart';
import '../../exercise_types.dart';

String _addMinsToDate(String date, int mins) {
  var newDate = DateTime.parse('1970-01-01 $date:00').add(Duration(minutes: mins));
  return '${_getPaddedZero(newDate.hour)}:${_getPaddedZero(newDate.minute)}';
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
                subtitle: Row(
                  children: <Widget>[
                    Padding(
                      child: Text(timetable.room, style: Theme.of(context).textTheme.body2),
                      padding: EdgeInsets.only(right: 4.0),
                    ),
                    Text('\u2022'),
                    Padding(
                      child: Text('${ExerciseTypes.getShortLocalNameByType(timetable.type)}'),
                      padding: EdgeInsets.only(left: 4.0),
                    ),
                  ],
                ),
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
                leading: Icon(ExerciseTypes.getIconByType(timetable.type),
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
    void _showDlg() {
      showDialog(context: context, builder: (dlgContext) {
        return AlertDialog(title: Text('Nie można pobrać planu'), content: Text('Wystąpił błąd podczas pobierania planu!'), actions: <Widget>[
          FlatButton(child: Text('Ok'), onPressed: () {
            Navigator.of(context).pop();
          })
        ]);
      }, barrierDismissible: false);
    }
    var data = await http.get('https://ath-plan.liquard.tk/?group=${groupData.id}');
    if (data.statusCode != 200) {
      _showDlg();
      return null;
    }
    try {
      var json = jsonDecode(data.body);
      var entries = Timetable.fromJson(json).entries;
      return entries;
    } on FormatException catch(ex) {
      debugPrint(ex.toString());
      _showDlg();
      return null;
    }
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
          ],
          bottom: TabBar(
            tabs: _weekDaysTabs,
          ),
        ),
        body: FutureBuilder<Map<String, List<TimetableEntry>>>(
            future: _timetable,
            builder: (futureContext, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  child: RichText(
                    text: TextSpan(
                      text: 'Wystąpił błąd podczas pobierania planu!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: snapshot.connectionState.toString()),
                        TextSpan(text: snapshot.error.toString()),
                      ]
                    )
                  )
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
        leading: Icon(ExerciseTypes.getIconByType(type)),
        title: Text(ExerciseTypes.getLocalizedNameByType(type)),
      );
    }

    ListTile _getHeader() {
      return ListTile(
        title: Text('Objaśnienia piktogramów', style: Theme.of(context).textTheme.body2),
      );
    }
    List<ListTile> helpData = ExerciseTypes.list.map((t) => _getListTile(t)).toList();
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
