import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:visitstracker/core/theme/text_styles.dart';
import 'package:visitstracker/features/customers/presentation/providers/customers_provider.dart';
import 'package:visitstracker/features/visits/presentation/providers/visits_provider.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final visitsProvider = context.read<VisitsProvider>();
      final customersProvider = context.read<CustomersProvider>();
      visitsProvider.setContext(context);
      customersProvider.setContext(context);
      visitsProvider.loadVisits();
      customersProvider.loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visits Tracker', style: title3(context: context)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.push('/customers'),
          ),
          IconButton(
            icon: const Icon(Icons.event),
            onPressed: () => context.push('/visits'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: Consumer<VisitsProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return _buildShimmerStatCard(context);
                      }
                      final todayVisits = provider.visits.where((visit) {
                        final today = DateTime.now();
                        final visitDate = visit.visitDate;
                        return visitDate.year == today.year &&
                            visitDate.month == today.month &&
                            visitDate.day == today.day;
                      }).length;
                      return _buildStatCard(
                        context,
                        'Today\'s Visits',
                        todayVisits.toString(),
                        Icons.event,
                        Colors.blue,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<CustomersProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return _buildShimmerStatCard(context);
                      }
                      return _buildStatCard(
                        context,
                        'Active Customers',
                        provider.customers.length.toString(),
                        Icons.people,
                        Colors.green,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Recent Activity
            Text(
              'Recent Activity',
              style: title4(context: context),
            ),
            const SizedBox(height: 16),
            Consumer2<VisitsProvider, CustomersProvider>(
              builder: (context, visitsProvider, customersProvider, child) {
                if (visitsProvider.isLoading || customersProvider.isLoading) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) =>
                        _buildShimmerActivityCard(context),
                  );
                }

                final recentActivities = <Map<String, dynamic>>[];

                // Add recent visits
                for (var visit in visitsProvider.visits.take(5)) {
                  recentActivities.add({
                    'type': 'visit',
                    'title': 'Visit to ${visit.location}',
                    'date': visit.visitDate,
                    'icon': Icons.event,
                  });
                }

                // Add recent customers
                for (var customer in customersProvider.customers.take(5)) {
                  recentActivities.add({
                    'type': 'customer',
                    'title': 'Customer Added: ${customer.name}',
                    'date': customer.createdAt,
                    'icon': Icons.people,
                  });
                }

                // Sort by date and take the most recent 5
                recentActivities.sort((a, b) => b['date'].compareTo(a['date']));
                final recent = recentActivities.take(5).toList();

                if (recent.isEmpty) {
                  return Center(
                    child: Text(
                      'No recent activity',
                      style: body(context: context, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    final activity = recent[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: activity['type'] == 'visit'
                              ? Colors.blue.shade50
                              : Colors.green.shade50,
                          child: Icon(
                            activity['icon'],
                            color: activity['type'] == 'visit'
                                ? Colors.blue
                                : Colors.green,
                          ),
                        ),
                        title: Text(
                          activity['title'],
                          style: headline(context: context),
                        ),
                        subtitle: Text(
                          _formatRelativeTime(activity['date']),
                          style: body(context: context, color: Colors.grey),
                        ),
                        trailing: Icon(
                          activity['icon'],
                          color: Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: title3(context: context, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: body(context: context, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerStatCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              highlightColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade100,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              highlightColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade100,
              child: Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              highlightColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade100,
              child: Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerActivityCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          highlightColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade100,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        title: Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          highlightColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        subtitle: Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          highlightColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade100,
          child: Container(
            width: 100,
            height: 16,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
