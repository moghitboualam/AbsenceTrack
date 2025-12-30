import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../apiservice/etudiant/student_service.dart';
import '../../models/student_models.dart';

class EmploiDuTempsDetailPage extends StatefulWidget {
  final String? id;

  const EmploiDuTempsDetailPage({super.key, this.id});

  @override
  State<EmploiDuTempsDetailPage> createState() =>
      _EmploiDuTempsDetailPageState();
}

class _EmploiDuTempsDetailPageState extends State<EmploiDuTempsDetailPage> {
  final StudentService _studentService = StudentService();
  EmploiDuTempsDetail? _scheduleDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (widget.id == null) return;
    try {
      final data = await _studentService.getEmploiDuTempsDetailsById(
        widget.id!,
      );
      if (mounted) {
        setState(() {
          _scheduleDetail = data;
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
        appBar: AppBar(title: const Text('Détails Emploi du Temps')),
        body: Center(child: Text("Erreur : $_error")),
      );
    }

    final days = ["LUNDI", "MARDI", "MERCREDI", "JEUDI", "VENDREDI", "SAMEDI"];
    final timeSlots = ["08:30", "10:00", "11:30", "14:30", "16:00", "17:30"];

    // Organize sessions by time and day
    final Map<String, Map<String, Seance>> grid = {};
    if (_scheduleDetail != null) {
      for (var seance in _scheduleDetail!.seanceDtos) {
        grid.putIfAbsent(seance.heureDebut, () => {})[seance.jour] = seance;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Détails Emploi du Temps')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_scheduleDetail != null) ...[
              Text(
                'Emploi du temps : ${_scheduleDetail!.classeCode}',
                style: ShadTheme.of(context).textTheme.h3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  onPressed: () {
                    context.go(
                      '/etudiant/emploi-du-temps/view-pdf/${widget.id}',
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 16),
                      SizedBox(width: 8),
                      Text('Voir le PDF'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Grid View
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        const SizedBox(
                          width: 60,
                          child: Text(
                            "Horaires",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...days.map(
                          (day) => Container(
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    // Data Rows
                    ...timeSlots.map(
                      (time) => Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              time,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...days.map((day) {
                            final seance = grid[time]?[day];
                            return Container(
                              width: 120,
                              height: 100, // Fixed height for cells
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: seance != null
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: seance != null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          seance.modulePromotionLibelle ??
                                              seance.moduleLibelle ??
                                              '',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (seance.salleCode != null)
                                          Text(
                                            seance.salleCode!,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        if (seance.enseignantNomComplet != null)
                                          Text(
                                            seance.enseignantNomComplet!,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                          ),
                                      ],
                                    )
                                  : null,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
