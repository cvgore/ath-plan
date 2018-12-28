import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'timetable.dart';
import '../group.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Group>> _groups;
//  Drawer _getNavDrawer(BuildContext context) {
//    var _headerChild = DrawerHeader(child: Text('ATH Plan'));
//    ListTile _getNavItem(var icon, String name, String routeName, String division) {
//      return ListTile(
//        leading: Icon(icon),
//        title: Text(name),
//        onTap: () {
//          setState(() {
//            Navigator.of(context).pop();
//            Navigator.of(context).push(MaterialPageRoute(
//              builder: (context) => DivisionScreen(division: division)
//            ));
//          });
//        },
//      );
//    }
//
//    var myNavChildren = [
//      _headerChild,
//      _getNavItem(
//        Icons.people,
//        'Wydział Automatyki i Robotyki',
//        DivisionScreen.routeName,
//        '81254'
//      )
//    ];
//
//    ListView listView = ListView(children: myNavChildren);
//
//    return Drawer(
//      child: listView,
//    );
//  }

  @override
  void initState() {
    super.initState();
    _groups = _getIndexes();
  }

  Future<List<Group>> _getIndexes() async {
    var data = await http.get('http://192.168.1.8');
    var json = jsonDecode(data.body);
    List<Group> temp = List();
    for (var i = 0; i < json.length; ++i) {
      temp.add(Group.fromJson(json[i]));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ATH Plan'),
      ),
      body: FutureBuilder<List<Group>>(
        future: _groups,
        builder: (context, snapshot) {
          if (snapshot.hasData || snapshot.hasError) {
            return Container(
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemExtent: null,
                  itemBuilder: (BuildContext _, int index) {
                    return ListTile(
                      leading: Icon(Icons.group),
                      title: Text(snapshot.data[index].name),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext _) => TimetableScreen(groupData: snapshot.data[index])
                        ));
                      },
                    );
                  },
                  itemCount: snapshot.data.length,
                )
            );
          }
          // By default, show a loading spinner
          return Center(child: CircularProgressIndicator());
        },
      ),
      // Set the nav drawer
      drawer: null, //_getNavDrawer(context),
    );
  }
}
