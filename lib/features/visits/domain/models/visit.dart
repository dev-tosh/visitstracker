class Visit {
  final String id;
  final String customerId;
  final DateTime visitDate;
  final String status;
  final String location;
  final String notes;
  final List<String> activitiesDone;
  final DateTime? createdAt;

  Visit({
    required this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activitiesDone,
    this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      visitDate: DateTime.parse(json['visit_date']),
      status: json['status'],
      location: json['location'],
      notes: json['notes'] ?? '',
      activitiesDone: (json['activities_done'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone,
    };
  }

  Visit copyWith({
    String? id,
    String? customerId,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<String>? activitiesDone,
  }) {
    return Visit(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      activitiesDone: activitiesDone ?? this.activitiesDone,
      createdAt: this.createdAt,
    );
  }
}
