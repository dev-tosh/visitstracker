import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/features/actions/domain/models/activity.dart';

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
      {'description': description},
    );
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
