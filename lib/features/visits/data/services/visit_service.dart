import 'package:visitstracker/features/visits/data/repositories/visit_repository.dart';
import 'package:visitstracker/features/visits/domain/entities/visit.dart';

class VisitService {
  final VisitRepository _repository;

  VisitService(this._repository);

  Future<List<Visit>> getVisits() async {
    return _repository.getVisits();
  }

  Future<Visit> getVisitById(int id) async {
    return _repository.getVisitById(id);
  }

  Future<void> createVisit({
    required String customerName,
    required DateTime visitDate,
    required String status,
    required String location,
    String? notes,
    List<String>? activitiesDone,
  }) async {
    await _repository.createVisit(
      customerName: customerName,
      visitDate: visitDate,
      status: status,
      location: location,
      notes: notes,
      activitiesDone: activitiesDone,
    );
  }
}
