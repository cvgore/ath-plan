// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimetableEntry _$TimetableEntryFromJson(Map<String, dynamic> json) {
  return TimetableEntry(
      slug: json['slug'] as String,
      timespan: _tsFromJson(json['timespan'] as Map<String, dynamic>),
      type: json['type'] as String,
      room: json['room'] as String);
}

Map<String, dynamic> _$TimetableEntryToJson(TimetableEntry instance) =>
    _$TimetableEntryJsonMapWrapper(instance);

class _$TimetableEntryJsonMapWrapper extends $JsonMapWrapper {
  final TimetableEntry _v;
  _$TimetableEntryJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys => const ['slug', 'timespan', 'type', 'room'];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'slug':
          return _v.slug;
        case 'timespan':
          return _tsToJson(_v.timespan);
        case 'type':
          return _v.type;
        case 'room':
          return _v.room;
      }
    }
    return null;
  }
}

TimetableTimespan _$TimetableTimespanFromJson(Map<String, dynamic> json) {
  return TimetableTimespan(
      start: json['start'] as String, length: json['length'] as int);
}

Map<String, dynamic> _$TimetableTimespanToJson(TimetableTimespan instance) =>
    _$TimetableTimespanJsonMapWrapper(instance);

class _$TimetableTimespanJsonMapWrapper extends $JsonMapWrapper {
  final TimetableTimespan _v;
  _$TimetableTimespanJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys => const ['start', 'length'];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'start':
          return _v.start;
        case 'length':
          return _v.length;
      }
    }
    return null;
  }
}

Timetable _$TimetableFromJson(Map<String, dynamic> json) {
  return Timetable(
      entries: (json['entries'] as Map<String, dynamic>).map((k, e) => MapEntry(
          k,
          (e as List)
              .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
              .toList())));
}

Map<String, dynamic> _$TimetableToJson(Timetable instance) =>
    _$TimetableJsonMapWrapper(instance);

class _$TimetableJsonMapWrapper extends $JsonMapWrapper {
  final Timetable _v;
  _$TimetableJsonMapWrapper(this._v);

  @override
  Iterable<String> get keys => const ['entries'];

  @override
  dynamic operator [](Object key) {
    if (key is String) {
      switch (key) {
        case 'entries':
          return _v.entries;
      }
    }
    return null;
  }
}
