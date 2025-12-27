import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../apiservice/admin/admin_departement_service.dart';
import '../../../dto/departement/departement_dto.dart';
import '../../../main.dart'; // Pour rootScaffoldMessengerKey

class DepartementListPage extends StatefulWidget {
  const DepartementListPage({super.key});

  @override
  State<DepartementListPage> createState() => _DepartementListPageState();
}

class _DepartementListPageState extends State<DepartementListPage> {
  final AdminDepartementService _service = AdminDepartementService();

  // États
  List<DepartementDto> _departements = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Pagination
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchDepartements();
  }

  // --- LOGIQUE MÉTIER ---

  Future<void> _fetchDepartements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.getAllDepartements(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        final content = response['content'] as List;
        _departements = content.map((e) => DepartementDto.fromJson(e)).toList();
        _totalPages = response['totalPages'] ?? 0;
        _totalElements = response['totalElements'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      _showSnackBar(
        "Erreur lors du chargement: ${e.toString()}",
        isError: true,
      );
    }
  }

  Future<void> _handleDelete(int id) async {
    // 1. Confirmation Dialog (équivalent window.confirm)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer ce département ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Appel API
    try {
      await _service.deleteDepartement(id);
      _showSnackBar("Département supprimé avec succès");

      // Gestion pagination après suppression
      if (_departements.length == 1 && _currentPage > 0) {
        setState(() => _currentPage--);
      }
      _fetchDepartements();
    } catch (e) {
      _showSnackBar("Erreur suppression: ${e.toString()}", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- NAVIGATION ---

  void _navToCreate() async {
    final result = await context.push('/admin/departements/new');
    if (result == true) _fetchDepartements();
  }

  void _navToEdit(int id) async {
    final result = await context.push('/admin/departements/edit/$id');
    if (result == true) _fetchDepartements();
  }

  void _navToDetails(int id) {
    context.push('/admin/departements/details/$id');
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Liste des Départements"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Menu d'export (Dropdown)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) => _showSnackBar("Export $val non implémenté"),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text("Exporter Excel"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 18),
                    SizedBox(width: 8),
                    Text("Exporter PDF"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec bouton Ajouter (Visible sur Desktop)
          // Sur mobile on utilise souvent le FloatingActionButton
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Text(
                      "Erreur: $_errorMessage",
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _departements.isEmpty
                ? const Center(child: Text("Aucun département trouvé."))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive Switch
                      if (constraints.maxWidth < 600) {
                        return _buildMobileList();
                      } else {
                        return _buildDesktopTable();
                      }
                    },
                  ),
          ),

          // Pagination
          _buildPagination(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navToCreate,
        label: const Text("Ajouter"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // --- VUE MOBILE (Liste de Cartes) ---
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _departements.length,
      itemBuilder: (context, index) {
        final dept = _departements[index];
        // Modification pour utiliser chefNom
        var chefNomComplet = dept.chefNom;
        if (chefNomComplet == null && dept.chef != null) {
            chefNomComplet = "${dept.chef!.prenom} ${dept.chef!.nom}";
        }
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dept.code ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    // Actions Menu Icon
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz),
                      onSelected: (val) {
                        if (val == 'edit') _navToEdit(dept.id!);
                        if (val == 'delete') _handleDelete(dept.id!);
                        if (val == 'details') _navToDetails(dept.id!);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text("Modifier"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 16),
                              SizedBox(width: 8),
                              Text("Détails"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Supprimer",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dept.libelle ?? "Sans libellé",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Chef: ${chefNomComplet ?? 'Non assigné'}",
                      style: const TextStyle(color: Colors.grey),
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

  // --- VUE DESKTOP (DataTable) ---
  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
            columns: const [
              DataColumn(
                label: Text(
                  "Code",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Libellé",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Chef",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Actions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: _departements.map((dept) {
              // Modification pour utiliser chefNom directement
              // Si chefNom est null, on tente le fallback sur l'objet chef (si présent)
              var chefNomComplet = dept.chefNom;
              if (chefNomComplet == null && dept.chef != null) {
                 chefNomComplet = "${dept.chef!.prenom} ${dept.chef!.nom}";
              }

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      dept.code ?? "",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(Text(dept.libelle ?? "")),
                  DataCell(
                    Text(
                      chefNomComplet ?? 'Non assigné',
                      style: TextStyle(
                        color: chefNomComplet == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          tooltip: "Modifier",
                          onPressed: () => _navToEdit(dept.id!),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          tooltip: "Détails",
                          onPressed: () => _navToDetails(dept.id!),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          tooltip: "Supprimer",
                          onPressed: () => _handleDelete(dept.id!),
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

  // --- PAGINATION ---
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info texte (Mobile : caché ou réduit, Desktop : complet)
          Flexible(
            child: Text(
              "Affichage ${_currentPage * _pageSize + 1} à ${(_currentPage * _pageSize) + _departements.length} sur $_totalElements",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Row(
            children: [
              OutlinedButton(
                onPressed: _currentPage > 0
                    ? () {
                        setState(() => _currentPage--);
                        _fetchDepartements();
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text("Précédent"),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () {
                        setState(() => _currentPage++);
                        _fetchDepartements();
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text("Suivant"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
