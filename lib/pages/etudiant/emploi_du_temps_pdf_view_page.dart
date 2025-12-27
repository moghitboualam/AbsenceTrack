import 'package:flutter/material.dart';

class EmploiDuTempsPdfViewPage extends StatelessWidget {
  final String? id;

  const EmploiDuTempsPdfViewPage({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Visualisation PDF',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Affichage du PDF pour l\'emploi du temps ID: $id',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
