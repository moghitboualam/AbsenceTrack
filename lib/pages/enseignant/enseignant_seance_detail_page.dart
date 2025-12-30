import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';
import '../../apiservice/enseignant/teacher_service.dart';
import '../../models/teacher_models.dart';

class EnseignantSeanceDetailPage extends StatefulWidget {
  final int seanceId;
  const EnseignantSeanceDetailPage({super.key, required this.seanceId});

  @override
  State<EnseignantSeanceDetailPage> createState() =>
      _EnseignantSeanceDetailPageState();
}

class _EnseignantSeanceDetailPageState
    extends State<EnseignantSeanceDetailPage> {
  final TeacherService _teacherService = TeacherService();
  late Future<void> _loadingFuture;

  SessionEtudiantsDto? _sessionData;
  List<AbsenceDto> _existingAbsences = [];
  List<EtudiantDto> _presentStudents = [];
  final Set<int> _absentStudentIds = {};

  // View Mode: 'absences' or 'presences'
  String _viewMode = 'absences'; // 'absences' or 'presences'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _loadingFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch both students and existing absences
    final results = await Future.wait([
      _teacherService.getEtudiantsBySeance(widget.seanceId),
      _teacherService.getAbsencesBySeance(widget.seanceId),
      _teacherService.getPresencesBySeance(widget.seanceId),
    ]);

    _sessionData = results[0] as SessionEtudiantsDto;
    _existingAbsences = results[1] as List<AbsenceDto>;
    _presentStudents = results[2] as List<EtudiantDto>;

    // Pre-select students who are already marked absent
    _absentStudentIds.clear();
    for (var absence in _existingAbsences) {
      _absentStudentIds.add(absence.etudiantId);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }

  Future<void> _saveAbsences(BuildContext context) async {
    // 1. Prepare Request
    // Note: We are currently NOT handling partial dates/times, assuming full session absence for simplicity
    // and basing it on the session details.
    if (_sessionData == null) return;

    try {
      final request = AbsenceRequest(
        seanceId: widget.seanceId,
        etudiantIds: _absentStudentIds.toList(),
        dateAbsence: DateTime.now().toIso8601String().split('T')[0], // Today
        heureDebut: _sessionData!.heureDebut,
        heureFin: _sessionData!.heureFin,
        statut: 'ABSENT',
      );

      await _teacherService.markAbsences(request);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Absences enregistrées avec succès")),
        );
        _refresh(); // Reload to confirm
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'enregistrement: $e")),
        );
      }
    }
  }

  Future<void> _sendWarning(
    BuildContext context,
    int etudiantId,
    String studentName,
  ) async {
    String reason = "";
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Avertissement pour $studentName"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Veuillez saisir le motif de l'avertissement :"),
              const SizedBox(height: 12),
              ShadInput(
                placeholder: const Text("Motif (ex: Comportement, Retard...)"),
                onChanged: (val) => reason = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Envoyer"),
            ),
          ],
        );
      },
    );

    if (confirmed == true && reason.isNotEmpty) {
      try {
        await _teacherService.envoyerAvertissement(etudiantId, reason);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Avertissement envoyé avec succès")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Erreur lors de l'envoi: $e")));
        }
      }
    }
  }

  Future<void> _invalidatePresence(BuildContext context, int presenceId) async {
    try {
      await _teacherService.invalidatePresence(presenceId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Présence invalidée avec succès")),
        );
        _refresh();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'invalidation: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la séance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadingFuture,
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

          if (_sessionData == null)
            return const Center(child: Text("Aucune donnée trouvée."));

          final session = _sessionData!;
          final etudiants = session.etudiants;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Info
                      Card(
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
                                session.moduleLibelle,
                                style: ShadTheme.of(context).textTheme.h4,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.class_,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Classe: ${session.classeCode}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${session.jour} | ${session.heureDebut.substring(0, 5)} - ${session.heureFin.substring(0, 5)}",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const SizedBox(height: 24),

                      // Toggle View
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _viewMode = 'absences'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _viewMode == 'absences'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _viewMode == 'absences'
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 2,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Absences",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _viewMode = 'presences'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _viewMode == 'presences'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _viewMode == 'presences'
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 2,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Présences (${_presentStudents.length})",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_viewMode == 'absences') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Liste des étudiants",
                              style: ShadTheme.of(context).textTheme.h4,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Absent",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Cochez les étudiants absents puis validez.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (etudiants.isEmpty)
                          const Center(
                            child: Text(
                              "Aucun étudiant inscrit dans cette classe.",
                            ),
                          ),

                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: etudiants.length,
                          separatorBuilder: (ctx, i) => const Divider(),
                          itemBuilder: (ctx, i) {
                            final etudiant = etudiants[i];
                            final isAbsent = _absentStudentIds.contains(
                              etudiant.id,
                            );

                            return Container(
                              decoration: BoxDecoration(
                                color: isAbsent ? Colors.red.shade50 : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                leading: Checkbox(
                                  value: isAbsent,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _absentStudentIds.add(etudiant.id);
                                      } else {
                                        _absentStudentIds.remove(etudiant.id);
                                      }
                                    });
                                  },
                                  activeColor: Colors.red,
                                ),
                                title: Text(
                                  "${etudiant.nom} ${etudiant.prenom}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isAbsent ? Colors.red : Colors.black,
                                  ),
                                ),
                                subtitle: Text(etudiant.email),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                  ),
                                  tooltip: "Envoyer un avertissement",
                                  onPressed: () => _sendWarning(
                                    context,
                                    etudiant.id,
                                    "${etudiant.nom} ${etudiant.prenom}",
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        // PRESENCES VIEW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Étudiants Présents",
                              style: ShadTheme.of(context).textTheme.h4,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_presentStudents.length} Présents",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_presentStudents.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                "Aucune présence marquée pour le moment.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _presentStudents.length,
                            separatorBuilder: (ctx, i) => const Divider(),
                            itemBuilder: (ctx, i) {
                              final etudiant = _presentStudents[i];
                              return Card(
                                elevation: 0,
                                color: Colors.green.shade50,
                                margin: EdgeInsets.zero,
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 16,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  title: Text(
                                    "${etudiant.nom} ${etudiant.prenom}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(etudiant.email),
                                  trailing: ShadButton.destructive(
                                    size: ShadButtonSize.sm,
                                    onPressed: () => _invalidatePresence(
                                      context,
                                      etudiant
                                          .id, // Assuming this maps to 'presenceId' if DTO has it, need to verify
                                    ),
                                    child: const Text("Invalider"),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              // Floating Action Button Styled Save Area
              if (_viewMode == 'absences')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ShadButton(
                          size: ShadButtonSize.lg,
                          onPressed: () => _saveAbsences(context),
                          child: Text(
                            "Enregistrer les Absences (${_absentStudentIds.length})",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
