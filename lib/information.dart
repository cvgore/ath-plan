import 'package:json_annotation/json_annotation.dart';

part 'information.g.dart';

@JsonSerializable(nullable: false)
class Information {
  final String info;

  Information({ this.info });

  factory Information.fromJson(Map<String, dynamic> json) => _$InformationFromJson(json);
  Map<String, dynamic> toJson() => _$InformationToJson(this);
}