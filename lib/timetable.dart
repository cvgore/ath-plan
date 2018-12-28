class Timetable {
  final String summary;
  final DateTime starts;
  final DateTime ends;

  Timetable(this.summary, this.starts, this.ends);

  Timetable.fromJson(Map<String, dynamic> json)
      : starts = DateTime.parse(json['starts']),
        ends = DateTime.parse(json['ends']),
        summary = json['summary'];
}
