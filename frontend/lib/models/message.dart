import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'message.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class Message extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final User user;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final DateTime timestamp;

  Message({
    required this.id,
    required this.user,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
