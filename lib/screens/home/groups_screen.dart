import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../group.dart';
import '../timetable/screen.dart';
import '../../common.dart';

class GroupsSubScreen extends StatefulWidget {
  GroupsSubScreen({Key key}): super(key: key);
  @override createState() => _GroupsSubScreenState();
}

class _GroupsSubScreenState extends State<GroupsSubScreen> {
  Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _getIndex();
  }

  Future<List<Group>> _getIndex({ forceRefresh: false }) async {
    _tryGetIndexFromCache() async {
      var file = await FileCache.getFile(FilePaths.INDEX_CACHE);
      var data = await file.readAsString();
      try {
        var json = jsonDecode(data);
        return data;
      } catch(ex) {}
      return null;
    }
    var data;
    if (!forceRefresh) {
      data = await _tryGetIndexFromCache();
      if (data == null) {
        return _getIndex(forceRefresh: true);
      }
    } else {
      data = (await http.get('https://ath-plan.liquard.tk/')).body;
    }
    var json = jsonDecode(data);
    if (json is! List) {
      throw FormatException('Not a list', json);
    }
    List<Group> _groups = List();
    for (var i = 0; i < json.length; ++i) {
      _groups.add(Group.fromJson(json[i]));
    }
    var file = await FileCache.getFile(FilePaths.INDEX_CACHE);
    file.writeAsString(jsonEncode(_groups));

    return _groups;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: _groupsFuture,
      builder: _futureBuilder
    );
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
    if (snapshot.hasData || snapshot.hasError) {
      List<Group> data = List.from(snapshot.data);
      return Container(
          child: RefreshIndicator(
              child: Scrollbar(
                child: ListView.builder(
                itemExtent: null,
                itemBuilder: (context, int idx) {
                  return ListTile(
                    leading: Icon(Icons.group),
                    title: Text(data[idx].name),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext _) => TimetableScreen(groupData: data[idx])
                      ));
                    },
                  );
                },
                itemCount: data.length,
              )),
              onRefresh: () async {
                setState(() {
                  _groupsFuture = _getIndex(forceRefresh: true);
                });
                return true;
              }
          )
      );
    }
    // By default, show a loading spinner
    return Center(child: CircularProgressIndicator());
  }
}