import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/features/customers/domain/models/customer.dart';

class CustomerRepository {
  final ApiClient _apiClient;
  final String _endpoint = '/customers';

  CustomerRepository(this._apiClient);

  Future<List<Customer>> getCustomers() async {
    final response = await _apiClient.get(_endpoint);
    return (response as List)
        .map((json) => Customer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Customer> getCustomer(int id) async {
    final response = await _apiClient.get('$_endpoint?id=eq.$id');
    final customers = (response as List)
        .map((json) => Customer.fromJson(json as Map<String, dynamic>))
        .toList();
    return customers.first;
  }

  Future<Customer> createCustomer(String name) async {
    final data = {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    };
    final response = await _apiClient.post(_endpoint, data);
    return Customer.fromJson(response as Map<String, dynamic>);
  }

  Future<Customer> updateCustomer(Customer customer) async {
    final response = await _apiClient.patch(
      '$_endpoint?id=eq.${customer.id}',
      customer.toJson(),
    );
    return Customer.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteCustomer(int id) async {
    await _apiClient.delete('$_endpoint?id=eq.$id');
  }
}
