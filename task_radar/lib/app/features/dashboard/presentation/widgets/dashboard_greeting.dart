import 'package:flutter/material.dart';

class DashboardGreeting extends StatelessWidget {
  final String? userName;

  const DashboardGreeting({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    final name = userName ?? '';
    return Text(
      'Olá, $name!',
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
