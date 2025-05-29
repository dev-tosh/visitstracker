import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VisitDetailsPage extends StatelessWidget {
  final String id;

  const VisitDetailsPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text('Visit Details for ID: $id'),
      ),
    );
  }
}
