import 'package:flutter/material.dart';
class EnseignantDashboardPage extends StatelessWidget {
  const EnseignantDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Tableau de bord Enseignant',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Bienvenue sur votre tableau de bord',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
