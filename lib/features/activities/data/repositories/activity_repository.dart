import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/core/repositories/base_repository.dart';
import 'package:visitstracker/core/services/cache_service.dart';
import 'package:visitstracker/features/activities/domain/models/activity.dart';

class ActivityRepository extends BaseRepository {
  ActivityRepository(ApiClient apiClient, CacheService cacheService)
      : super(apiClient, cacheService, '/activities', 'activities_cache');

  Future<List<Activity>> getActivities() async {
    final response = await getAll();
    return response.map((json) => Activity.fromJson(json)).toList();
  }

  Future<Activity> createActivity(Activity activity) async {
    try {
      final response = await create(activity.toJson());
      if (response == null) {
        // If the create returns null, fetch the latest activities and return the first one
        final activities = await getActivities();
        return activities.first;
      }
      return Activity.fromJson(response);
    } catch (e) {
      // In offline mode, use the optimistic response
      final optimisticResponse = {
        'description': activity.description,
        'created_at': activity.createdAt.toIso8601String(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      return Activity.fromJson(optimisticResponse);
    }
  }

  Future<Activity> updateActivity(String id, Activity activity) async {
    final response = await update(id, activity.toJsonForUpdate());
    if (response == null) {
      // If the update returns null, fetch the updated activity
      final activities = await getActivities();
      return activities.firstWhere((a) => a.id.toString() == id);
    }
    return Activity.fromJson(response);
  }

  Future<void> deleteActivity(String id) async {
    await delete(id);
  }
}
