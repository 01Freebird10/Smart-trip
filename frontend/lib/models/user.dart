import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  @JsonKey(name: 'first_name')
  final String? firstName;
  @HiveField(3)
  @JsonKey(name: 'last_name')
  final String? lastName;
  @HiveField(4)
  final String? bio;
  @HiveField(5)
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @HiveField(6)
  final int? age;
  @HiveField(7)
  final String? address;
  @HiveField(8)
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @HiveField(9)
  final String? gender;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.bio,
    this.profilePicture,
    this.age,
    this.address,
    this.phoneNumber,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? bio,
    String? profilePicture,
    int? age,
    String? address,
    String? phoneNumber,
    String? gender,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      age: age ?? this.age,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
    );
  }
}
