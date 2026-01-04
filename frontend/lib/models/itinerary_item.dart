import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'itinerary_item.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class ItineraryItem extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int trip;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? location;
  @HiveField(5)
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @HiveField(6)
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @HiveField(7)
  final int order;

  ItineraryItem({
    required this.id,
    required this.trip,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    required this.order,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) => _$ItineraryItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItineraryItemToJson(this);
}
