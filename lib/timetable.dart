import 'package:json_annotation/json_annotation.dart';

part 'timetable.g.dart';

TimetableTimespan _tsFromJson(Map<String, dynamic> timespan) {
  return TimetableTimespan.fromJson(timespan);
}
Map<String, dynamic> _tsToJson(TimetableTimespan timespan) => {
  'start': timespan.start,
  'length': timespan.length
};

@JsonSerializable(nullable: false, useWrappers: true)
class TimetableEntry {
  final String slug;
  @JsonKey(fromJson: _tsFromJson, toJson: _tsToJson)
  final TimetableTimespan timespan;
  final String type;
  final String room;

  TimetableEntry({ this.slug, this.timespan, this.type, this.room });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) => _$TimetableEntryFromJson(json);
  Map<String, dynamic> toJson() => _$TimetableEntryToJson(this);
}

@JsonSerializable(nullable: false, useWrappers: true)
class TimetableTimespan {
  final String start;
  final int length;

  TimetableTimespan({ this.start, this.length });

  factory TimetableTimespan.fromJson(Map<String, dynamic> json) => _$TimetableTimespanFromJson(json);
  Map<String, dynamic> toJson() => _$TimetableTimespanToJson(this);

}

@JsonSerializable(nullable: false, useWrappers: true)
class Timetable {
  final Map<String, List<TimetableEntry>> entries;

  Timetable({ this.entries });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    var root = Map<String, List<TimetableEntry>>();
    json.forEach((key, value) {
      root.putIfAbsent(key, () => (json[key] as List).map((e) => TimetableEntry.fromJson(e)).toList());
    });
    return Timetable(
      entries: root
    );
  }
  Map<String, dynamic> toJson() => _$TimetableToJson(this);
}

