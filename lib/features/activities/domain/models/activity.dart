class Activity {
  final String? id;
  final String description;
  final DateTime createdAt;

  Activity({
    this.id,
    required this.description,
    required this.createdAt,
  });

  Activity copyWith({
    String? id,
    String? description,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) {
      json['id'] = id.toString();
    }
    return json;
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id']?.toString(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
