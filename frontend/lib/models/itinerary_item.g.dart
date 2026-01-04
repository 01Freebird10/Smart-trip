// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItineraryItemAdapter extends TypeAdapter<ItineraryItem> {
  @override
  final int typeId = 2;

  @override
  ItineraryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItineraryItem(
      id: fields[0] as int,
      trip: fields[1] as int,
      title: fields[2] as String,
      description: fields[3] as String?,
      location: fields[4] as String?,
      startTime: fields[5] as DateTime,
      endTime: fields[6] as DateTime,
      order: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ItineraryItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.trip)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryItem _$ItineraryItemFromJson(Map<String, dynamic> json) =>
    ItineraryItem(
      id: (json['id'] as num).toInt(),
      trip: (json['trip'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$ItineraryItemToJson(ItineraryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip': instance.trip,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'order': instance.order,
    };
