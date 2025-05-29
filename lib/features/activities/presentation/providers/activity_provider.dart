import 'package:flutter/material.dart';
import 'package:visitstracker/features/activities/data/repositories/activity_repository.dart';
import 'package:visitstracker/features/activities/domain/models/activity.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository;
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;

  ActivityProvider(this._repository);

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _repository.getActivities();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createActivity(String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final activity = await _repository.createActivity(description);
      _activities.add(activity);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateActivity(Activity activity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedActivity = await _repository.updateActivity(activity);
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = updatedActivity;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteActivity(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteActivity(id);
      _activities.removeWhere((activity) => activity.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
