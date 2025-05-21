import 'package:flutter/material.dart';
import '../widgets/health_dashboard.dart';

/// The main home page of the application.
class HomePage extends StatelessWidget {
  /// Creates the home page.
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: const HealthDashboard(),
        ),
      ),
    );
  }
} 