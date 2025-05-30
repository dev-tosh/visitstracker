import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:visitstracker/core/theme/text_styles.dart';
import 'package:visitstracker/core/widgets/shimmer_card.dart';
import 'package:visitstracker/features/customers/domain/models/customer.dart';
import 'package:visitstracker/features/customers/presentation/providers/customers_provider.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();
    // Load customers when the page is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers', style: title3(context: context)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Consumer<CustomersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) => _buildShimmerCard(context),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading customers',
                    style: headline(context: context),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.loadCustomers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No customers yet',
                    style: headline(context: context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first customer',
                    style: body(context: context, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.customers.length,
            itemBuilder: (context, index) {
              final customer = provider.customers[index];
              return _buildCustomerCard(context, customer);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'customers_fab',
        onPressed: () => _showAddCustomerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return ShimmerCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Text(
            customer.name[0].toUpperCase(),
            style: headline(context: context, color: Colors.blue),
          ),
        ),
        title: Text(
          customer.name,
          style: headline(context: context),
        ),
        subtitle: Text(
          'Created ${_formatDate(customer.createdAt)}',
          style: body(context: context, color: Colors.grey),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(context, value, customer),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to customer details
        },
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Customer', style: title3(context: context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
              ),
              autofocus: true,
            ),
            Consumer<CustomersProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  );
                }
                if (provider.error != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<CustomersProvider>(
            builder: (context, provider, child) {
              return ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        if (controller.text.isNotEmpty) {
                          await provider.createCustomer(controller.text);
                          if (provider.error == null) {
                            Navigator.pop(context);
                          }
                        }
                      },
                child: const Text('Add'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, String value, Customer customer) {
    switch (value) {
      case 'edit':
        _showEditCustomerDialog(context, customer);
        break;
      case 'delete':
        _showDeleteConfirmation(context, customer);
        break;
    }
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    final controller = TextEditingController(text: customer.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Customer', style: title3(context: context)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Customer Name',
            hintText: 'Enter customer name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<CustomersProvider>().updateCustomer(
                      customer.copyWith(name: controller.text),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Customer', style: title3(context: context)),
        content: Text(
          'Are you sure you want to delete ${customer.name}?',
          style: body(context: context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CustomersProvider>().deleteCustomer(customer.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
