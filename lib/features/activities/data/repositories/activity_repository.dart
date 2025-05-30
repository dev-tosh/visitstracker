import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/features/activities/domain/models/activity.dart';

class ActivityRepository {
  final ApiClient _apiClient;

  ActivityRepository(this._apiClient);

  Future<List<Activity>> getActivities() async {
    final response = await _apiClient.get('/activities');
    return (response as List)
        .map((json) => Activity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Activity> createActivity(String description) async {
    final response = await _apiClient.post(
      '/activities',
      {
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    // If response is null (empty response), fetch the activity we just created
    if (response == null) {
      // Wait a moment for the activity to be created
      await Future.delayed(const Duration(seconds: 1));

      // Fetch the activity by description
      final activities =
          await _apiClient.get('/activities?description=eq.$description');
      if (activities.isEmpty) {
        throw Exception(
            'Failed to create activity: Activity not found after creation');
      }
      return Activity.fromJson(activities[0] as Map<String, dynamic>);
    }

    return Activity.fromJson(response as Map<String, dynamic>);
  }

  Future<Activity> updateActivity(Activity activity) async {
    final response = await _apiClient.patch(
      '/activities/${activity.id}',
      activity.toJson(),
    );
    return Activity.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteActivity(int id) async {
    await _apiClient.delete('/activities/$id');
  }
}
