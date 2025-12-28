import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_promotion_service.dart';
import 'package:flutter_dashboard_app/dto/promotion/promotion_dto.dart';
import 'package:flutter_dashboard_app/main.dart'; 

class PromotionListPage extends StatefulWidget {
  const PromotionListPage({super.key});

  @override
  State<PromotionListPage> createState() => _PromotionListPageState();
}

class _PromotionListPageState extends State<PromotionListPage> {
  final AdminPromotionService _service = AdminPromotionService();

  // États
  List<PromotionDto> _promotions = [];
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
    _fetchPromotions();
  }

  // --- LOGIQUE MÉTIER ---

  Future<void> _fetchPromotions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.getAllPromotions(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        final content = response['content'] as List;
        _promotions = content.map((e) => PromotionDto.fromJson(e)).toList();
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer cette promotion ?",
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
      await _service.deletePromotion(id);
      _showSnackBar("Promotion supprimée avec succès");

      if (_promotions.length == 1 && _currentPage > 0) {
        setState(() => _currentPage--);
      }
      _fetchPromotions();
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
    final result = await context.push('/admin/promotions/new');
    if (result == true) _fetchPromotions();
  }

  void _navToEdit(int id) async {
    final result = await context.push('/admin/promotions/edit/$id');
    if (result == true) _fetchPromotions();
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Liste des Promotions"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
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
                : _promotions.isEmpty
                ? const Center(child: Text("Aucune promotion trouvée."))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return _buildMobileList();
                      } else {
                        return _buildDesktopTable();
                      }
                    },
                  ),
          ),
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

  // --- VUE MOBILE ---
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _promotions.length,
      itemBuilder: (context, index) {
        final promo = _promotions[index];
       
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
                      promo.codePromotion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz),
                      onSelected: (val) {
                        if (val == 'edit') _navToEdit(promo.id);
                        if (val == 'delete') _handleDelete(promo.id);
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
                Text("Filière: ${promo.filiereNom ?? '-'}"),
                Text("Année Univ: ${promo.anneeUniversitaireNom ?? '-'}"),
                Text("Année: ${promo.annee}"),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- VUE DESKTOP ---
  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
            columns: const [
              DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Filière", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Année Univ", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Année (Cursus)", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _promotions.map((promo) {
              return DataRow(
                cells: [
                  DataCell(Text(promo.codePromotion, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(promo.filiereNom ?? "-")),
                  DataCell(Text(promo.anneeUniversitaireNom ?? "-")),
                  DataCell(Text(promo.annee.toString())),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          tooltip: "Modifier",
                          onPressed: () => _navToEdit(promo.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          tooltip: "Supprimer",
                          onPressed: () => _handleDelete(promo.id),
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
          Flexible(
            child: Text(
              "Affichage ${_currentPage * _pageSize + 1} à ${(_currentPage * _pageSize) + _promotions.length} sur $_totalElements",
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
                        _fetchPromotions();
                      }
                    : null,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                child: const Text("Précédent"),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () {
                        setState(() => _currentPage++);
                        _fetchPromotions();
                      }
                    : null,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                child: const Text("Suivant"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
