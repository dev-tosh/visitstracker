import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:visitstracker/core/services/alert_service.dart';
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
      final provider = context.read<CustomersProvider>();
      provider.setContext(context);
      provider.loadCustomers();
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(bottomSheetContext).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(bottomSheetContext).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text('Add Customer',
                      style: title3(context: bottomSheetContext)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      hintText: 'Enter customer name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Consumer<CustomersProvider>(
                    builder: (context, provider, child) {
                      if (provider.error != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Consumer<CustomersProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      if (controller.text.isNotEmpty) {
                                        // Set the context before creating the customer
                                        provider.setContext(bottomSheetContext);
                                        await provider
                                            .createCustomer(controller.text);
                                        if (provider.error == null) {
                                          Navigator.pop(bottomSheetContext);
                                        }
                                      }
                                    },
                              child: const Text('Add'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(bottomSheetContext).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(bottomSheetContext).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text('Edit Customer',
                      style: title3(context: bottomSheetContext)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      hintText: 'Enter customer name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Consumer<CustomersProvider>(
                    builder: (context, provider, child) {
                      if (provider.error != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Consumer<CustomersProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      if (controller.text.isNotEmpty) {
                                        // Set the context before updating the customer
                                        provider.setContext(bottomSheetContext);
                                        await provider.updateCustomer(
                                          customer.copyWith(
                                              name: controller.text),
                                        );
                                        if (provider.error == null) {
                                          Navigator.pop(bottomSheetContext);
                                        }
                                      }
                                    },
                              child: const Text('Save'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Customer customer) async {
    final provider = context.read<CustomersProvider>();
    final shouldDelete = await AlertService.showDeleteConfirmation(
      context: context,
      title: 'Delete Customer',
      message: 'Are you sure you want to delete "${customer.name}"?',
    );

    if (shouldDelete) {
      provider.setContext(context);
      if (customer.id != null) {
        await provider.deleteCustomer(customer.id!);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
