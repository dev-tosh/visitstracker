import 'package:visitstracker/features/visits/data/repositories/visit_repository.dart';
import 'package:visitstracker/features/visits/domain/models/visit.dart';

class VisitService {
  final VisitRepository _repository;

  VisitService(this._repository);

  Future<List<Visit>> getVisits() async {
    return _repository.getVisits();
  }

  Future<void> createVisit({
    required String customerName,
    required DateTime visitDate,
    required String status,
    required String location,
    String? notes,
    List<String>? activitiesDone,
  }) async {
    final visit = Visit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerName,
      visitDate: visitDate,
      status: status,
      location: location,
      notes: notes ?? '',
      activitiesDone: activitiesDone ?? [],
    );
    await _repository.createVisit(visit);
  }
}
