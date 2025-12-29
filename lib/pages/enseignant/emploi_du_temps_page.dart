import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../services/teacher_service.dart';
import '../../models/teacher_models.dart';

class EnseignantEmploiDuTempsPage extends StatefulWidget {
  const EnseignantEmploiDuTempsPage({super.key});

  @override
  State<EnseignantEmploiDuTempsPage> createState() =>
      _EnseignantEmploiDuTempsPageState();
}

class _EnseignantEmploiDuTempsPageState
    extends State<EnseignantEmploiDuTempsPage> {
  final TeacherService _teacherService = TeacherService();
  TeacherTimetable? _timetable;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    try {
      final data = await _teacherService.getMyTimetable();
      if (mounted) {
        setState(() {
          _timetable = data;
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
        appBar: AppBar(title: const Text('Mon Emploi du Temps')),
        body: Center(child: Text("Erreur : $_error")),
      );
    }

    final days = ["LUNDI", "MARDI", "MERCREDI", "JEUDI", "VENDREDI", "SAMEDI"];
    final timeSlots = ["08:30", "10:00", "11:30", "14:30", "16:00", "17:30"];

    // Organize by Time -> Day
    final Map<String, Map<String, TeacherSeance>> grid = {};
    if (_timetable != null) {
      for (var seance in _timetable!.seances) {
        grid.putIfAbsent(seance.heureDebut, () => {})[seance.jour] = seance;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Emploi du Temps')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planning Hebdomadaire',
              style: ShadTheme.of(context).textTheme.h3,
            ),
            Text(
              'Pr. ${_timetable?.enseignantPrenom ?? ""} ${_timetable?.enseignantNom ?? ""}',
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
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
                          width: 140,
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...days.map((day) {
                          final seance = grid[time]?[day];
                          return Container(
                            width: 140,
                            height: 120, // Fixed height
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: seance != null
                                  ? (seance.type == 'TP'
                                        ? Colors.green.shade50
                                        : seance.type == 'TD'
                                        ? Colors.blue.shade50
                                        : Colors.purple.shade50)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: seance != null ? 1 : 0.5,
                              ),
                            ),
                            child: seance != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        seance.moduleLibelle,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (seance.type != null)
                                        Badge(
                                          label: Text(
                                            seance.type!,
                                            style: const TextStyle(fontSize: 8),
                                          ),
                                          backgroundColor: Colors.black54,
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${seance.classeCode ?? ''} - ${seance.salleCode ?? ''}",
                                        style: const TextStyle(fontSize: 9),
                                        textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
