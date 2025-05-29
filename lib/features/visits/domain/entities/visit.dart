import 'package:equatable/equatable.dart';

class Visit extends Equatable {
  final int id;
  final int customerId;
  final DateTime visitDate;
  final String status;
  final String location;
  final String notes;
  final List<String>? activitiesDone;
  final DateTime? createdAt;

  const Visit({
    required this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    this.activitiesDone,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        visitDate,
        status,
        location,
        notes,
        activitiesDone,
        createdAt,
      ];

  Visit copyWith({
    int? id,
    int? customerId,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<String>? activitiesDone,
    DateTime? createdAt,
  }) {
    return Visit(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      activitiesDone: activitiesDone ?? this.activitiesDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
