import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'trip.g.dart';

@JsonSerializable()
@HiveType(typeId: 4) // Unique typeId
class Collaborator {
  @HiveField(0)
  final User? user;
  @HiveField(1)
  final String role;

  Collaborator({this.user, required this.role});

  factory Collaborator.fromJson(Map<String, dynamic> json) => _$CollaboratorFromJson(json);
  Map<String, dynamic> toJson() => _$CollaboratorToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 1)
class Trip extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String destination;
  @HiveField(4)
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @HiveField(5)
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @HiveField(6)
  final User? owner;
  @HiveField(7)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @HiveField(8)
  final List<Collaborator>? collaborators;
  @HiveField(9)
  @JsonKey(name: 'image')
  final String? imageUrl;
  @HiveField(10)
  @JsonKey(fromJson: _parseBudget, toJson: _toJsonBudget)
  final double? budget;
  @HiveField(11)
  final List<Booking>? bookings;

  Trip({
    required this.id,
    required this.title,
    this.description,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.owner,
    required this.createdAt,
    this.collaborators,
    this.imageUrl,
    this.budget = 0.0,
    this.bookings = const [],
  });

  static double _parseBudget(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static dynamic _toJsonBudget(double? value) => value;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      owner: json['owner'] != null ? User.fromJson(json['owner'] as Map<String, dynamic>) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrl: json['image'] as String?,
      budget: _parseBudget(json['budget']),
      collaborators: (json['collaborators'] as List?)
          ?.map((e) => Collaborator.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookings: (json['bookings'] as List?)
          ?.map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'destination': destination,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'image': imageUrl,
    'budget': budget ?? 0.0,
    'collaborators': collaborators?.map((e) => e.toJson()).toList(),
    'bookings': bookings?.map((e) => e.toJson()).toList() ?? [],
  };

  Trip copyWith({
    int? id,
    String? title,
    String? description,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    User? owner,
    DateTime? createdAt,
    List<Collaborator>? collaborators,
    String? imageUrl,
    List<Booking>? bookings,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      collaborators: collaborators ?? this.collaborators,
      imageUrl: imageUrl ?? this.imageUrl,
      budget: budget ?? this.budget,
      bookings: bookings ?? this.bookings,
    );
  }
}
@JsonSerializable()
@HiveType(typeId: 5)
class Booking {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final User user;
  @HiveField(2)
  final int trip;
  @HiveField(3)
  final String destination;
  @HiveField(4)
  final String status;
  @HiveField(5)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @HiveField(6)
  final int adults;
  @HiveField(7)
  final int children;
  @HiveField(8)
  @JsonKey(name: 'total_amount')
  final double totalAmount;

  Booking({
    required this.id,
    required this.user,
    required this.trip,
    required this.destination,
    required this.status,
    required this.createdAt,
    this.adults = 1,
    this.children = 0,
    this.totalAmount = 0.0,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      trip: json['trip'] as int,
      destination: json['destination'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      adults: json['adults'] as int? ?? 1,
      children: json['children'] as int? ?? 0,
      totalAmount: (json['total_amount'] is String) 
          ? double.tryParse(json['total_amount']) ?? 0.0
          : (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user.toJson(),
    'trip': trip,
    'destination': destination,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'adults': adults,
    'children': children,
    'total_amount': totalAmount,
  };
}
