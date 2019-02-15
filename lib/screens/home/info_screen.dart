import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../information.dart';

class InfoSubScreen extends StatefulWidget {
  InfoSubScreen({Key key}): super(key: key);
  @override createState() => _InfoSubScreenState();
}

class _InfoSubScreenState extends State<InfoSubScreen> {
  Future<List<Information>> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = _getInfo();
  }

  Future<List<Information>> _getInfo() async {
    var data =
    await http.get('https://ath-plan.liquard.tk/?info');
    if (data.statusCode != 200) {
      //_showErrorWhileFetching();
      return null;
    }

    return await compute(_parseInformation, data.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Information>>(
      future: _infoFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Nie można pobrać informacji'),
          );
        }
        else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, int idx) {
              return ListTile(
                title: Text(snapshot.data[idx].info),
              );
            }
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}


List<Information> _parseInformation(String data) {
  try {
    var json = jsonDecode(data);
    if (json is List) {
      return json.map((info) => Information.fromJson(info)).toList();
    }
    throw FormatException('Not a list', json);
  } on FormatException catch (ex) {
    debugPrint(ex.toString());
    //_showErrorWhileFetching();
    return null;
  }
}