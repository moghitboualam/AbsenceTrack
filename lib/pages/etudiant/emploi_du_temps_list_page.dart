import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/student_service.dart';
import '../../models/student_models.dart';

class EmploiDuTempsListPage extends StatefulWidget {
  const EmploiDuTempsListPage({super.key});

  @override
  State<EmploiDuTempsListPage> createState() => _EmploiDuTempsListPageState();
}

class _EmploiDuTempsListPageState extends State<EmploiDuTempsListPage> {
  final StudentService _studentService = StudentService();
  List<EmploiDuTemps> _schedules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      // 1. Get student details to find classId
      // Optimization: In a real app, we might store current student in a Provider/State
      // to avoid re-fetching details on every page. For now, we fetch it.
      final student = await _studentService.getMyDetails();

      if (student.classId != null) {
        // 2. Fetch schedules for that class
        final data = await _studentService.getEmploiDuTempsByClassId(
          student.classId!,
        );
        if (mounted) {
          setState(() {
            _schedules = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _schedules = [];
            _isLoading = false;
          });
        }
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
        appBar: AppBar(title: const Text('Mes Emplois du Temps')),
        body: Center(child: Text("Erreur : $_error")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Emplois du Temps')),
      body: _schedules.isEmpty
          ? const Center(
              child: Text("Aucun emploi du temps trouvé pour votre classe."),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _schedules.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      schedule.nom, // Display actual name
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Semaine du ${schedule.dateDebut}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.go('/etudiant/emploi-du-temps/${schedule.id}');
                    },
                  ),
                );
              },
            ),
    );
  }
}
