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
}
