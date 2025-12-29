import 'package:flutter/material.dart';

import '../../services/student_service.dart';
import '../../models/student_models.dart';

class MesSeancesPage extends StatefulWidget {
  const MesSeancesPage({super.key});

  @override
  State<MesSeancesPage> createState() => _MesSeancesPageState();
}

class _MesSeancesPageState extends State<MesSeancesPage> {
  final StudentService _studentService = StudentService();
  List<Seance> _seances = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  Future<void> _loadSeances() async {
    try {
      final data = await _studentService.getMesSeances();
      if (mounted) {
        setState(() {
          _seances = data;
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
        appBar: AppBar(title: const Text('Mes Séances')),
        body: Center(child: Text("Erreur : $_error")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Séances')),
      body: _seances.isEmpty
          ? const Center(child: Text("Aucune séance trouvée."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _seances.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final seance = _seances[index];
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
                        Text(
                          seance.modulePromotionLibelle ??
                              seance.moduleLibelle ??
                              "Module inconnu",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(seance.jour),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text("${seance.heureDebut} - ${seance.heureFin}"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.room,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(seance.salleCode ?? "Salle inconnue"),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                seance.enseignantNomComplet ??
                                    "Enseignant inconnu",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (seance.type != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Badge(
                              label: Text(seance.type!),
                              backgroundColor: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
