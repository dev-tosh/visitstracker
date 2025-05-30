import 'package:flutter/material.dart';
import 'package:visitstracker/core/network/supabase_service.dart';
import 'package:visitstracker/features/customers/domain/models/customer.dart';

class CustomersProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  CustomersProvider(this._supabaseService);

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _supabaseService.getCustomers();
      _customers = data.map((json) => Customer.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      final data = await _supabaseService.createCustomer(name);
      final customer = Customer.fromJson(data);
      _customers.add(customer);
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      final data =
          await _supabaseService.updateCustomer(customer.id, customer.name);
      final updatedCustomer = Customer.fromJson(data);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.deleteCustomer(id);
      _customers.removeWhere((customer) => customer.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
