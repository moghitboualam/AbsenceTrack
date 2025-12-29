import 'package:flutter/material.dart';

import '../../services/student_service.dart';
import '../../models/student_models.dart';

class MesJustificationsPage extends StatefulWidget {
  const MesJustificationsPage({super.key});

  @override
  State<MesJustificationsPage> createState() => _MesJustificationsPageState();
}

class _MesJustificationsPageState extends State<MesJustificationsPage> {
  final StudentService _studentService = StudentService();
  List<EtudiantAbsence> _justifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _studentService.getMesJustifications();
      if (mounted) {
        setState(() {
          _justifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Justifications')),
        body: Center(child: Text("Erreur: $_error")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Justifications')),
      body: _justifications.isEmpty
          ? const Center(child: Text("Aucune justification soumise."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _justifications.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final item = _justifications[i];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.moduleNom ?? "Module Inconnu",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            _buildStatusBadge(item.etatJustification),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Date: ${item.date ?? 'N/A'}"),
                        Text(
                          "Heure: ${item.heureDebut ?? ''} - ${item.heureFin ?? ''}",
                        ),
                        const Divider(),
                        if (item.justification != null)
                          Text(
                            "Votre commentaire: ${item.justification}",
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        // Note: If backend returns "motif refus", display it here if available in model
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'VALIDE':
        color = Colors.green;
        text = 'Validée';
        break;
      case 'REFUSE':
        color = Colors.red;
        text = 'Refusée';
        break;
      case 'EN_ATTENTE':
        color = Colors.blue;
        text = 'En attente';
        break;
      default:
        color = Colors.grey;
        text = status ?? 'Non Soumis';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
