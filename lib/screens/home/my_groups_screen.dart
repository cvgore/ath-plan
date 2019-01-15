import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../timetable/screen.dart';
import '../../group.dart';

class MyGroupsSubScreen extends StatefulWidget {
  @override
  createState() => _MyGroupsSubScreenState();
}

class _MyGroupsSubScreenState extends State<MyGroupsSubScreen> {
  Future<List<Group>> _bookmarksFuture;
  List<Group> _bookmarks = List();

  @override
  void initState() {
    super.initState();
    _bookmarksFuture = _getBookmarks();
  }

  Future<List<Group>> _getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList('bookmarks');
    _bookmarks = List();
//    if (data.length > 0) {
//      for (String fav in data) {
//        int grpId = int.parse(fav);
//        int grpPos = _groups.indexWhere((g) => g.id == grpId);
//        if (grpPos == -1) {
//          debugPrint('Group not found: $grpId');
//          continue;
//        }
//
//        _bookmarks.add(_groups[grpPos]);
//      }
//    }
    return _bookmarks;
  }

  ListTile _getBookmarksTile(Group data, int index) {
    return ListTile(
        leading: Icon(Icons.bookmark),
        title: Text(data.name),
        onTap: () {
          setState(() {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TimetableScreen(groupData: data)));
          });
        },
        onLongPress: () {
          _bookmarks.removeAt(index);
          _saveBookmarks();
        });
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'bookmarks', _bookmarks.map((g) => g.id.toString()).toList());
    setState(() {
      _bookmarksFuture = _getBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: _bookmarksFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData || snapshot.hasError) {
          List<Group> data = List.from(snapshot.data);
          return Container(
            child: ListView.builder(
              itemExtent: null,
              itemBuilder: (BuildContext _, int index) {
                return ListTile(
                  leading: Icon(Icons.group),
                  title: Text(data[index].name),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext _) => TimetableScreen(groupData: data[index])));
                  },
                );
              },
              itemCount: data.length,
            ),
          );
        }
        // By default, show a loading spinner
        return Center(child: CircularProgressIndicator());
      });
  }
}
