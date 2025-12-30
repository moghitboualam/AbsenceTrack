import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';
import '../../apiservice/enseignant/teacher_service.dart';
import '../../models/teacher_models.dart';

class EnseignantMesSeancesPage extends StatefulWidget {
  const EnseignantMesSeancesPage({super.key});

  @override
  State<EnseignantMesSeancesPage> createState() =>
      _EnseignantMesSeancesPageState();
}

class _EnseignantMesSeancesPageState extends State<EnseignantMesSeancesPage> {
  final TeacherService _teacherService = TeacherService();
  late Future<List<ProfesseurSeanceDto>> _seancesFuture;

  @override
  void initState() {
    super.initState();
    _seancesFuture = _teacherService.getMesSeancesProfesseur();
  }

  Future<void> _refresh() async {
    setState(() {
      _seancesFuture = _teacherService.getMesSeancesProfesseur();
    });
  }

  Future<void> _openSessionDialog(BuildContext context, int seanceId) async {
    int duration = 60; // Default
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ouvrir la session"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Spécifiez la durée de validité du QR Code (minutes)"),
              const SizedBox(height: 16),
              ShadInput(
                initialValue: "60",
                keyboardType: TextInputType.number,
                onChanged: (val) => duration = int.tryParse(val) ?? 60,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _teacherService.ouvrirSession(seanceId, duration);
                  _refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Session ouverte avec succès"),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
                  }
                }
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _closeSession(BuildContext context, int seanceId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clôturer la session"),
        content: const Text(
          "Voulez-vous vraiment valider les présences et clôturer cette session ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _teacherService.validerSession(seanceId);
        _refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Session clôturée avec succès")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Séances'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<ProfesseurSeanceDto>>(
        future: _seancesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ShadButton(
                    onPressed: _refresh,
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            );
          }

          final seances = snapshot.data ?? [];

          if (seances.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune séance trouvée.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: seances.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final seance = seances[index];
              final isToday = seance.estAujourdhui;
              final isOpen = seance.sessionOuverte;

              return Card(
                elevation: (isToday || isOpen) ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isOpen
                      ? const BorderSide(color: Colors.green, width: 2)
                      : (isToday
                            ? BorderSide(
                                color: Colors.blue.withOpacity(0.5),
                                width: 1.5,
                              )
                            : BorderSide.none),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              seance.moduleNom,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Badge(
                            label: Text(seance.typeSeance),
                            backgroundColor: isOpen
                                ? Colors.green
                                : (isToday ? Colors.blue : Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            seance.jour,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${seance.heureDebut.substring(0, 5)} - ${seance.heureFin.substring(0, 5)}",
                          ),
                          if (isOpen) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "En cours",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.class_,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text("Salle: ${seance.salleNom ?? 'N/A'}"),
                          const SizedBox(width: 16),
                          const Icon(Icons.group, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("Classe: ${seance.classeCode}"),
                        ],
                      ),

                      // Action Buttons for Today or Open Sessions
                      if (isToday || isOpen) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isOpen)
                              ShadButton(
                                size: ShadButtonSize.sm,
                                onPressed: () =>
                                    _openSessionDialog(context, seance.id),
                                child: const Text("Ouvrir Session"),
                              )
                            else ...[
                              ShadButton.outline(
                                size: ShadButtonSize.sm,
                                onPressed: () => context.push(
                                  '/enseignant/seance/${seance.id}',
                                ),
                                child: const Text("Détails"),
                              ),
                              const SizedBox(width: 8),
                              ShadButton.destructive(
                                size: ShadButtonSize.sm,
                                onPressed: () =>
                                    _closeSession(context, seance.id),
                                child: const Text("Clôturer"),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
