import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../apiservice/enseignant/teacher_service.dart';
import '../../models/teacher_models.dart';

class EnseignantDashboardPage extends StatefulWidget {
  const EnseignantDashboardPage({super.key});

  @override
  State<EnseignantDashboardPage> createState() =>
      _EnseignantDashboardPageState();
}

class _EnseignantDashboardPageState extends State<EnseignantDashboardPage> {
  final TeacherService _teacherService = TeacherService();
  TeacherDetails? _teacherData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _teacherService.getMyDetails();
      if (mounted) {
        setState(() {
          _teacherData = data;
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
      appBar: AppBar(title: const Text('Espace Enseignant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_teacherData != null) ...[
              // Welcome Section
              Text(
                'Bonjour, Pr. ${_teacherData!.prenom} ! 👋',
                style: ShadTheme.of(context).textTheme.h2,
              ),
              const SizedBox(height: 4),
              const Text(
                'Bienvenue dans votre espace professionnel.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (_teacherData!.estChefDepartement) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        "Chef de Département",
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Profile Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            _teacherData!.prenom.substring(0, 1) +
                                _teacherData!.nom.substring(0, 1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          "${_teacherData!.prenom} ${_teacherData!.nom}",
                        ),
                        subtitle: Text(_teacherData!.email),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.work,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Spécialité: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(_teacherData!.specialite ?? "Non spécifié"),
                          ],
                        ),
                      ),
                      if (_teacherData!.estChefDepartement &&
                          _teacherData!.departementsDiriges.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.business,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Direction: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: _teacherData!.departementsDiriges
                                      .map(
                                        (d) => Chip(
                                          label: Text(
                                            "${d.libelle} (${d.code})",
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- SESSIONS DU JOUR ---
              Text(
                'Séances du Jour',
                style: ShadTheme.of(context).textTheme.h4,
              ),
              const SizedBox(height: 16),
              _buildSessionsDuJour(),

              const SizedBox(height: 24),

              // Quick Actions (Emploi du temps)
              Text('Accès Rapide', style: ShadTheme.of(context).textTheme.h4),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Mon Emploi du Temps',
                    icon: Icons.calendar_today,
                    onTap: () => context.go('/enseignant/edt'),
                    color: Colors.blue.shade100,
                    iconColor: Colors.blue,
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Gestion Salles (À venir)',
                    icon: Icons.room,
                    onTap: () {},
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange,
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Gestion Justificatifs',
                    icon: Icons.description,
                    onTap: () => context.go('/enseignant/justifications'),
                    color: Colors.purple.shade100,
                    iconColor: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Modules Taught
              Text(
                'Modules Enseignés',
                style: ShadTheme.of(context).textTheme.h4,
              ),
              const SizedBox(height: 16),
              if (_teacherData!.modulesEnseignes.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.book, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("Aucun module assigné ce semestre."),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _teacherData!.modulesEnseignes.length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final mod = _teacherData!.modulesEnseignes[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.book, color: Colors.purple),
                        ),
                        title: Text(
                          mod.moduleLibelle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${mod.semestreLibelle ?? ''} - ${mod.promotionCode ?? ''}",
                        ),
                        trailing: Chip(
                          label: Text(mod.code ?? 'CODE'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsDuJour() {
    return FutureBuilder<List<ProfesseurSeanceDto>>(
      future: _teacherService.getMesSeancesActive(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Erreur chargement séances: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final todaySeances = snapshot.data ?? [];
        // filtering is handled by backend now

        if (todaySeances.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text("Aucune séance prévue pour aujourd'hui."),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todaySeances.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final seance = todaySeances[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: seance.sessionOuverte
                      ? Colors.green
                      : Colors.blue.withOpacity(0.5),
                ),
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
                          seance.moduleNom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Badge(
                          label: Text(seance.typeSeance),
                          backgroundColor: Colors.blueGrey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        const SizedBox(width: 4),
                        Text(
                          "${seance.heureDebut.substring(0, 5)} - ${seance.heureFin.substring(0, 5)}",
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.class_, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("Salle: ${seance.salleNom ?? 'N/A'}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Classe: ${seance.classeCode}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!seance.sessionOuverte)
                          ShadButton(
                            size: ShadButtonSize.sm,
                            onPressed: () =>
                                _openSessionDialog(context, seance.id),
                            child: const Text("Ouvrir Session"),
                          )
                        else
                          ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            onPressed: () => _closeSession(context, seance.id),
                            child: const Text("Clôturer & Valider"),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
              const Text("Spécifiez la durée de validité (minutes)"),
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
                  setState(() {}); // Refresh UI
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
    // Confirmation Dialog
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _teacherService.validerSession(seanceId);
                setState(() {}); // Refresh UI
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
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // try {
      //   await _teacherService.validerSession(seanceId);
      //   setState(() {}); // Refresh UI
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text("Session clôturée avec succès")),
      //     );
      //   }
      // } catch (e) {
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(
      //       context,
      //     ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      //   }
      // }
    }
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
