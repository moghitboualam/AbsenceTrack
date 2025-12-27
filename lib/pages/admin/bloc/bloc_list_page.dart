import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../apiservice/admin/admin_bloc_service.dart';
import '../../../../dto/bloc/bloc_dto.dart';
import '../../../../main.dart';

class BlocListPage extends StatefulWidget {
  const BlocListPage({super.key});

  @override
  State<BlocListPage> createState() => _BlocListPageState();
}

class _BlocListPageState extends State<BlocListPage> {
  final AdminBlocService _service = AdminBlocService();

  List<BlocDto> _blocs = [];
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchBlocs();
  }

  Future<void> _fetchBlocs() async {
    setState(() => _isLoading = true);
    try {
      final response = await _service.getAllBlocs(page: _currentPage, size: _pageSize);
      
      setState(() {
        if (response is Map<String, dynamic> && response.containsKey('content')) {
          final content = response['content'] as List;
          _blocs = content.map((e) => BlocDto.fromJson(e)).toList();
          _totalPages = response['totalPages'] ?? 1;
        } else if (response is List) {
          _blocs = response.map((e) => BlocDto.fromJson(e)).toList();
          _totalPages = 1;
        } else {
          _blocs = [];
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
        content: const Text("Voulez-vous vraiment supprimer ce bloc ?"),
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
      await _service.deleteBloc(id);
      _showSnackBar("Bloc supprimé");
      _fetchBlocs();
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
        title: const Text("Gestion des Blocs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBlocs,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _blocs.isEmpty
                    ? const Center(child: Text("Aucun bloc trouvé"))
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
          // Pagination simple
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
                            _fetchBlocs();
                          }
                        : null,
                  ),
                  Text("Page ${_currentPage + 1} / $_totalPages"),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages - 1
                        ? () {
                            setState(() => _currentPage++);
                            _fetchBlocs();
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
          final result = await context.push('/admin/blocs/new');
          if (result == true) _fetchBlocs();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _blocs.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final bloc = _blocs[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(bloc.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(bloc.localisation),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final result = await context.push('/admin/blocs/edit/${bloc.id}');
                  if (result == true) _fetchBlocs();
                } else if (value == 'delete') {
                  _handleDelete(bloc.id);
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
              DataColumn(label: Text("Nom")),
              DataColumn(label: Text("Localisation")),
              DataColumn(label: Text("Actions")),
            ],
            rows: _blocs.map((bloc) {
              return DataRow(
                cells: [
                  DataCell(Text(bloc.id.toString())),
                  DataCell(Text(bloc.nom)),
                  DataCell(Text(bloc.localisation)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await context.push('/admin/blocs/edit/${bloc.id}');
                            if (result == true) _fetchBlocs();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _handleDelete(bloc.id),
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
