import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visitstracker/core/theme/text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            onPressed: () => context.go('/customers'),
          ),
          IconButton(
            icon: const Icon(Icons.event),
            onPressed: () => context.go('/visits'),
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
                  child: _buildStatCard(
                    context,
                    'Today\'s Visits',
                    '3',
                    Icons.event,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Customers',
                    '8',
                    Icons.people,
                    Colors.green,
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
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
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(
                        index % 2 == 0 ? Icons.event : Icons.people,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      index % 2 == 0 ? 'New Visit Scheduled' : 'Customer Added',
                      style: headline(context: context),
                    ),
                    subtitle: Text(
                      '2 hours ago',
                      style: body(context: context, color: Colors.grey),
                    ),
                    trailing: Icon(
                      index % 2 == 0 ? Icons.event : Icons.people,
                      color: Colors.grey.shade400,
                    ),
                  ),
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
}
