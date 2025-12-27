import 'package:flutter/material.dart';

class EmploiDuTempsDetailPage extends StatelessWidget {
  final String? id;

  const EmploiDuTempsDetailPage({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_view_day, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Détail de l\'Emploi du Temps',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: $id',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
