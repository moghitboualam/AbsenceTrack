import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
// Assurez-vous que ces imports correspondent à votre structure de dossiers
import '../../../dto/etudiant/etudiant_dto.dart';
import '../../../apiservice/admin/admin_etudiant_service.dart';

class EtudiantListPage extends StatefulWidget {
  const EtudiantListPage({super.key});

  @override
  State<EtudiantListPage> createState() => _EtudiantListPageState();
}

class _EtudiantListPageState extends State<EtudiantListPage> {
  final AdminEtudiantService _service = AdminEtudiantService();

  List<EtudiantDto> _etudiants = [];
  bool _isLoading = true;
  bool _isImporting = false;
  int _currentPage = 0;
  int _totalPages = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchEtudiants();
  }

  // --- LOGIQUE MÉTIER ---

  Future<void> _fetchEtudiants() async {
    setState(() => _isLoading = true);
    try {
      final response = await _service.getAllEtudiants(
        page: _currentPage,
        size: _pageSize,
      );
      setState(() {
        _etudiants = List<EtudiantDto>.from(response['students']);
        _totalPages = response['totalPages'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar(
        "Erreur lors du chargement: ${e.toString()}",
        isError: true,
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleExcelImport() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isImporting = true);
      _showSnackBar("Importation en cours...");

      try {
        File file = File(result.files.single.path!);
        await _service.importEtudiantsExcel(file);
        _showSnackBar("Importation réussie !");
        setState(() => _currentPage = 0);
        _fetchEtudiants();
      } catch (e) {
        _showSnackBar("Erreur d'importation: ${e.toString()}", isError: true);
      } finally {
        setState(() => _isImporting = false);
      }
    } else {
      _showSnackBar("Aucun fichier sélectionné", isError: true);
    }
  }

  // --- SUPPRESSION CORRIGÉE ---
  Future<void> _handleDelete(int? id) async {
    if (id == null) return;

    // 1. Demander confirmation
    bool confirm = await _showDeleteDialog();
    if (!confirm) return; // Si l'utilisateur annule, on arrête tout.

    try {
      // 2. Appel au serveur (Opération longue)
      await _service.deleteEtudiant(id);

      // 3. VÉRIFICATION VITALE : Le widget est-il toujours à l'écran ?
      // Si l'utilisateur a quitté la page pendant le chargement, on arrête.
      if (!mounted) return;

      // 4. SOLUTION LISTE : Mise à jour locale immédiate
      // On retire l'élément de la liste visuelle sans attendre le serveur
      setState(() {
        _etudiants.removeWhere((element) => element.id == id);
      });

      // 5. Afficher le message de succès
      _showSnackBar("Étudiant supprimé avec succès");

      // Optionnel : Vous pouvez relancer un fetch en arrière-plan pour être sûr
      // _fetchEtudiants();
    } catch (e) {
      // En cas d'erreur, on vérifie aussi mounted avant d'afficher l'erreur
      if (mounted) {
        _showSnackBar(
          "Erreur lors de la suppression: ${e.toString()}",
          isError: true,
        );
      }
    }
  }

  // --- SNACKBAR ROBUSTE ---
  void _showSnackBar(String message, {bool isError = false}) {
    // On efface les anciens SnackBars pour afficher le nouveau immédiatement
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior:
            SnackBarBehavior.floating, // Flottant c'est souvent plus visible
        margin: const EdgeInsets.all(20), // Un peu de marge
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirmation"),
            content: const Text("Supprimer cet étudiant ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Supprimer",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // --- INTERFACE UTILISATEUR (BUILD) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des Étudiants"),
        actions: [
          if (_isImporting)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'import') _handleExcelImport();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Importer Excel"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Zone de contenu principale (Liste ou Tableau)
                Expanded(
                  child: _etudiants.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucun étudiant trouvé",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            // Si largeur < 600px -> Vue Mobile (Cartes)
                            // Sinon -> Vue Desktop (Tableau)
                            if (constraints.maxWidth < 600) {
                              return _buildMobileListView();
                            } else {
                              return _buildDesktopDataTable();
                            }
                          },
                        ),
                ),

                // Zone de pagination (commune aux deux vues)
                if (_etudiants.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[200]!)),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentPage > 0
                              ? () {
                                  setState(() => _currentPage--);
                                  _fetchEtudiants();
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left, size: 18),
                          label: const Text("Précédent"),
                        ),
                        Text(
                          "Page ${_currentPage + 1} / $_totalPages",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: (_currentPage < _totalPages - 1)
                              ? () {
                                  setState(() => _currentPage++);
                                  _fetchEtudiants();
                                }
                              : null,
                          // Astuce : direction: TextDirection.rtl pour mettre l'icône à droite
                          label: const Text("Suivant"),
                          icon: const Icon(Icons.chevron_right, size: 18),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 1. On attend le retour
          final result = await context.push('/admin/etudiant/new');

          // 2. On rafraîchit si modification validée
          if (result == true) {
            _fetchEtudiants();
          }
        },
        tooltip: "Ajouter un nouvel étudiant",
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- VUE MOBILE : LISTE DE CARTES ---
  Widget _buildMobileListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _etudiants.length,
      itemBuilder: (context, index) {
        final etudiant = _etudiants[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
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
                        "${etudiant.nom} ${etudiant.prenom}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "#${etudiant.id}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        etudiant.email ?? "Non renseigné",
                        style: TextStyle(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        // 1. On attend le retour
                        final result = await context.push(
                          '/admin/etudiant/edit/${etudiant.id}',
                        );

                        // 2. On rafraîchit si modification validée
                        if (result == true) {
                          _fetchEtudiants();
                        }
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Modifier"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _handleDelete(etudiant.id),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text("Supprimer"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- VUE DESKTOP : TABLEAU COMPLET ---
  Widget _buildDesktopDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 800,
          ), // Largeur min pour éviter l'écrasement
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) return null;
              // Pas d'accès direct à l'index ici pour l'alternance simple dans le map,
              // mais on peut le gérer différemment si besoin.
              // Ici on laisse blanc par défaut.
              return Colors.white;
            }),
            columns: const [
              DataColumn(
                label: Text(
                  'ID',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Nom',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Prénom',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: _etudiants.asMap().entries.map((entry) {
              final index = entry.key;
              final etudiant = entry.value;
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  return index.isEven ? Colors.grey[50] : Colors.white;
                }),
                cells: [
                  DataCell(Text(etudiant.id?.toString() ?? '')),
                  DataCell(Text(etudiant.nom ?? '')),
                  DataCell(Text(etudiant.prenom ?? '')),
                  DataCell(Text(etudiant.email ?? '')),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: "Modifier",
                          onPressed: () async {
                            // 1. On attend le retour
                            final result = await context.push(
                              '/admin/etudiant/edit/${etudiant.id}',
                            );

                            // 2. On rafraîchit si modification validée
                            if (result == true) {
                              _fetchEtudiants();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Supprimer",
                          onPressed: () => _handleDelete(etudiant.id),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
