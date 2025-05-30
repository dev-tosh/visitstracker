import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:visitstracker/core/services/snackbar_service.dart';
import 'package:visitstracker/features/activities/data/repositories/activity_repository.dart';
import 'package:visitstracker/features/activities/domain/models/activity.dart';

class ActivitiesProvider extends ChangeNotifier {
  final ActivityRepository _repository;
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;
  BuildContext? _context;

  ActivitiesProvider(this._repository);

  void setContext(BuildContext context) {
    _context = context;
    developer.log('Context set in ActivitiesProvider');
  }

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _repository.getActivities();
      _activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      developer.log('Loaded ${_activities.length} activities');
    } catch (e) {
      _error = e.toString();
      developer.log('Error loading activities: $_error');
      if (_context != null) {
        developer.log('Showing error snackbar for load activities');
        SnackbarService.show(
          context: _context!,
          message: 'Failed to load activities: ${e.toString()}',
          type: SnackBarType.error,
        );
      } else {
        developer.log('Context is null, cannot show snackbar');
      }
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
      developer.log('Creating activity: $description');
      final activity = Activity(
        description: description,
        createdAt: DateTime.now(),
      );
      await _repository.createActivity(activity);
      developer.log('Activity created, reloading activities');
      await loadActivities();
      if (_context != null) {
        developer.log('Showing success snackbar for create activity');
        SnackbarService.show(
          context: _context!,
          message: 'Activity created successfully',
          type: SnackBarType.success,
        );
      } else {
        developer.log('Context is null, cannot show success snackbar');
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error creating activity: $_error');
      if (_context != null) {
        developer.log('Showing error snackbar for create activity');
        SnackbarService.show(
          context: _context!,
          message: 'Failed to create activity: ${e.toString()}',
          type: SnackBarType.error,
        );
      } else {
        developer.log('Context is null, cannot show error snackbar');
      }
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
      if (activity.id != null) {
        await _repository.updateActivity(activity.id!, activity);
        await loadActivities();
        if (_context != null) {
          developer.log('Showing success snackbar for update activity');
          SnackbarService.show(
            context: _context!,
            message: 'Activity updated successfully',
            type: SnackBarType.success,
          );
        } else {
          developer.log('Context is null, cannot show success snackbar');
        }
      } else {
        developer.log('Activity ID is null, cannot update activity');
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error updating activity: $_error');
      if (_context != null) {
        developer.log('Showing error snackbar for update activity');
        SnackbarService.show(
          context: _context!,
          message: 'Failed to update activity: ${e.toString()}',
          type: SnackBarType.error,
        );
      } else {
        developer.log('Context is null, cannot show error snackbar');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteActivity(id);
      await loadActivities();
      if (_context != null) {
        developer.log('Showing success snackbar for delete activity');
        SnackbarService.show(
          context: _context!,
          message: 'Activity deleted successfully',
          type: SnackBarType.success,
        );
      } else {
        developer.log('Context is null, cannot show success snackbar');
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error deleting activity: $_error');
      if (_context != null) {
        developer.log('Showing error snackbar for delete activity');
        SnackbarService.show(
          context: _context!,
          message: 'Failed to delete activity: ${e.toString()}',
          type: SnackBarType.error,
        );
      } else {
        developer.log('Context is null, cannot show error snackbar');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.syncCache();
      await loadActivities();
    } catch (e) {
      _error = e.toString();
      developer.log('Error syncing activities: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
