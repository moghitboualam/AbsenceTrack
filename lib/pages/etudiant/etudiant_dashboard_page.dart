import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../services/student_service.dart';
import '../../models/student_models.dart';
import '../../services/websocket_service.dart';

class EtudiantDashboardPage extends StatefulWidget {
  const EtudiantDashboardPage({super.key});

  @override
  State<EtudiantDashboardPage> createState() => _EtudiantDashboardPageState();
}

class _EtudiantDashboardPageState extends State<EtudiantDashboardPage> {
  final StudentService _studentService = StudentService();
  final WebSocketService _wsService = WebSocketService();
  StudentDetails? _studentDetails;
  bool _isLoading = true;
  String? _error;
  List<Seance> _activeSeances = [];
  bool _isMarkingPresence = false;

  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupWebSocketListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _wsService.disconnect();
    super.dispose();
  }

  void _setupWebSocketListener() {
    _notificationSubscription = _wsService.notificationStream.listen((data) {
      if (mounted) {
        final message = data['message'] ?? 'Nouvelle notification';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(
              label: 'Voir',
              onPressed: () {
                // Navigate based on type, for now just show details
                context.go('/etudiant/emploi-du-temps');
              },
            ),
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.blueAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final data = await _studentService.getMyDetails();
      if (mounted) {
        setState(() {
          _studentDetails = data;
        });

        // 2. Fetch active sessions
        final activeSeances = await _studentService.getActiveOpenSeances();

        if (mounted) {
          setState(() {
            _activeSeances = activeSeances;
            _isLoading = false;
          });

          // Connect WS after getting class ID
          if (data.classId != null) {
            _wsService.connect(data.classId.toString());
          }
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Erreur: $_error"),
              const SizedBox(height: 16),
              ShadButton(onPressed: _loadData, child: const Text("Réessayer")),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Étudiant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_studentDetails != null) ...[
              Text(
                'Bonjour, ${_studentDetails!.prenom} ! 👋',
                style: ShadTheme.of(context).textTheme.h2,
              ),
              Text(
                'Année : ${_studentDetails!.anneeUniversitaire ?? "N/A"}',
                style: ShadTheme.of(context).textTheme.p,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.school, color: Colors.blue),
                        title: Text(
                          _studentDetails!.filiereNom ?? "Filière inconnue",
                        ),
                        subtitle: const Text("Filière"),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.class_, color: Colors.green),
                        title: Text(
                          _studentDetails!.classeCode ?? "Classe inconnue",
                        ),
                        subtitle: const Text("Classe"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // SECTION SÉANCES EN COURS
            if (_activeSeances.isNotEmpty) ...[
              Text(
                'Séances en cours 🔴',
                style: ShadTheme.of(
                  context,
                ).textTheme.h4.copyWith(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              ..._activeSeances.map((seance) => _buildActiveSeanceCard(seance)),
              const SizedBox(height: 24),
            ],
            Text('Accès Rapide', style: ShadTheme.of(context).textTheme.h4),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Emploi du temps',
                  icon: Icons.calendar_today,
                  onTap: () => context.go('/etudiant/emploi-du-temps'),
                  color: Colors.blue.shade100,
                  iconColor: Colors.blue,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Mes Absences',
                  icon: Icons.person_off,
                  onTap: () => context.go('/etudiant/absences'),
                  color: Colors.red.shade100,
                  iconColor: Colors.red,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Mes Séances',
                  icon: Icons.class_,
                  onTap: () => context.go('/etudiant/seances'),
                  color: Colors.green.shade100,
                  iconColor: Colors.green,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Justifications',
                  icon: Icons.description,
                  onTap: () => context.go('/etudiant/justifications'),
                  color: Colors.orange.shade100,
                  iconColor: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSeanceCard(Seance seance) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seance.moduleLibelle ?? 'Module Inconnu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${seance.heureDebut} - ${seance.heureFin} • ${seance.salleCode ?? "Salle N/A"}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                onPressed: _isMarkingPresence
                    ? null
                    : () => _markPresence(seance.id),
                backgroundColor: Colors.green,
                child: _isMarkingPresence
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Marquer ma présence',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markPresence(int seanceId) async {
    setState(() => _isMarkingPresence = true);
    try {
      final success = await _studentService.markPresence(seanceId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Présence marquée avec succès ! ✅'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh data to update list (remove signed seance if backend logic does that, or just refresh)
          _loadData();
        } else {
          // Should be caught by catch block usually if API throws, but just in case
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible de marquer la présence'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Extract message cleanly
        String msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isMarkingPresence = false);
      }
    }
  }
}
