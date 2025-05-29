import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/features/visits/domain/entities/visit.dart';

class VisitRepository {
  final ApiClient _apiClient;

  VisitRepository(this._apiClient);

  Future<List<Visit>> getVisits() async {
    final response = await _apiClient.get('/visits');
    return (response as List)
        .map((json) => Visit(
              id: json['id'] as int,
              customerId: json['customer_id'] as int,
              visitDate: DateTime.parse(json['visit_date'] as String),
              status: json['status'] as String,
              location: json['location'] as String,
              notes: json['notes'] as String,
              activitiesDone: json['activities_done'] != null
                  ? (json['activities_done'] as List).cast<String>()
                  : null,
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
      notes: response['notes'] as String,
      activitiesDone: response['activities_done'] != null
          ? (response['activities_done'] as List).cast<String>()
          : null,
      createdAt: response['created_at'] != null
          ? DateTime.parse(response['created_at'] as String)
          : null,
    );
  }
}
