import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';

import '../../group.dart';
import '../../timetable.dart';
import '../../exercise_types.dart';
import 'entry_tile.dart';
import '../../common.dart';

class TimetableScreen extends StatefulWidget {
  static const String routeName = "/timetable";
  final Group groupData;

  TimetableScreen({Key key, @required this.groupData}) : super(key: key);

  @override
  _TimetableScreenState createState() => _TimetableScreenState(this.groupData);
}

enum _TimetableDropdownMenu {
  ADD_REMOVE_FROM_MY_GROUPS,
  SHOW_PICTOGRAM_LEGEND,
  CUSTOM_WEEK,
  DOWNLOAD_TIMETABLE_FROM_SERVER,
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
  bool _isCustomWeek = false;
  // int _customWeek = 0;
  Future<Map<String, List<TimetableEntry>>> _timetable;
  int _weekDayIdx;
  List<String> _dateKeys = List();
  SharedPreferences _prefs;

  _TimetableScreenState(this.groupData) : super();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
    _timetable = _getTimetable();
  }

  List<Widget> _getTabViewChildren(Map<String, List<TimetableEntry>> data) {
    var temp = List<Widget>();
    for (int i = 0; i < _weekDaysTabs.length; i++) {
      var subData = data[_dateKeys[i]] ?? List();
      if (subData.length == 0) {
        temp.add(_noData());
      } else {
        temp.add(Scrollbar(child: ListView.builder(
            itemCount: subData.length,
            itemBuilder: (BuildContext itemContext, int idx) {
              return EntryTile(subData[idx]);
            })));
      }
    }
    return temp;
  }

  void _showErrorWhileFetching() {
    showDialog(
        context: context,
        builder: (dlgContext) {
          return AlertDialog(
              title: Text('Nie można pobrać planu'),
              content: Text('Wystąpił błąd podczas pobierania planu!'),
              actions: <Widget>[
                FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context)..pop()..pop();
                    })
              ]);
        },
        barrierDismissible: false);
  }

  Future<Map<String, List<TimetableEntry>>> _getTimetable({ forceRefresh: false, fake: false }) async {
    if (fake == true) {
      return _timetable;
    }
    _tryGetTimetableFromCache() async {
      var file = await FileCache.getFile(FilePaths.timetableCache(this.groupData.id));
      var data = await file.readAsString();
      try {
        var json = jsonDecode(data);
        return data;
      } catch(ex) {}
      return null;
    }
    var data;
    if (!forceRefresh) {
      data = await _tryGetTimetableFromCache();
      if (data == null) {
        debugPrint('Failed to fetch timetable from cache');
        return _getTimetable(forceRefresh: true);
      }
    } else {
      data = await http.get('https://ath-plan.liquard.tk?group=${this.groupData.id}/');
    }
    if (data is http.Response) {
      if (data.statusCode != 200) {
        //_showErrorWhileFetching();
        return null;
      }
      data = data.body;
      var file = await FileCache.getFile(FilePaths.timetableCache(this.groupData.id));
      await file.writeAsString(data);
    }

    return await compute(_parseTimetable, (data as String));
  }

  @override
  Widget build(BuildContext context) {
    _dateKeys.clear();
    var week = 7 * (-_selectedWeek + 1);
    _weekDayIdx = DateTime.now().add(Duration(days: week)).weekday - 1;
    var firstDayOfWeek = DateTime.now()
        .subtract(Duration(days: week + DateTime.now().weekday - 1));
    for (int i = 0; i < 7; i++) {
      var curr = firstDayOfWeek.add(Duration(days: i));
      _dateKeys.add(
          '${curr.year}-${getPaddedZero(curr.month)}-${getPaddedZero(curr.day)}');
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
              Builder(
                builder: (BuildContext context) {
                  return PopupMenuButton<_TimetableDropdownMenu>(
                    itemBuilder: _makePopupMenuItems,
                    onSelected: (item) {
                      switch(item) {
                        case _TimetableDropdownMenu.SHOW_PICTOGRAM_LEGEND:
                          showModalBottomSheet(context: context, builder: (context) => _iconsHelp());
                          return null;
                        case _TimetableDropdownMenu.CUSTOM_WEEK:
//                          TODO: showDialog(
//                            context: context,
//                            builder: (context) => AlertDialog(
//                              title: Text('Wybierz tydzień'),
//                              content: Center(
//                                child: DropdownButton(
//                                  items: _getAllAvailableWeeks(),
//                                  onChanged: (value) {
//                                    setState(() {
//                                      _customWeek = value;
//                                      _isCustomWeek = true;
//                                    });
//                                  }
//                                ),
//                              ),
//                            )
//                          );
                          return null;
                        case _TimetableDropdownMenu.DOWNLOAD_TIMETABLE_FROM_SERVER:
                          _refetchTimetable();
                          return null;
                        case _TimetableDropdownMenu.ADD_REMOVE_FROM_MY_GROUPS:
                          _addOrRemoveFromMyGroups();
                          return null;
                      }
                    },
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
                  debugPrint('Error while fetching plan data');
                  debugPrint(
                      'ConnState: ${snapshot.connectionState.toString()}');
                  debugPrint('Err: ${snapshot.error.toString()}');
                  //_showErrorWhileFetching();
                  return _noData();
                } else if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  title: Text(_getWeekText(-1))),
              BottomNavigationBarItem(
                  icon: Icon(Icons.today), title: Text(_getWeekText(0))),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  title: Text(_getWeekText(1))),
            ],
            currentIndex: _selectedWeek,
            onTap: _changeWeek,
          ),
        ));
  }

  Widget _noData() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _getImageNoTimetable(),
            Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('Brak zajęć?')),
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
        title: Text('Objaśnienia piktogramów',
            style: Theme.of(context).textTheme.body2),
      );
    }

    List<ListTile> helpData =
        ExerciseTypes.list.map((t) => _getListTile(t)).toList();
    helpData.insert(0, _getHeader());
    return Scrollbar(child: ListView(children: helpData));
  }

  void _changeWeek(int value) {
    setState(() {
      if (_isCustomWeek) {
        _isCustomWeek = false;
      }
      _selectedWeek = value;
      _timetable = _getTimetable(fake: true);
    });
  }

  String _getWeekText(int i) {
    var wkStart = DateTime.now();
    wkStart = wkStart.add(Duration(days: 7 * i - wkStart.weekday + 1));
    var wkEnd = wkStart.add(Duration(days: 6));
    return '${_getPrettyPrintDayMonth(wkStart)} - ${_getPrettyPrintDayMonth(wkEnd)}';
  }

  String _getPrettyPrintDayMonth(DateTime dt) {
    return '${getPaddedZero(dt.day)}.${getPaddedZero(dt.month)}';
  }

  List<PopupMenuItem<_TimetableDropdownMenu>> _makePopupMenuItems(BuildContext context) {
    makeItem(String title, IconData icon, _TimetableDropdownMenu option) => PopupMenuItem(
      child: Row(children: <Widget>[
        Icon(icon),
        Padding(
          child: Text(title),
          padding: EdgeInsets.only(left: 4.0),
        )
      ]),
      value: option,
    );

    return [
      makeItem('Dodaj do moich grup', Icons.favorite, _TimetableDropdownMenu.ADD_REMOVE_FROM_MY_GROUPS),
      makeItem('Objaśnienia piktogramów...', Icons.help, _TimetableDropdownMenu.SHOW_PICTOGRAM_LEGEND),
      makeItem('Pobierz plan z serwera', Icons.cloud_download, _TimetableDropdownMenu.DOWNLOAD_TIMETABLE_FROM_SERVER),
      // TODO: makeItem('Wybierz tydzień...', Icons.cloud_download, _TimetableDropdownMenu.CUSTOM_WEEK),
    ];
  }

  _getImageNoTimetable() {
    if (_prefs != null && _prefs.getBool('is-surprise') == true) {
      return Image.asset("assets/images/1337.png",
        width: 169.0,
        repeat: ImageRepeat.noRepeat,
        fit: BoxFit.contain);
    } else {
      return Center(
        child: Text('\u{1F914}',
          style: TextStyle(
            fontSize: 128.0
          ),
        )
      );
    }
  }

  _addOrRemoveFromMyGroups() async {
    var file = await FileCache.getFile(FilePaths.OWN_GROUPS);
    List<Group> groups;
    try {
      var tmp = jsonDecode(await file.readAsString());
      groups = tmp.map((el) => Group.fromJson(el)).toList();
    } catch(ex) {
      groups = List();
    }

    if (groups.indexOf(this.groupData) > -1) {
      // do nothing
    } else {
      groups.add(this.groupData);
      file.writeAsString(jsonEncode(groups));
    }
  }

  _refetchTimetable() {
    setState(() {
      _timetable = _getTimetable(forceRefresh: true);
    });
  }

// TODO:  _getAllAvailableWeeks() {
//    return _.map((v) => DropdownMenuItem(child: Text(v))).toList();
//  }

}

Map<String, List<TimetableEntry>> _parseTimetable(String data) {
  try {
    var json = jsonDecode(data);
    return Timetable.fromJson(json).entries;
  } on FormatException catch (ex) {
    debugPrint(ex.toString());
    //_showErrorWhileFetching();
    return null;
  }
}
