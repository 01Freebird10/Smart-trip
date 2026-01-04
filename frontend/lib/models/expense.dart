import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Expense {
  final int id;
  final int trip;
  final String name;
  final double amount;
  final String category;
  final DateTime timestamp;

  Expense({
    required this.id,
    required this.trip,
    required this.name,
    required this.amount,
    required this.category,
    required this.timestamp,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as int,
    trip: json['trip'] as int,
    name: json['name'] as String,
    amount: double.parse(json['amount'].toString()),
    category: json['category'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'trip': trip,
    'name': name,
    'amount': amount,
    'category': category,
    'timestamp': timestamp.toIso8601String(),
  };
}
