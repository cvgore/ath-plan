import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../group.dart';
import '../timetable/screen.dart';

class GroupsSubScreen extends StatefulWidget {
  GroupsSubScreen({Key key}): super(key: key);
  @override createState() => _GroupsSubScreenState();
}

class _GroupsSubScreenState extends State<GroupsSubScreen> {
  Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _getIndexes();
  }

  Future<List<Group>> _getIndexes() async {
    var data = await http.get('https://ath-plan.liquard.tk/');
    var json = jsonDecode(data.body);
    List<Group> _groups = List();
    for (var i = 0; i < json.length; ++i) {
      _groups.add(Group.fromJson(json[i]));
    }

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
              child: ListView.builder(
                itemExtent: null,
                itemBuilder: (BuildContext _, int index) {
                  return ListTile(
                    leading: Icon(Icons.group),
                    title: Text(data[index].name),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext _) => TimetableScreen(groupData: data[index])
                      ));
                    },
                  );
                },
                itemCount: data.length,
              ),
              onRefresh: () async {
                setState(() {
                  _groupsFuture = _getIndexes();
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