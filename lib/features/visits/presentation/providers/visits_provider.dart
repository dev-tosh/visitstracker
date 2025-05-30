import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:visitstracker/core/services/snackbar_service.dart';
import 'package:visitstracker/features/visits/data/repositories/visit_repository.dart';
import 'package:visitstracker/features/visits/domain/models/visit.dart';

class VisitsProvider extends ChangeNotifier {
  final VisitRepository _repository;
  List<Visit> _visits = [];
  bool _isLoading = false;
  String? _error;
  BuildContext? _context;

  VisitsProvider(this._repository);

  void setContext(BuildContext context) {
    _context = context;
  }

  List<Visit> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVisits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _visits = await _repository.getVisits();
      _visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));
      developer.log('Loaded ${_visits.length} visits');
    } catch (e) {
      _error = e.toString();
      developer.log('Error loading visits: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createVisit({
    required int customerId,
    required DateTime visitDate,
    required String status,
    required String location,
    String? notes,
    List<String>? activitiesDone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final visit = Visit(
        id: '', // Let Supabase generate the ID
        customerId: customerId.toString(),
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes ?? '',
        activitiesDone: activitiesDone ?? [],
      );
      await _repository.createVisit(visit);
      await loadVisits();
      if (_context != null) {
        SnackbarService.show(
          context: _context!,
          message: 'Visit created successfully',
          type: SnackBarType.success,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error creating visit: $_error');
      if (_context != null) {
        SnackbarService.show(
          context: _context!,
          message: 'Failed to create visit: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVisit({
    required String id,
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
      final visit = Visit(
        id: id,
        customerId: _visits.firstWhere((v) => v.id == id).customerId,
        visitDate: visitDate ?? _visits.firstWhere((v) => v.id == id).visitDate,
        status: status ?? _visits.firstWhere((v) => v.id == id).status,
        location: location ?? _visits.firstWhere((v) => v.id == id).location,
        notes: notes ?? _visits.firstWhere((v) => v.id == id).notes,
        activitiesDone: activitiesDone ??
            _visits.firstWhere((v) => v.id == id).activitiesDone,
      );
      await _repository.updateVisit(id, visit);
      await loadVisits();
      if (_context != null) {
        SnackbarService.show(
          context: _context!,
          message: 'Visit updated successfully',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error updating visit: $_error');
      if (_context != null) {
        SnackbarService.show(
          context: _context!,
          message: 'Failed to update visit: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVisit(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteVisit(id);
      await loadVisits();
      if (_context != null) {
        SnackbarService.show(
          context: _context!,
          message: 'Visit deleted successfully',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error deleting visit: $_error');
      if (_context != null) {
        SnackbarService.show(
          context: _context!,
          message: 'Failed to delete visit: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
