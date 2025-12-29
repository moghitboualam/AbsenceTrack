import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../apiservice/admin/admin_enseignant_service.dart';
import '../../../dto/enseignant/enseignant_dto.dart';
import '../../../main.dart'; // Pour rootScaffoldMessengerKey

class EnseignantListPage extends StatefulWidget {
  const EnseignantListPage({super.key});

  @override
  State<EnseignantListPage> createState() => _EnseignantListPageState();
}

class _EnseignantListPageState extends State<EnseignantListPage> {
  final AdminEnseignantService _service = AdminEnseignantService();

  // Données et États
  List<EnseignantDto> _enseignants = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;
  final int _pageSize = 100; // Increased for better client-side filtering

  // Filtres
  String _searchQuery = "";
  String? _selectedSpecialty;
  final List<String> _specialtyOptions = [
    "Informatique",
    "Mathématiques",
    "Physique",
    "Chimie",
    "Biologie",
    "Sciences Économiques",
    "Droit",
    "Gestion",
    "Communication",
    "Langues",
  ];

  @override
  void initState() {
    super.initState();
    _fetchEnseignants();
  }

  // --- LOGIQUE MÉTIER ---

  Future<void> _fetchEnseignants() async {
    setState(() => _isLoading = true);
    try {
      final response = await _service.getAllEnseignants(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        final content = response['content'] as List;
        _enseignants = content.map((e) => EnseignantDto.fromJson(e)).toList();
        _totalPages = response['totalPages'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Erreur de chargement: ${e.toString()}", isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete(int id) async {
    // Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer cet enseignant ?",
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

    try {
      await _service.deleteEnseignant(id);
      _showSnackBar("Enseignant supprimé avec succès");
      _fetchEnseignants(); // Recharger la liste
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

  // Logique de filtrage (Client-side comme dans votre React)
  List<EnseignantDto> get _filteredEnseignants {
    return _enseignants.where((enseignant) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (enseignant.nom?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (enseignant.prenom?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false) ||
          (enseignant.email?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      final matchesSpecialty =
          _selectedSpecialty == null ||
          enseignant.specialite == _selectedSpecialty;

      return matchesSearch && matchesSpecialty;
    }).toList();
  }

  // --- CONSTRUCTION UI ---

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredEnseignants;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond léger comme Shadcn
      appBar: AppBar(
        title: const Text("Liste des Enseignants"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Bouton Actions (Export)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'excel')
                _showSnackBar("Export Excel non implémenté");
              if (value == 'pdf') _showSnackBar("Export PDF non implémenté");
            },
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
          // --- BARRE DE FILTRES ET RECHERCHE ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // Barre de recherche
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Rechercher...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Dropdown Filtre (Visible sur mobile via icône ou desktop complet)
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedSpecialty,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Spécialité",
                        ),
                        isExpanded: true, // Pour éviter le débordement
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Toutes"),
                          ),
                          ..._specialtyOptions.map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedSpecialty = val),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- CONTENU PRINCIPAL (Responsive) ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                ? const Center(child: Text("Aucun enseignant trouvé"))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Point de rupture responsive (700px)
                      if (constraints.maxWidth < 700) {
                        return _buildMobileList(filteredList);
                      } else {
                        return _buildDesktopTable(filteredList);
                      }
                    },
                  ),
          ),

          // --- PAGINATION ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _currentPage > 0
                      ? () {
                          setState(() => _currentPage--);
                          _fetchEnseignants();
                        }
                      : null,
                  child: const Text("Précédent"),
                ),
                Text("Page ${_currentPage + 1} sur $_totalPages"),
                OutlinedButton(
                  onPressed: _currentPage < _totalPages - 1
                      ? () {
                          setState(() => _currentPage++);
                          _fetchEnseignants();
                        }
                      : null,
                  child: const Text("Suivant"),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bouton Flottant Ajouter (Plus ergonomique sur mobile)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigation vers la page de création (à créer si inexistante)
          final result = await context.push('/admin/enseignants/new');
          if (result == true) _fetchEnseignants();
        },
        label: const Text("Ajouter"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // --- VUE MOBILE (Cartes) ---
  Widget _buildMobileList(List<EnseignantDto> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${item.nom} ${item.prenom}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.email ?? "N/A",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      item.specialite ?? "N/A",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final result = await context.push(
                          '/admin/enseignants/edit/${item.id}',
                        );
                        if (result == true) _fetchEnseignants();
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Modifier"),
                    ),
                    TextButton.icon(
                      onPressed: () => _handleDelete(item.id!),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text("Supprimer"),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
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

  // --- VUE DESKTOP (Tableau) ---
  Widget _buildDesktopTable(List<EnseignantDto> items) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
              columns: const [
                DataColumn(
                  label: Text(
                    "ID",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Nom & Prénom",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Spécialité",
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
              rows: items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.id.toString())),
                    DataCell(Text("${item.nom} ${item.prenom}")),
                    DataCell(Text(item.email ?? "")),
                    DataCell(Text(item.specialite ?? "N/A")),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await context.push(
                                '/admin/enseignants/edit/${item.id}',
                              );
                              if (result == true) _fetchEnseignants();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _handleDelete(item.id!),
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
      ),
    );
  }

  // Petit widget pour le badge Chef Département
}
