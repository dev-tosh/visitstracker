import 'dart:developer' as developer;
import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/features/visits/domain/entities/visit.dart';

class VisitRepository {
  final ApiClient _apiClient;

  VisitRepository(this._apiClient);

  Future<List<Visit>> getVisits() async {
    developer.log('Fetching visits...');
    final response = await _apiClient.get('/visits');
    developer.log('Received ${(response as List).length} visits');
    return (response as List)
        .map((json) => Visit(
              id: json['id'] as int,
              customerId: json['customer_id'] as int,
              visitDate: DateTime.parse(json['visit_date'] as String),
              status: json['status'] as String,
              location: json['location'] as String,
              notes: json['notes'] as String? ?? '',
              activitiesDone: json['activities_done'] != null
                  ? (json['activities_done'] as List).cast<String>()
                  : [],
              createdAt: json['created_at'] != null
                  ? DateTime.parse(json['created_at'] as String)
                  : null,
            ))
        .toList();
  }

  Future<Visit> getVisitById(int id) async {
    final response = await _apiClient.get('/visits/$id');
    return Visit(
      id: response['id'] as int,
      customerId: response['customer_id'] as int,
      visitDate: DateTime.parse(response['visit_date'] as String),
      status: response['status'] as String,
      location: response['location'] as String,
      notes: response['notes'] as String? ?? '',
      activitiesDone: response['activities_done'] != null
          ? (response['activities_done'] as List).cast<String>()
          : [],
      createdAt: response['created_at'] != null
          ? DateTime.parse(response['created_at'] as String)
          : null,
    );
  }

  Future<void> createVisit({
    required String customerName,
    required DateTime visitDate,
    required String status,
    required String location,
    String? notes,
    List<String>? activitiesDone,
  }) async {
    developer.log('Creating visit for customer: $customerName');
    developer.log(
        'Visit details: date=$visitDate, status=$status, location=$location');
    if (activitiesDone != null) {
      developer.log('Activities to be done: ${activitiesDone.join(", ")}');
    }

    // First try to get the customer
    final trimmedName = customerName.trim();
    developer.log('Looking up customer: $trimmedName');
    final customers = await _apiClient.get('/customers?name=eq.$trimmedName');
    int customerId;

    if (customers.isEmpty) {
      developer.log('Customer not found, creating new customer');
      final newCustomer = await _apiClient.post(
        '/customers',
        {
          'name': trimmedName,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Wait a moment for the customer to be created
      await Future.delayed(const Duration(seconds: 1));

      // Fetch the customer again to get the ID
      final createdCustomers =
          await _apiClient.get('/customers?name=eq.$trimmedName');
      if (createdCustomers.isEmpty) {
        throw Exception(
            'Failed to create customer: Customer not found after creation');
      }
      customerId = createdCustomers[0]['id'] as int;
      developer.log('Created new customer with ID: $customerId');
    } else {
      customerId = customers[0]['id'] as int;
      developer.log('Found existing customer with ID: $customerId');
    }

    // Check valid status values
    developer.log('Checking valid status values...');
    final statusCheck = await _apiClient.get('/visits?select=status&limit=1');
    developer.log('Status check response: $statusCheck');

    // Create the visit
    developer.log('Creating visit in database...');
    final visitData = {
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location.trim(),
      'notes': notes?.trim() ?? '',
      'activities_done': activitiesDone ?? [],
      'created_at': DateTime.now().toIso8601String(),
    };
    developer.log('Visit data: $visitData');

    final response = await _apiClient.post('/visits', visitData);
    developer.log('Visit created successfully with response: $response');
  }

  Future<void> updateVisit({
    required int id,
    String? customerName,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<String>? activitiesDone,
  }) async {
    final Map<String, dynamic> updateData = {};

    // Handle customer update if name is provided
    if (customerName != null) {
      final customers =
          await _apiClient.get('/customers?name=eq.$customerName');
      if (customers.isEmpty) {
        final newCustomer = await _apiClient.post(
          '/customers',
          {
            'name': customerName,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
        updateData['customer_id'] = newCustomer['id'] as int;
      } else {
        updateData['customer_id'] = customers[0]['id'] as int;
      }
    }

    // Add other fields if provided
    if (visitDate != null) {
      updateData['visit_date'] = visitDate.toIso8601String();
    }
    if (status != null) {
      updateData['status'] = status;
    }
    if (location != null) {
      updateData['location'] = location;
    }
    if (notes != null) {
      updateData['notes'] = notes;
    }
    if (activitiesDone != null) {
      // Validate activities
      final activities = await _apiClient.get('/activities');
      final validActivityIds =
          (activities as List).map((a) => a['id'].toString()).toSet();

      final invalidActivities =
          activitiesDone.where((id) => !validActivityIds.contains(id)).toList();

      if (invalidActivities.isNotEmpty) {
        throw Exception(
            'Invalid activity IDs: ${invalidActivities.join(", ")}');
      }

      updateData['activities_done'] = activitiesDone;
    }

    await _apiClient.patch(
      '/visits?id=eq.$id',
      updateData,
    );
  }

  Future<void> deleteVisit(int id) async {
    await _apiClient.delete('/visits?id=eq.$id');
  }
}
