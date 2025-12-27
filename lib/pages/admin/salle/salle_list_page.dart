import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../apiservice/admin/admin_salle_service.dart';
import '../../../../dto/salle/salle_dto.dart';
import '../../../../main.dart';

class SalleListPage extends StatefulWidget {
  const SalleListPage({super.key});

  @override
  State<SalleListPage> createState() => _SalleListPageState();
}

class _SalleListPageState extends State<SalleListPage> {
  final AdminSalleService _service = AdminSalleService();

  List<SalleDto> _salles = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchSalles();
  }

  Future<void> _fetchSalles() async {
    setState(() => _isLoading = true);
    try {
      final response = await _service.getAllSalles(page: _currentPage, size: _pageSize);
      
      setState(() {
        if (response is Map<String, dynamic> && response.containsKey('content')) {
          final content = response['content'] as List;
          _salles = content.map((e) => SalleDto.fromJson(e)).toList();
          _totalPages = response['totalPages'] ?? 1;
        } else if (response is List) {
          _salles = response.map((e) => SalleDto.fromJson(e)).toList();
          _totalPages = 1;
        } else {
          _salles = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Erreur: ${e.toString()}", isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cette salle ?"),
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
      await _service.deleteSalle(id);
      _showSnackBar("Salle supprimée");
      _fetchSalles();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Salles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSalles,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _salles.isEmpty
                    ? const Center(child: Text("Aucune salle trouvée"))
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
          // Pagination
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() => _currentPage--);
                            _fetchSalles();
                          }
                        : null,
                  ),
                  Text("Page ${_currentPage + 1} / $_totalPages"),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages - 1
                        ? () {
                            setState(() => _currentPage++);
                            _fetchSalles();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/admin/salles/new');
          if (result == true) _fetchSalles();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _salles.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final salle = _salles[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text("${salle.code} - ${salle.type}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Capacité: ${salle.capacite} | Bloc: ${salle.blocNom ?? salle.blocId}"),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final result = await context.push('/admin/salles/edit/${salle.id}');
                  if (result == true) _fetchSalles();
                } else if (value == 'delete') {
                  _handleDelete(salle.id);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("Modifier")],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Supprimer")],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Code")),
              DataColumn(label: Text("Type")),
              DataColumn(label: Text("Capacité")),
              DataColumn(label: Text("Bloc")),
              DataColumn(label: Text("Actions")),
            ],
            rows: _salles.map((salle) {
              return DataRow(
                cells: [
                  DataCell(Text(salle.id.toString())),
                  DataCell(Text(salle.code)),
                  DataCell(Text(salle.type)),
                  DataCell(Text(salle.capacite.toString())),
                  DataCell(Text(salle.blocNom ?? salle.blocId.toString())),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await context.push('/admin/salles/edit/${salle.id}');
                            if (result == true) _fetchSalles();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _handleDelete(salle.id),
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
