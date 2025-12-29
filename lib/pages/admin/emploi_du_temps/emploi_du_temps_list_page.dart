import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_emploi_du_temps_service.dart';
import 'package:flutter_dashboard_app/dto/emploi_du_temps/emploi_du_temps_dto.dart';
import 'package:flutter_dashboard_app/main.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminEmploiDuTempsListPage extends StatefulWidget {
  const AdminEmploiDuTempsListPage({super.key});

  @override
  State<AdminEmploiDuTempsListPage> createState() => _AdminEmploiDuTempsListPageState();
}

class _AdminEmploiDuTempsListPageState extends State<AdminEmploiDuTempsListPage> {
  final AdminEmploiDuTempsService _service = AdminEmploiDuTempsService();

  List<EmploiDuTempsDto> _emploisDuTemps = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEmploisDuTemps();
  }

  Future<void> _fetchEmploisDuTemps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getAllEmploiDuTemps();
      setState(() {
        _emploisDuTemps = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Êtes-vous sûr de vouloir supprimer cet emploi du temps ?"),
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
      await _service.deleteEmploiDuTemps(id);
      _showSnackBar("Emploi du temps supprimé avec succès");
      _fetchEmploisDuTemps();
    } catch (e) {
      _showSnackBar("Erreur suppression: ${e.toString()}", isError: true);
    }
  }

  Future<void> _handleDownload(int id, String? nom) async {
    try {
      final bytes = await _service.downloadTimetablePdf(id); // List<int>
      
      final dir = await getTemporaryDirectory();
      // Sanitize filename
      final safeNom = (nom ?? 'emploi_du_temps_${id}').replaceAll(RegExp(r'[^\w\s\.-]'), '_');
      final file = File('${dir.path}/$safeNom.pdf');
      
      await file.writeAsBytes(bytes);
      
      _showSnackBar("Téléchargement réussi. Ouverture...");
      
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
         _showSnackBar("Impossible d'ouvrir le fichier: ${result.message}", isError: true);
      }
    } catch (e) {
      _showSnackBar("Erreur téléchargement: ${e.toString()}", isError: true);
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

  void _navToCreate() async {
    final result = await context.push('/admin/emploi-du-temps/new');
    if (result == true) _fetchEmploisDuTemps();
  }

  void _navToEdit(int id) async {
    final result = await context.push('/admin/emploi-du-temps/edit/$id');
    if (result == true) _fetchEmploisDuTemps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Gestion des Emplois du Temps"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text("Erreur: $_errorMessage", style: const TextStyle(color: Colors.red)))
          : _emploisDuTemps.isEmpty
          ? const Center(child: Text("Aucun emploi du temps trouvé."))
          : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navToCreate,
        label: const Text("Ajouter"),
        icon: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _emploisDuTemps.length,
      itemBuilder: (context, index) {
        final edt = _emploisDuTemps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(edt.nom ?? "Sans nom", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${edt.classeCode ?? '-'} | ${edt.semestreNum ?? '-'}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.fileText),
                  onPressed: () => _handleDownload(edt.id!, edt.nom),
                  tooltip: "PDF",
                ),
                IconButton(
                  icon: const Icon(LucideIcons.calendarClock, color: Colors.purple),
                  onPressed: () => context.push('/admin/emploi-du-temps/${edt.id!}/manage'),
                  tooltip: "Gérer Séances",
                ),
                IconButton(
                  icon: const Icon(LucideIcons.edit, color: Colors.blue),
                  onPressed: () => _navToEdit(edt.id!),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, color: Colors.red),
                  onPressed: () => _handleDelete(edt.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
