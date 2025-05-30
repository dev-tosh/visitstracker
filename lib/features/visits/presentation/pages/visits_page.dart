import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:visitstracker/core/services/alert_service.dart';
import 'package:visitstracker/core/theme/text_styles.dart';
import 'package:visitstracker/core/widgets/shimmer_card.dart';
import 'package:visitstracker/features/visits/domain/models/visit.dart';
import 'package:visitstracker/features/visits/presentation/providers/visits_provider.dart';
import 'package:visitstracker/features/activities/presentation/providers/activities_provider.dart';
import 'package:visitstracker/features/customers/presentation/providers/customers_provider.dart';

class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  @override
  void initState() {
    super.initState();
    // Load visits when the page is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VisitsProvider>();
      provider.setContext(context);
      provider.loadVisits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visits', style: title3(context: context)),
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
      body: Consumer<VisitsProvider>(
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
                    'Error loading visits',
                    style: headline(context: context),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.loadVisits(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.visits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No visits yet',
                    style: headline(context: context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Schedule your first visit',
                    style: body(context: context, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.visits.length,
            itemBuilder: (context, index) {
              final visit = provider.visits[index];
              return _buildVisitCard(context, visit);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'visits_fab',
        onPressed: () => _showAddVisitDialog(context),
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

  Widget _buildVisitCard(BuildContext context, Visit visit) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // context.push('/visits/${visit.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.location,
                          style: headline(context: context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${_formatDate(visit.visitDate)}',
                          style: body(context: context, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, visit.status),
                ],
              ),
              if (visit.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          visit.notes,
                          style: body(
                              context: context, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (visit.activitiesDone?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                Text(
                  'Activities',
                  style: body(context: context, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: visit.activitiesDone!.map((activityId) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Activity #$activityId',
                            style: body(
                              context: context,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditVisitDialog(context, visit);
                    },
                    tooltip: 'Edit Visit',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => _showDeleteConfirmation(context, visit),
                    tooltip: 'Delete Visit',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: body(
              context: context,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value, Visit visit) {
    switch (value) {
      case 'edit':
        _showEditVisitDialog(context, visit);
        break;
      case 'delete':
        _showDeleteConfirmation(context, visit);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Visit visit) async {
    final provider = context.read<VisitsProvider>();
    final shouldDelete = await AlertService.showDeleteConfirmation(
      context: context,
      title: 'Delete Visit',
      message:
          'Are you sure you want to delete this visit to ${visit.location}?',
    );

    if (shouldDelete) {
      provider.setContext(context);
      await provider.deleteVisit(visit.id);
    }
  }

  Widget _buildShimmerOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: Column(
        children: [
          Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVisitDialog(BuildContext context) {
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedStatus = 'Pending';
    List<String> selectedActivities = [];
    int? selectedCustomerId;

    // Load customers and activities when dialog opens
    final customersProvider = context.read<CustomersProvider>();
    final activitiesProvider = context.read<ActivitiesProvider>();
    customersProvider.loadCustomers();
    activitiesProvider.loadActivities();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
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
                    Text('Add Visit', style: title3(context: context)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<CustomersProvider>(
                            builder: (context, customersProvider, child) {
                              if (customersProvider.isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (customersProvider.error != null) {
                                return Text(
                                  'Error loading customers: ${customersProvider.error}',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                              if (customersProvider.customers.isEmpty) {
                                return Text(
                                  'No customers available. Please add a customer first.',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                              return DropdownButtonFormField<String>(
                                value: selectedCustomerId?.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Customer',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                items: customersProvider.customers
                                    .map((customer) => DropdownMenuItem(
                                          value: customer.id,
                                          child: Text(customer.name),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() =>
                                        selectedCustomerId = int.parse(value));
                                  }
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'Enter visit location',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              hintText: 'Enter visit notes (optional)',
                              prefixIcon: Icon(Icons.note),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Date: ${_formatDate(selectedDate)}',
                                  style: body(context: context),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setState(() => selectedDate = date);
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Change'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(Icons.flag),
                            ),
                            items: ['Pending', 'Completed', 'Cancelled']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedStatus = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Consumer<ActivitiesProvider>(
                            builder: (context, activitiesProvider, child) {
                              if (activitiesProvider.isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (activitiesProvider.error != null) {
                                return Text(
                                  'Error loading activities: ${activitiesProvider.error}',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                              if (activitiesProvider.activities.isEmpty) {
                                return Text(
                                  'No activities available. Please add some activities first.',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Activities',
                                      style: body(context: context)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: activitiesProvider.activities
                                        .map((activity) {
                                      final isSelected = selectedActivities
                                          .contains(activity.id.toString());
                                      return FilterChip(
                                        label: Text(activity.description),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedActivities
                                                  .add(activity.id.toString());
                                            } else {
                                              selectedActivities.remove(
                                                  activity.id.toString());
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            },
                          ),
                          Consumer<VisitsProvider>(
                            builder: (context, provider, child) {
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
                    ),
                    Consumer<VisitsProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return _buildShimmerOverlay(context);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
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
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<VisitsProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton(
                            onPressed: provider.isLoading ||
                                    selectedCustomerId == null ||
                                    locationController.text.isEmpty
                                ? null
                                : () async {
                                    try {
                                      await provider.createVisit(
                                        customerId: selectedCustomerId!,
                                        visitDate: selectedDate,
                                        status: selectedStatus,
                                        location: locationController.text,
                                        notes: notesController.text.isNotEmpty
                                            ? notesController.text
                                            : null,
                                        activitiesDone:
                                            selectedActivities.isNotEmpty
                                                ? selectedActivities
                                                : null,
                                      );
                                      if (provider.error == null) {
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    } catch (e) {
                                      // Error is already handled by the provider
                                    }
                                  },
                            child: const Text('Add'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditVisitDialog(BuildContext context, Visit visit) {
    final locationController = TextEditingController(text: visit.location);
    final notesController = TextEditingController(text: visit.notes);
    DateTime selectedDate = visit.visitDate;
    String selectedStatus = visit.status;
    List<String> selectedActivities = visit.activitiesDone ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
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
                    Text('Edit Visit', style: title3(context: context)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'Enter visit location',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              hintText: 'Enter visit notes (optional)',
                              prefixIcon: Icon(Icons.note),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Date: ${_formatDate(selectedDate)}',
                                  style: body(context: context),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setState(() => selectedDate = date);
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Change'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(Icons.flag),
                            ),
                            items: ['Pending', 'Completed', 'Cancelled']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedStatus = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Consumer<ActivitiesProvider>(
                            builder: (context, activitiesProvider, child) {
                              if (activitiesProvider.isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (activitiesProvider.error != null) {
                                return Text(
                                  'Error loading activities: ${activitiesProvider.error}',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Activities',
                                      style: body(context: context)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: activitiesProvider.activities
                                        .map((activity) {
                                      final isSelected = selectedActivities
                                          .contains(activity.id.toString());
                                      return FilterChip(
                                        label: Text(activity.description),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedActivities
                                                  .add(activity.id.toString());
                                            } else {
                                              selectedActivities.remove(
                                                  activity.id.toString());
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            },
                          ),
                          Consumer<VisitsProvider>(
                            builder: (context, provider, child) {
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
                    ),
                    Consumer<VisitsProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return _buildShimmerOverlay(context);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
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
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<VisitsProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    if (locationController.text.isNotEmpty) {
                                      try {
                                        await provider.updateVisit(
                                          id: visit.id,
                                          visitDate: selectedDate,
                                          status: selectedStatus,
                                          location: locationController.text,
                                          notes: notesController.text.isNotEmpty
                                              ? notesController.text
                                              : null,
                                          activitiesDone:
                                              selectedActivities.isNotEmpty
                                                  ? selectedActivities
                                                  : null,
                                        );
                                        if (provider.error == null) {
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        // Error is already handled by the provider
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
