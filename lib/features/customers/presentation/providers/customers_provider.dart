import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:visitstracker/core/services/snackbar_service.dart';
import 'package:visitstracker/features/customers/data/repositories/customer_repository.dart';
import 'package:visitstracker/features/customers/domain/models/customer.dart';

class CustomersProvider extends ChangeNotifier {
  final CustomerRepository _repository;
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;
  BuildContext? _context;

  CustomersProvider(this._repository);

  void setContext(BuildContext context) {
    _context = context;
    developer.log('Context set in CustomersProvider');
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
      _customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      developer.log('Loaded ${_customers.length} customers');
    } catch (e) {
      _error = e.toString();
      developer.log('Error loading customers: $_error');
      if (_context != null) {
        developer.log('Showing error snackbar for load customers');
        SnackbarService.show(
          context: _context!,
          message: 'Failed to load customers: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCustomer(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log('Creating customer: $name');
      final customer = Customer(
        name: name,
        createdAt: DateTime.now(),
      );
      await _repository.createCustomer(customer);
      developer.log('Customer created, reloading customers');
      await loadCustomers();
      if (_context != null) {
        developer.log('Showing success snackbar for create customer');
        SnackbarService.show(
          context: _context!,
          message: 'Customer created successfully',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error creating customer: $_error');
      if (_context != null) {
        developer.log('Showing error snackbar for create customer');
        SnackbarService.show(
          context: _context!,
          message: 'Failed to create customer: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateCustomer(customer.id.toString(), customer);
      await loadCustomers();
      if (_context != null) {
        developer.log('Showing success snackbar for update customer');
        SnackbarService.show(
          context: _context!,
          message: 'Customer updated successfully',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error updating customer: $_error');
      if (_context != null) {
        developer.log('Showing error snackbar for update customer');
        SnackbarService.show(
          context: _context!,
          message: 'Failed to update customer: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteCustomer(id);
      await loadCustomers();
      if (_context != null) {
        developer.log('Showing success snackbar for delete customer');
        SnackbarService.show(
          context: _context!,
          message: 'Customer deleted successfully',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Error deleting customer: $_error');
      if (_context != null) {
        developer.log('Showing error snackbar for delete customer');
        SnackbarService.show(
          context: _context!,
          message: 'Failed to delete customer: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
