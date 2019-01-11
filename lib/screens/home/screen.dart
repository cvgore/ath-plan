import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../timetable/screen.dart';
import '../../group.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Group>> _groupsFuture;
  List<Group> _groups = List();
  String _filterBy = '';

  bool _isSearchVisible = false;

  TextEditingController _filterController;

  Future<List<Group>> _bookmarksFuture;
  List<Group> _bookmarks = List();

  Future<List<Group>> _getBookmarks() async {
    await _groupsFuture;
    final prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList('bookmarks');
    _bookmarks = List();
    if (data.length == 0) {
      return List();
    }

    for(String fav in data) {
      int grpId = int.parse(fav);
      int grpPos = _groups.indexWhere((g) => g.id == grpId);
      if (grpPos == -1) {
        debugPrint('Group not found: $grpId');
        continue;
      }

      _bookmarks.add(_groups[grpPos]);
    }
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
            builder: (context) => TimetableScreen(groupData: data)
          ));
        });
      },
      onLongPress: () {
        _bookmarks.removeAt(index);
        _saveBookmarks();
      }
    );
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('bookmarks',
        _bookmarks.map((g) => g.id.toString()).toList()
    );
    setState(() {
      _bookmarksFuture = _getBookmarks();
    });
  }

  @override
  void initState() {
    super.initState();
    _groupsFuture = _getIndexes();
    _bookmarksFuture = _getBookmarks();
    _filterController = TextEditingController();
    _filterController.addListener(() {
      if (_filterController.text.isEmpty) {
        setState(() {
          _filterBy = "";
        });
      } else {
        setState(() {
          _filterBy = _filterController.text;
        });
      }
    });
  }

  Future<List<Group>> _getIndexes() async {
    var data = await http.get('https://ath-plan.liquard.tk/');
    var json = jsonDecode(data.body);
    _groups = List();
    for (var i = 0; i < json.length; ++i) {
      _groups.add(Group.fromJson(json[i]));
    }

    return _groups;
  }

  _openRepo() async {
    const url = 'https://github.com/cvgore/ath-plan';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible ? TextField(
          style: Theme.of(context).textTheme.title,
          controller: _filterController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Wpisz szukaną frazę...'
          ),
        ) : Text('ATH Plan'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationVersion: '0.1.0',
                applicationName: 'ATH Plan',
                children: <Widget>[
                  Text('\u00A9 2018 cvgore'),
                  Text('Licensed under GPLv3.0'),
                  FlatButton(
                    child: Text('https://github.com/cvgore/ath-plan'),
                    onPressed: _openRepo,
                  )
                ]
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData || snapshot.hasError) {
            List<Group> data = List.from(snapshot.data);
            if (_isSearchVisible && _filterBy.length > 0) {
              data.retainWhere((g) => g.name.toLowerCase().contains(_filterBy.toLowerCase()));
            }
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
                                builder: (BuildContext _) => TimetableScreen(groupData: data[index],)
                            ));
                          },
                          onLongPress: () {
                            if (_bookmarks.indexOf(data[index]) == -1) {
                              _bookmarks.add(data[index]);
                              _saveBookmarks();
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Dodano do zakładek - ${data[index].name}')
                                  )
                              );
                            } else {
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('${data[index].name} - już dodałeś do zakładek')
                                )
                              );
                            }
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
        },
      ),
      // Set the nav drawer
      drawer: FutureBuilder<List<Group>>(
        future: _bookmarksFuture,
        builder: (context, snapshot) {
          Widget _getDrawerHeader() => DrawerHeader(child: Text('ATH Plan'));

          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Drawer(
                child: ListView(
                  children: <Widget>[
                    _getDrawerHeader(),
                    ListTile(
                      title: Text('Brak zakładek'),
                      subtitle: Text('Przytrzymaj na danej grupie, aby dodać do zakładek'),
                    )
                  ],
                )
              );
            }
            return Drawer(
              child: ListView.builder(
                itemCount: snapshot.data.length + 1,
                itemBuilder: (BuildContext _, int index) {
                  if (index == 0) {
                    return _getDrawerHeader();
                  }
                  return _getBookmarksTile(snapshot.data[index - 1], index - 1);
                }
              ),
            );
          } else if (snapshot.hasError) {
            return Drawer(
              child: ListView(
                children: <Widget>[
                  _getDrawerHeader()
                ],
              )
            );
          }
          return Drawer(
            child: ListView(
              children: <Widget>[
                _getDrawerHeader(),
                Center(child: CircularProgressIndicator())
              ],
            )
          );
        },
      ), //_getNavDrawer(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(_isSearchVisible ? Icons.close : Icons.search),
        onPressed: () {
          setState(() {
            _isSearchVisible = !_isSearchVisible;
          });
        },
      ),
    );
  }
}
