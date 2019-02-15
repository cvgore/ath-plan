import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../timetable/screen.dart';
import '../../group.dart';
import '../../common.dart';

class MyGroupsSubScreen extends StatefulWidget {
  MyGroupsSubScreen({Key key}): super(key: key);
  @override createState() => _MyGroupsSubScreenState();
}

class _MyGroupsSubScreenState extends State<MyGroupsSubScreen> {
  Future<List<Group>> _groupsFuture;
  List<Group> _groups = List();

  @override
  void initState() {
    super.initState();
    _groupsFuture = _getGroups();
  }

  Future<List<Group>> _getGroups() async {
    _groups = List();
    var file = await FileCache.getFile(FilePaths.OWN_GROUPS);
    try {
      var groups = jsonDecode(await file.readAsString());
      if (groups is Iterable) {
        _groups = groups.map((el) => Group.fromJson(el)).toList();
      }
    } on FormatException {
//      Scaffold.of(context).showSnackBar(
//        SnackBar(
//          content: Text('Wystąpił błąd, twoje grupy nie mogą zostać wyświetlone'),
//        )
//      );
    }
    return _groups;
  }

  ListTile _getGroupTile(Group data, int index) {
    return ListTile(
        leading: Icon(Icons.bookmark),
        title: Text(data.name),
        onTap: () {
          setState(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TimetableScreen(groupData: data)));
          });
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) =>
              AlertDialog(
                title: Text('Usuń grupę'),
                content: Text("Czy na pewno chcesz usunąć grupę '${data.name}' ze swoich grup?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Usuń'),
                    onPressed: () {
                      _groups.removeAt(index);
                      _saveGroups();
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                  FlatButton(
                    child: Text('Anuluj'),
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                  )
                ],
              )
          );
        });
  }

  Future<void> _saveGroups() async {
    var file = await FileCache.getFile(FilePaths.OWN_GROUPS);
    await file.writeAsString(jsonEncode(_groups));
    setState(() {
      _groupsFuture = _getGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length < 1) {
            return RefreshIndicator(
              child: Center(
                child: Text('Brak twoich grup'),
              ),
              onRefresh: () async {
                setState(() {
                  _groupsFuture = _getGroups();
                });
              },
            );
          }
          List<Group> data = List.from(snapshot.data);
          return RefreshIndicator(
            child: Container(
              child: ListView.builder(
                itemExtent: null,
                itemBuilder: (BuildContext _, int index) {
                  return _getGroupTile(data[index], index);
                },
                itemCount: data.length,
              ),
            ),
            onRefresh: () async {
              setState(() {
                _groupsFuture = _getGroups();
              });
            },
          );
        } else if (snapshot.hasError) {
          return RefreshIndicator(
            child: Center(
            child: Text('Twoje grupy są niedostępne')
            ),
            onRefresh: () async {
              setState(() {
                _groupsFuture = _getGroups();
              });
            },
          );
        }
        // By default, show a loading spinner
        return Center(child: CircularProgressIndicator());
      });
  }
}
