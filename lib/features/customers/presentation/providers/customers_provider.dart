import 'package:flutter/foundation.dart';
import 'package:visitstracker/features/customers/data/repositories/customer_repository.dart';
import 'package:visitstracker/features/customers/domain/models/customer.dart';

class CustomersProvider extends ChangeNotifier {
  final CustomerRepository _repository;
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  CustomersProvider(this._repository) {
    loadCustomers();
  }

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _repository.getCustomers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCustomer(String name) async {
    try {
      final customer = await _repository.createCustomer(name);
      _customers.add(customer);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      final updatedCustomer = await _repository.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _repository.deleteCustomer(id);
      _customers.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
