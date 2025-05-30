import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:visitstracker/core/theme/text_styles.dart';
import 'package:visitstracker/core/widgets/shimmer_card.dart';
import 'package:visitstracker/features/visits/domain/entities/visit.dart';
import 'package:visitstracker/features/visits/presentation/providers/visits_provider.dart';
import 'package:visitstracker/features/activities/presentation/providers/activities_provider.dart';

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
      context.read<VisitsProvider>().loadVisits();
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
          child: Icon(
            Icons.event,
            color: Colors.blue,
          ),
        ),
        title: Text(
          visit.location,
          style: headline(context: context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Date: ${_formatDate(visit.visitDate)}',
              style: body(context: context, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            _buildStatusChip(context, visit.status),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(context, value, visit),
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
          context.push('/visits/${visit.id}');
        },
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: body(
          context: context,
          color: color,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value, Visit visit) {
    switch (value) {
      case 'edit':
        // TODO: Implement edit visit
        break;
      case 'delete':
        _showDeleteConfirmation(context, visit);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Visit visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Visit', style: title3(context: context)),
        content: Text(
          'Are you sure you want to delete this visit?',
          style: body(context: context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<VisitsProvider>().deleteVisit(visit.id);
                Navigator.pop(context);
              } catch (e) {
                // Error is already handled by the provider
              }
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

  void _showAddVisitDialog(BuildContext context) {
    final customerController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedStatus = 'Pending';
    List<String> selectedActivities = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Visit', style: title3(context: context)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    hintText: 'Enter customer name',
                    prefixIcon: Icon(Icons.person),
                  ),
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
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
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
                      return const Center(child: CircularProgressIndicator());
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
                        Text('Activities', style: body(context: context)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              activitiesProvider.activities.map((activity) {
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
                                    selectedActivities
                                        .remove(activity.id.toString());
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
                    if (provider.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Consumer<VisitsProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (customerController.text.isNotEmpty &&
                              locationController.text.isNotEmpty) {
                            try {
                              await provider.createVisit(
                                customerName: customerController.text,
                                visitDate: selectedDate,
                                status: selectedStatus,
                                location: locationController.text,
                                notes: notesController.text.isNotEmpty
                                    ? notesController.text
                                    : null,
                                activitiesDone: selectedActivities.isNotEmpty
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
                  child: const Text('Add'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
