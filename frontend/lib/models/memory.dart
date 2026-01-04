class Memory {
  final String id;
  final String tripId;
  final String title;
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.tripId,
    required this.title,
    this.content,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Memory.fromMap(Map<dynamic, dynamic> map) {
    return Memory(
      id: map['id'] as String,
      tripId: map['tripId'] as String,
      title: map['title'] as String,
      content: map['content'] as String?,
      imageUrl: map['imageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Memory copyWith({
    String? title,
    String? content,
    String? imageUrl,
  }) {
    return Memory(
      id: id,
      tripId: tripId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
    );
  }
}
