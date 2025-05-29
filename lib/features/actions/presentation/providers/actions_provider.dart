import 'package:flutter/material.dart';
import 'package:visitstracker/features/actions/data/repositories/action_repository.dart';

class ActionsProvider extends ChangeNotifier {
  final ActionRepository _repository;
  List<Map<String, dynamic>> _actions = [];
  bool _isLoading = false;
  String? _error;

  ActionsProvider(this._repository);

  List<Map<String, dynamic>> get actions => _actions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _actions = await _repository.getActions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
