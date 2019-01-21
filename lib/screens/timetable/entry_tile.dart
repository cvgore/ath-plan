import 'dart:convert';

import 'package:flutter/material.dart';

import '../../timetable.dart';
import '../../exercise_types.dart';
import '../../common.dart';

String _getPrettyTime(String date, int mins) {
  var newDate = DateTime.parse('1970-01-01 $date:00').add(Duration(minutes: mins));
  return '${getPaddedZero(newDate.hour)}:${getPaddedZero(newDate.minute)}';
}

class EntryTile extends StatefulWidget {
  final TimetableEntry _timetable;
  EntryTile(TimetableEntry entry, {Key key}): _timetable = entry, super(key: key);
  @override createState() => _EntryTileState(timetable: _timetable);
}

class _EntryTileState extends State<EntryTile> {
  final TimetableEntry timetable;
  _EntryTileState({ this.timetable });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${timetable.slug}'),
      subtitle: Row(
        children: <Widget>[
          Padding(
            child: Text(timetable.room, style: TextStyle(fontWeight: FontWeight.bold)),
            padding: EdgeInsets.only(right: 4.0),
          ),
          Text('\u2022'),
          Padding(
            child: Text('${ExerciseTypes.getShortLocalNameByType(timetable.type)}'),
            padding: EdgeInsets.only(left: 4.0),
          ),
        ],
      ),
      trailing: Column(
        children: <Widget>[
          Text(timetable.timespan.start, style: Theme.of(context).textTheme.title),
          Text(_getPrettyTime(timetable.timespan.start, timetable.timespan.length)),
        ],
        crossAxisAlignment: CrossAxisAlignment.end,
      ),
      leading: Icon(ExerciseTypes.getIconByType(timetable.type),
      ),
      onLongPress: () {
        if (g_inDebugMode) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext builder) {
              return Container(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(jsonEncode(timetable)),
                ),
              );
            });
        }
      },
    );
  }
}