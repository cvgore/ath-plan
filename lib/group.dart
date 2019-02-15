import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable(nullable: false)
class Group {
  final String name;
  final int id;
  final int type;

  Group({ this.name, this.id, this.type });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);

}
