import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visitstracker/core/theme/text_styles.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Actions', style: title3(context: context)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _buildEndpointCard(
            context,
            title: 'Customers',
            description: 'Manage customer records and information',
            icon: Icons.people_rounded,
            color: Colors.blue,
            onTap: () => context.push('/customers'),
          ),
          const SizedBox(height: 12),
          _buildEndpointCard(
            context,
            title: 'Activities',
            description: 'Manage types of activities for visits',
            icon: Icons.task_alt_rounded,
            color: Colors.green,
            onTap: () => context.push('/activities'),
          ),
          const SizedBox(height: 12),
          _buildEndpointCard(
            context,
            title: 'Visits',
            description: 'Record and monitor customer visits',
            icon: Icons.calendar_month_rounded,
            color: Colors.orange,
            onTap: () => context.push('/visits'),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: headline(context: context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: body(context: context, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
