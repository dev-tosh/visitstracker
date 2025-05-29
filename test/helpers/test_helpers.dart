import 'package:flutter/material.dart';
import 'package:visitstracker/features/activities/domain/entities/activity.dart';
import 'package:visitstracker/features/customers/domain/entities/customer.dart';
import 'package:visitstracker/features/visits/domain/entities/visit.dart';

/// Creates a test customer with default values
Customer createTestCustomer({
  int id = 1,
  String name = 'Test Customer',
  DateTime? createdAt,
}) {
  return Customer(
    id: id,
    name: name,
    createdAt: createdAt ?? DateTime.now(),
  );
}

/// Creates a test activity with default values
Activity createTestActivity({
  int id = 1,
  String description = 'Test Activity',
  DateTime? createdAt,
}) {
  return Activity(
    id: id,
    description: description,
    createdAt: createdAt ?? DateTime.now(),
  );
}

/// Creates a test visit with default values
Visit createTestVisit({
  int id = 1,
  int customerId = 1,
  DateTime? visitDate,
  String status = 'Completed',
  String location = 'Test Location',
  String notes = 'Test Notes',
  List<String>? activitiesDone,
  DateTime? createdAt,
}) {
  return Visit(
    id: id,
    customerId: customerId,
    visitDate: visitDate ?? DateTime.now(),
    status: status,
    location: location,
    notes: notes,
    activitiesDone: activitiesDone ?? ['1'],
    createdAt: createdAt ?? DateTime.now(),
  );
}

/// Creates a test MaterialApp with the given child
Widget createTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
