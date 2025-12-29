
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_inscription_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_etudiant_service.dart';
import 'package:flutter_dashboard_app/dto/inscription/inscription_dto.dart';
import 'package:flutter_dashboard_app/dto/inscription/inscription_request.dart';
import 'package:flutter_dashboard_app/dto/etudiant/etudiant_dto.dart';
import 'package:flutter_dashboard_app/main.dart'; // Pour le scaffoldMessenger global

class PromotionInscriptionsPage extends StatefulWidget {
  final int promotionId;
  final String? promotionCode;

  const PromotionInscriptionsPage({
    super.key,
    required this.promotionId,
    this.promotionCode,
  });

  @override
  State<PromotionInscriptionsPage> createState() =>
      _PromotionInscriptionsPageState();
}

class _PromotionInscriptionsPageState
    extends State<PromotionInscriptionsPage> {
  final AdminInscriptionService _inscriptionService = AdminInscriptionService();
  final AdminEtudiantService _etudiantService = AdminEtudiantService();

  List<InscriptionDto> _inscriptions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInscriptions();
  }

  // --- API CALLS ---

  Future<void> _fetchInscriptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _inscriptionService
          .getInscriptionsByPromotion(widget.promotionId);
      setState(() {
        _inscriptions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteInscription(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cette inscription ?"),
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
      await _inscriptionService.deleteInscription(id);
      _showSnackBar("Inscription supprimée.", isError: false);
      _fetchInscriptions();
    } catch (e) {
      _showSnackBar("Erreur lors de la suppression: $e", isError: true);
    }
  }

  Future<void> _importExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        
        setState(() => _isLoading = true);
        
        await _inscriptionService.importInscriptionsExcel(file, widget.promotionId);
        
        _showSnackBar("Importation réussie", isError: false);
        _fetchInscriptions(); // Reload list to see new students if auto-enrolled or just to refresh
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Erreur lors de l'importation: $e", isError: true);
    }
  }

  // --- MODAL D'AJOUT (RECHERCHE ETUDIANT) ---
  
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddInscriptionDialog(
        promotionId: widget.promotionId,
        etudiantService: _etudiantService,
        inscriptionService: _inscriptionService,
        onSuccess: _fetchInscriptions,
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Inscriptions - ${widget.promotionCode ?? widget.promotionId}"),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.upload_file, color: Colors.green),
                tooltip: "Importer Excel",
                onPressed: _importExcel,
              ),
            ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Erreur: $_errorMessage", style: const TextStyle(color: Colors.red)))
              : _inscriptions.isEmpty
                  ? _buildEmptyState()
                  : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text("Ajouter"),
        icon: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Aucune inscription trouvée pour cette promotion.",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text("Inscrire un étudiant"),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _inscriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _inscriptions[index];
        return Card(
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                item.etudiantNomComplet?.substring(0, 1).toUpperCase() ?? "?",
                style: TextStyle(color: Colors.blue.shade800),
              ),
            ),
            title: Text(item.etudiantNomComplet ?? "Sans Nom"),
            subtitle: Text("ID: ${item.etudiantId} | ${item.redoublant ? 'Redoublant' : 'Non redoublant'}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteInscription(item.id!),
            ),
          ),
        );
      },
    );
  }
}

// --- SOUS-WIDGET: DIALOGUE D'AJOUT ---

class _AddInscriptionDialog extends StatefulWidget {
  final int promotionId;
  final AdminEtudiantService etudiantService;
  final AdminInscriptionService inscriptionService;
  final VoidCallback onSuccess;

  const _AddInscriptionDialog({
    required this.promotionId,
    required this.etudiantService,
    required this.inscriptionService,
    required this.onSuccess,
  });

  @override
  State<_AddInscriptionDialog> createState() => __AddInscriptionDialogState();
}

class __AddInscriptionDialogState extends State<_AddInscriptionDialog> {
  // Liste des étudiants sans inscription
  List<EtudiantDto> _students = [];
  EtudiantDto? _selectedStudent;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Options
  bool _redoublant = false;
  int _annee = 1;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      // Idéalement, on charge les étudiants NON inscrits ou tous les étudiants
      // Pour l'instant, utilisons getAll ou une méthode spécifique si disponible.
      // Le controlleur d'étudiant a "/sans-inscription"
      final students = await widget.etudiantService.getEtudiantsSansInscription();
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback si l'endpoint n'existe pas ou erreur
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedStudent == null) return;
    setState(() => _isSubmitting = true);

    try {
      final req = InscriptionRequest(
        etudiantId: _selectedStudent!.id,
        promotionId: widget.promotionId,
        redoublant: _redoublant,
        annee: _annee,
      );
      await widget.inscriptionService.createInscription(req);
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        rootScaffoldMessengerKey.currentState?.showSnackBar(
           const SnackBar(content: Text("Inscription réussie"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        rootScaffoldMessengerKey.currentState?.showSnackBar(
           SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nouvelle Inscription"),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<EtudiantDto>(
                    decoration: const InputDecoration(labelText: "Étudiant"),
                    isExpanded: true,
                    items: _students.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text("${e.nom} ${e.prenom} (${e.email})"),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedStudent = val),
                    value: _selectedStudent,
                    hint: const Text("Sélectionner un étudiant"),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Redoublant"),
                    value: _redoublant,
                    onChanged: (val) => setState(() => _redoublant = val),
                  ),
                  TextFormField(
                    initialValue: _annee.toString(),
                    decoration: const InputDecoration(labelText: "Année (1, 2, 3...)"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _annee = int.tryParse(val) ?? 1,
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: (_selectedStudent != null && !_isSubmitting) ? _handleSubmit : null,
          child: _isSubmitting 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Inscrire"),
        ),
      ],
    );
  }
}
