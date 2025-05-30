import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitstracker/core/services/alert_service.dart';
import 'package:visitstracker/core/theme/text_styles.dart';
import 'package:visitstracker/core/widgets/shimmer_card.dart';
import 'package:visitstracker/features/activities/domain/models/activity.dart';
import 'package:visitstracker/features/activities/presentation/providers/activities_provider.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  @override
  void initState() {
    super.initState();
    // Load activities when the page is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ActivitiesProvider>();
      provider.setContext(context);
      provider.loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities', style: title3(context: context)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ActivitiesProvider>(
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
                    'Error loading activities',
                    style: headline(context: context),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.loadActivities(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activities yet',
                    style: headline(context: context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first activity',
                    style: body(context: context, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.activities.length,
            itemBuilder: (context, index) {
              final activity = provider.activities[index];
              return _buildActivityCard(context, activity);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'activities_fab',
        onPressed: () => _showAddActivityDialog(context),
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
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.task_alt, color: Colors.green),
        ),
        title: Text(
          activity.description,
          style: headline(context: context),
        ),
        subtitle: Text(
          'Created ${_formatDate(activity.createdAt)}',
          style: body(context: context, color: Colors.grey),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(context, value, activity),
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
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context) {
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
                  Text('Add Activity',
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
                      labelText: 'Activity Description',
                      hintText: 'Enter activity description',
                      prefixIcon: Icon(Icons.task_alt),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Consumer<ActivitiesProvider>(
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
                        child: Consumer<ActivitiesProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      if (controller.text.isNotEmpty) {
                                        // Set the context before creating the activity
                                        provider.setContext(bottomSheetContext);
                                        await provider
                                            .createActivity(controller.text);
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
      BuildContext context, String value, Activity activity) {
    switch (value) {
      case 'edit':
        _showEditActivityDialog(context, activity);
        break;
      case 'delete':
        _showDeleteConfirmation(context, activity);
        break;
    }
  }

  void _showEditActivityDialog(BuildContext context, Activity activity) {
    final controller = TextEditingController(text: activity.description);
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
                  Text('Edit Activity',
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
                      labelText: 'Activity Description',
                      hintText: 'Enter activity description',
                      prefixIcon: Icon(Icons.task_alt),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Consumer<ActivitiesProvider>(
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
                        child: Consumer<ActivitiesProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      if (controller.text.isNotEmpty) {
                                        // Set the context before updating the activity
                                        provider.setContext(bottomSheetContext);
                                        await provider.updateActivity(
                                          activity.copyWith(
                                            description: controller.text,
                                          ),
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

  void _showDeleteConfirmation(BuildContext context, Activity activity) async {
    final provider = context.read<ActivitiesProvider>();
    final shouldDelete = await AlertService.showDeleteConfirmation(
      context: context,
      title: 'Delete Activity',
      message: 'Are you sure you want to delete "${activity.description}"?',
    );

    if (shouldDelete) {
      provider.setContext(context);
      if (activity.id != null) {
        await provider.deleteActivity(activity.id!);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
