import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/core/repositories/base_repository.dart';
import 'package:visitstracker/core/services/cache_service.dart';
import 'package:visitstracker/features/customers/domain/models/customer.dart';

class CustomerRepository extends BaseRepository {
  CustomerRepository(ApiClient apiClient, CacheService cacheService)
      : super(apiClient, cacheService, '/customers', 'customers_cache');

  Future<List<Customer>> getCustomers() async {
    final response = await getAll();
    return response.map((json) => Customer.fromJson(json)).toList();
  }

  Future<Customer> createCustomer(Customer customer) async {
    try {
      final response = await create(customer.toJson());
      if (response == null) {
        // If the create returns null, fetch the latest customers and return the first one
        final customers = await getCustomers();
        return customers.first;
      }
      return Customer.fromJson(response);
    } catch (e) {
      // In offline mode, use the optimistic response from base repository
      final optimisticResponse = {
        'name': customer.name,
        'created_at': customer.createdAt.toIso8601String(),
        'id': DateTime.now().millisecondsSinceEpoch,
      };
      return Customer.fromJson(optimisticResponse);
    }
  }

  Future<Customer> updateCustomer(String id, Customer customer) async {
    try {
      final response = await update(id, customer.toJsonForUpdate());
      if (response == null) {
        // If the update returns null, fetch the updated customer
        final customers = await getCustomers();
        return customers.firstWhere((c) => c.id == id);
      }
      return Customer.fromJson(response);
    } catch (e) {
      // In offline mode, use the optimistic response
      final optimisticResponse = {
        'id': id,
        'name': customer.name,
        'created_at': customer.createdAt.toIso8601String(),
      };
      return Customer.fromJson(optimisticResponse);
    }
  }

  Future<void> deleteCustomer(String id) async {
    await delete(id);
  }
}
