import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_classes_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_etudiant_service.dart'; // Need this for getEtudiantsByClasseId if not in ClassesService
import 'package:flutter_dashboard_app/dto/classes/classes_dto.dart';
import 'package:flutter_dashboard_app/dto/etudiant/etudiant_dto.dart';

class PromotionClassesPage extends StatefulWidget {
  final int promotionId;
  final String? promotionCode; // Optional, for display

  const PromotionClassesPage({super.key, required this.promotionId, this.promotionCode});

  @override
  State<PromotionClassesPage> createState() => _PromotionClassesPageState();
}

class _PromotionClassesPageState extends State<PromotionClassesPage> {
  final AdminClassesService _classesService = AdminClassesService();
  final AdminEtudiantService _etudiantService = AdminEtudiantService(); // Assuming this exists with getEtudiantsByClasseId

  List<ClassesDto> _classes = [];
  bool _isLoading = true;
  String? _errorMessage;

  // For expansion
  final Map<int, bool> _expandedClasses = {};
  final Map<int, List<EtudiantDto>> _studentLists = {};
  final Map<int, bool> _loadingStudents = {};

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _classesService.getClassesByPromotionId(widget.promotionId);
      setState(() {
        _classes = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur chargement classes: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateClasses() async {
    setState(() => _isLoading = true);
    try {
      await _classesService.assignStudentsToClasses(widget.promotionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Classes générées avec succès")),
      );
      _fetchClasses(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur génération: ${e.toString()}"), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleExpansion(int classId) async {
    final isExpanded = _expandedClasses[classId] ?? false;
    
    setState(() {
      _expandedClasses[classId] = !isExpanded;
    });

    if (!isExpanded && (!_studentLists.containsKey(classId) || _studentLists[classId]!.isEmpty)) {
      // Fetch students if expanding and not loaded
      setState(() {
        _loadingStudents[classId] = true;
      });
       
      try {
        // We need to check if AdminEtudiantService has getEtudiantsByClasseId.
        // The React code uses getEtudiantsByClasseId(classId).
        // If not, I'll need to implement it or use what's available.
        // Assuming AdminEtudiantService will be checked/updated.
        final students = await _etudiantService.getEtudiantsByClasseId(classId); 
        setState(() {
          _studentLists[classId] = students;
        });
      } catch (e) {
        // Fallback or error
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement étudiants: ${e.toString()}"), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _loadingStudents[classId] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Classes - ${widget.promotionCode ?? 'Promotion ${widget.promotionId}'}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.autorenew),
            tooltip: "Répartir les étudiants (Générer)",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Répartition Automatique"),
                  content: const Text("Voulez-vous lancer la répartition automatique des étudiants dans les classes ?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
                    ElevatedButton(
                      onPressed: () {
                         Navigator.pop(ctx);
                         _generateClasses();
                      },
                      child: const Text("Confirmer"),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _classes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Aucune classe pour cette promotion."),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _generateClasses,
                            child: const Text("Générer les classes"),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        final cls = _classes[index];
                        final isExpanded = _expandedClasses[cls.id] ?? false;
                        final isLoadingStudents = _loadingStudents[cls.id] ?? false;
                        final students = _studentLists[cls.id] ?? [];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(cls.code ?? "Classe #${cls.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Étudiants: ${cls.nbrEleves}"),
                                trailing: IconButton(
                                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                  onPressed: () => _toggleExpansion(cls.id!),
                                ),
                                onTap: () => _toggleExpansion(cls.id!),
                              ),
                              if (isExpanded)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                                  ),
                                  child: isLoadingStudents
                                    ? const Center(child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ))
                                    : students.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text("Aucun étudiant assigné.", style: TextStyle(fontStyle: FontStyle.italic)),
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(bottom: 8.0),
                                                child: Text("Liste des étudiants:", style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                              ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: students.length,
                                                separatorBuilder: (ctx, i) => const Divider(height: 1),
                                                itemBuilder: (ctx, i) {
                                                  final etu = students[i];
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 30, child: Text("${i + 1}", style: const TextStyle(color: Colors.grey))),
                                                        Expanded(child: Text("${etu.nom} ${etu.prenom}")),
                                                        // Add more details if needed
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                )
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
