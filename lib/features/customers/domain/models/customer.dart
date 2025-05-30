class Customer {
  final String? id;
  final String name;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString(),
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) {
      json['id'] = id.toString();
    }
    return json;
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
