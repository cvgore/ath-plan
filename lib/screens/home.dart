import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'timetable.dart';
import '../group.dart';

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

  Future<List<Group>> _favouritesFuture;
  List<Group> _favourites = List();

  Future<List<Group>> _getFavs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList('favourites') ?? List<String>();
    _favourites = List();
    if (data.length == 0) {
      return List();
    }

    for(String fav in data) {
      int grpId = int.parse(fav);
      int grpPos = _groups.indexWhere((g) => g.id == grpId);
      if (grpPos == -1) {
        continue;
      }

      _favourites.add(_groups[grpPos]);
    }
    return _favourites;
  }

  ListTile _getFavsTile(Group data, int index) {
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
        _favourites.removeAt(index);
        _saveFavs();
      }
    );
  }

  Future<void> _saveFavs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favourites',
        _favourites.map((g) => g.id.toString()).toList()
    );
    setState(() {
      _favouritesFuture = _getFavs();
    });
  }

  @override
  void initState() {
    super.initState();
    _groupsFuture = _getIndexes();
    _favouritesFuture = _getFavs();
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
    var data = await http.get('http://192.168.1.100:8080');
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
                            if (_favourites.indexOf(data[index]) == -1) {
                              _favourites.add(data[index]);
                              _saveFavs();
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Dodano do ulubionych - ${data[index].name}')
                                  )
                              );
                            } else {
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('${data[index].name} - już dodałeś do ulubionych')
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
        future: _favouritesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Drawer(
                child: ListView(
                  children: <Widget>[
                    DrawerHeader(child: Text('ATH Plan')),
                    ListTile(
                      title: Text('Brak ulubionych'),
                      subtitle: Text('Przytrzymaj na danej grupie, aby dodać'),
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
                    return DrawerHeader(child: Text('ATH Plan'));
                  }
                  return _getFavsTile(snapshot.data[index - 1], index - 1);
                }
              ),
            );
          } else if (snapshot.hasError) {
            return Drawer(
              child: ListView(
                children: <Widget>[
                  DrawerHeader(child: Text('ATH Plan'))
                ],
              )
            );
          }
          return Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(child: Text('ATH Plan')),
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
