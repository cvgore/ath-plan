import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../group.dart';
import '../timetable.dart';

class TimetableScreen extends StatefulWidget {
  static const String routeName = "/timetable";

  final Group groupData;

  TimetableScreen({Key key, @required this.groupData}) : super(key: key);

  @override
  _TimetableScreenState createState() => _TimetableScreenState(this.groupData);
}

class _TimetableScreenState extends State<TimetableScreen> {
  final Group groupData;
  Future<List<Timetable>> _timetable;

  _TimetableScreenState(this.groupData): super();

  @override
  void initState() {
    super.initState();
    _timetable = _getTimetable();
  }

  Future<List<Timetable>> _getTimetable() async {
    var data = await http.get('http://192.168.1.8?group=${groupData.id}');
    var json = jsonDecode(data.body);
    List<Timetable> temp = List();
//    for (var i = 0; i < json.length; ++i) {
//      temp.add(Timetable.fromJson(json[i]));
//    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
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
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (BuildContext _) => <PopupMenuEntry>[
                PopupMenuItem(
                  child: Text('Zmień tydzień'),
                  value: 1,
                )
              ],
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pon'),
              Tab(text: 'Wto'),
              Tab(text: 'Śro'),
              Tab(text: 'Czw'),
              Tab(text: 'Pią')
            ],
          ),
        ),
        body: FutureBuilder<List<Timetable>>(
          future: _timetable,
          builder: (context, snapshot) {
            if (snapshot.hasData || snapshot.hasError) {
              if (snapshot.data.length == 0) {
                return Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('\u{1F914}', style: TextStyle(fontSize: 128.0)),
                        Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text('Brak zajęć?')
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Container(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemExtent: null,
                    itemBuilder: (BuildContext _, int index) {
                      return ListTile(
                          title: Text(snapshot.data[index].summary),
                          subtitle: Text('${snapshot.data[index].starts.toString()} - ${snapshot.data[index].ends.toString()}')
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
      )
    );
  }
}
