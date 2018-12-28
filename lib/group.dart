class Group {
  final String name;
  final int id;
  final int type;

  Group(this.name, this.id, this.type);

  Group.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        type = json['type'];
}
