import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/core/repositories/base_repository.dart';
import 'package:visitstracker/core/services/cache_service.dart';
import 'package:visitstracker/features/visits/domain/models/visit.dart';

class VisitRepository extends BaseRepository {
  VisitRepository(ApiClient apiClient, CacheService cacheService)
      : super(apiClient, cacheService, '/visits', 'visits_cache');

  Future<List<Visit>> getVisits() async {
    final response = await getAll();
    return response.map((json) => Visit.fromJson(json)).toList();
  }

  Future<Visit> createVisit(Visit visit) async {
    final response = await create(visit.toJsonForCreate());
    if (response == null) {
      // If the create returns null, fetch the created visit
      final visits = await getVisits();
      // Sort by created_at in descending order to get the most recent visit
      visits.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      // Return the most recent visit that matches our criteria
      return visits.firstWhere(
        (v) =>
            v.customerId == visit.customerId &&
            v.location == visit.location &&
            v.visitDate.year == visit.visitDate.year &&
            v.visitDate.month == visit.visitDate.month &&
            v.visitDate.day == visit.visitDate.day,
        orElse: () => throw Exception('Failed to find created visit'),
      );
    }
    return Visit.fromJson(response);
  }

  Future<Visit> updateVisit(String id, Visit visit) async {
    final response = await update(id, visit.toJsonForUpdate());
    if (response == null) {
      // If the update returns null, fetch the updated visit
      final visits = await getVisits();
      return visits.firstWhere(
        (v) => v.id == id,
        orElse: () => throw Exception('Failed to find updated visit'),
      );
    }
    return Visit.fromJson(response);
  }

  Future<void> deleteVisit(String id) async {
    await delete(id);
  }
}
