import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_etudiant_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_enseignant_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_departement_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_filiere_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final _etudiantService = AdminEtudiantService();
  final _enseignantService = AdminEnseignantService();
  final _departementService = AdminDepartementService();
  final _filiereService = AdminFiliereService();

  int _totalEtudiants = 0;
  int _totalEnseignants = 0;
  int _totalDepartements = 0;
  int _totalFilieres = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      // Fetch only 1 item to get totalElements efficiently
      final etudiants = await _etudiantService.getAllEtudiants(page: 0, size: 1);
      final enseignants = await _enseignantService.getAllEnseignants(page: 0, size: 1);
      final departements = await _departementService.getAllDepartements(page: 0, size: 1);
      final filieres = await _filiereService.getAllFilieres(page: 0, size: 1);

      if (mounted) {
        setState(() {
          _totalEtudiants = etudiants['totalElements'] ?? 0;
          _totalEnseignants = enseignants['totalElements'] ?? 0;
           // Departement service returns Page object map
          _totalDepartements = departements['totalElements'] ?? 0;
          _totalFilieres = filieres['totalElements'] ?? 0; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Silently fail or show simple error in UI, dashboard should arguably be resilient
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text("Tableau de bord"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vue d'ensemble",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Stats Grid
            if (_isLoading) 
              const Center(child: CircularProgressIndicator())
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return GridView.count(
                    crossAxisCount: isMobile ? 2 : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    childAspectRatio: 1.1,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard(
                        title: "Étudiants",
                        value: _totalEtudiants.toString(),
                        icon: LucideIcons.graduationCap,
                        color: Colors.blue,
                        onTap: () => context.push('/admin/etudiants'),
                      ),
                      _StatCard(
                        title: "Enseignants",
                        value: _totalEnseignants.toString(),
                        icon: LucideIcons.users,
                        color: Colors.green,
                        onTap: () => context.push('/admin/enseignants'),
                      ),
                      _StatCard(
                        title: "Départements",
                        value: _totalDepartements.toString(),
                        icon: LucideIcons.building,
                        color: Colors.orange,
                        onTap: () => context.push('/admin/departements'),
                      ),
                      _StatCard(
                        title: "Filières",
                        value: _totalFilieres.toString(),
                        icon: LucideIcons.bookOpen,
                        color: Colors.purple,
                        onTap: () => context.push('/admin/filieres'),
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 32),
            const Text(
              "Actions Rapides",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Quick Actions
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ActionCard(
                  title: "Nouvel Étudiant",
                  icon: LucideIcons.userPlus,
                  color: Colors.blue,
                  onTap: () => context.push('/admin/etudiant/new'),
                ),
                _ActionCard(
                  title: "Nouvel Enseignant",
                  icon: LucideIcons.userPlus,
                  color: Colors.green,
                  onTap: () => context.push('/admin/enseignants/new'),
                ),
                _ActionCard(
                  title: "Gérer Emplois du Temps",
                  icon: LucideIcons.calendar,
                  color: Colors.purple,
                  onTap: () => context.push('/admin/emploi-du-temps'),
                ),
                 _ActionCard(
                  title: "Planification Modules",
                  icon: LucideIcons.calendarCheck,
                  color: Colors.amber[700]!,
                  onTap: () => context.push('/admin/module-promotions'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
               Icon(icon, color: color, size: 20),
               const SizedBox(width: 12),
               Expanded(
                 child: Text(
                   title,
                   style: const TextStyle(fontWeight: FontWeight.w500),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
