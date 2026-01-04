// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollaboratorAdapter extends TypeAdapter<Collaborator> {
  @override
  final int typeId = 4;

  @override
  Collaborator read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Collaborator(
      user: fields[0] as User?,
      role: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Collaborator obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.user)
      ..writeByte(1)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollaboratorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripAdapter extends TypeAdapter<Trip> {
  @override
  final int typeId = 1;

  @override
  Trip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trip(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String?,
      destination: fields[3] as String,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime,
      owner: fields[6] as User?,
      createdAt: fields[7] as DateTime,
      collaborators: (fields[8] as List?)?.cast<Collaborator>(),
      imageUrl: fields[9] as String?,
      budget: fields[10] as double?,
      bookings: (fields[11] as List?)?.cast<Booking>(),
    );
  }

  @override
  void write(BinaryWriter writer, Trip obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.destination)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.owner)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.collaborators)
      ..writeByte(9)
      ..write(obj.imageUrl)
      ..writeByte(10)
      ..write(obj.budget)
      ..writeByte(11)
      ..write(obj.bookings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookingAdapter extends TypeAdapter<Booking> {
  @override
  final int typeId = 5;

  @override
  Booking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Booking(
      id: fields[0] as int,
      user: fields[1] as User,
      trip: fields[2] as int,
      destination: fields[3] as String,
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
      adults: fields[6] as int,
      children: fields[7] as int,
      totalAmount: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Booking obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.trip)
      ..writeByte(3)
      ..write(obj.destination)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.adults)
      ..writeByte(7)
      ..write(obj.children)
      ..writeByte(8)
      ..write(obj.totalAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collaborator _$CollaboratorFromJson(Map<String, dynamic> json) => Collaborator(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      role: json['role'] as String,
    );

Map<String, dynamic> _$CollaboratorToJson(Collaborator instance) =>
    <String, dynamic>{
      'user': instance.user,
      'role': instance.role,
    };

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      owner: json['owner'] == null
          ? null
          : User.fromJson(json['owner'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      collaborators: (json['collaborators'] as List<dynamic>?)
          ?.map((e) => Collaborator.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['image'] as String?,
      budget: json['budget'] == null ? 0.0 : Trip._parseBudget(json['budget']),
      bookings: (json['bookings'] as List<dynamic>?)
              ?.map((e) => Booking.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'destination': instance.destination,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'owner': instance.owner,
      'created_at': instance.createdAt.toIso8601String(),
      'collaborators': instance.collaborators,
      'image': instance.imageUrl,
      'budget': Trip._toJsonBudget(instance.budget),
      'bookings': instance.bookings,
    };

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
      id: (json['id'] as num).toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      trip: (json['trip'] as num).toInt(),
      destination: json['destination'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      adults: (json['adults'] as num?)?.toInt() ?? 1,
      children: (json['children'] as num?)?.toInt() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'trip': instance.trip,
      'destination': instance.destination,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'adults': instance.adults,
      'children': instance.children,
      'total_amount': instance.totalAmount,
    };
