import 'package:flutter/material.dart';
import 'package:visitstracker/features/visits/data/services/visit_service.dart';
import 'package:visitstracker/features/visits/domain/entities/visit.dart';

class VisitsProvider extends ChangeNotifier {
  final VisitService _visitService;
  List<Visit> _visits = [];
  bool _isLoading = false;
  String? _error;

  VisitsProvider(this._visitService);

  List<Visit> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVisits() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _visits = await _visitService.getVisits();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Visit?> getVisitById(int id) async {
    try {
      return await _visitService.getVisitById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
