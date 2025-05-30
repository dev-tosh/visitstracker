import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:visitstracker/features/visits/data/repositories/visit_repository.dart';
import 'package:visitstracker/features/visits/domain/entities/visit.dart';

class VisitsProvider extends ChangeNotifier {
  final VisitRepository _repository;
  List<Visit> _visits = [];
  bool _isLoading = false;
  String? _error;

  VisitsProvider(this._repository);

  List<Visit> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVisits() async {
    developer.log('Loading visits...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _visits = await _repository.getVisits();
      _error = null;
      developer.log('Successfully loaded ${_visits.length} visits');
    } catch (e) {
      _error = e.toString();
      developer.log('Error loading visits: $e', error: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createVisit({
    required String customerName,
    required DateTime visitDate,
    required String status,
    required String location,
    String? notes,
    List<String>? activitiesDone,
  }) async {
    developer.log('Creating new visit...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createVisit(
        customerName: customerName,
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes,
        activitiesDone: activitiesDone,
      );
      developer.log('Visit created successfully, reloading visits...');
      await loadVisits();
    } catch (e) {
      _error = e.toString();
      developer.log('Error creating visit: $e', error: true);
      notifyListeners();
      rethrow;
    }
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateVisit(
        id: id,
        customerName: customerName,
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes,
        activitiesDone: activitiesDone,
      );
      await loadVisits(); // Reload visits to get the updated one
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteVisit(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteVisit(id);
      _visits.removeWhere((visit) => visit.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
