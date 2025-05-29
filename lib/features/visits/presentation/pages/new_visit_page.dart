import 'package:flutter/material.dart';

class NewVisitPage extends StatelessWidget {
  const NewVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Visit'),
      ),
      body: const Center(
        child: Text('New Visit Form'),
      ),
    );
  }
}
