import 'package:flutter/material.dart';

/// Placeholder page for historical/sample data.
class SampleDataPage extends StatelessWidget {
  const SampleDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample Data')),
      body: const Center(
        child: Text('Sample Data Page – coming soon!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
} 