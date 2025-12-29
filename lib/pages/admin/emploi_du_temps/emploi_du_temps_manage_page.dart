import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_emploi_du_temps_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_module_promotion_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_salle_service.dart';
import 'package:flutter_dashboard_app/dto/emploi_du_temps/emploi_du_temps_dto.dart';
import 'package:flutter_dashboard_app/dto/seance/seance_dto.dart';
import 'package:flutter_dashboard_app/dto/seance/seance_request.dart';
import 'package:flutter_dashboard_app/dto/module_promotion/module_promotion_dto.dart';
import 'package:flutter_dashboard_app/dto/salle/salle_dto.dart';
import 'package:flutter_dashboard_app/main.dart';

class AdminEmploiDuTempsManagePage extends StatefulWidget {
  final int id;
  const AdminEmploiDuTempsManagePage({super.key, required this.id});

  @override
  State<AdminEmploiDuTempsManagePage> createState() => _AdminEmploiDuTempsManagePageState();
}

class _AdminEmploiDuTempsManagePageState extends State<AdminEmploiDuTempsManagePage> {
  final AdminEmploiDuTempsService _edtService = AdminEmploiDuTempsService();
  final AdminModulePromotionService _moduleService = AdminModulePromotionService();
  final AdminSalleService _salleService = AdminSalleService();

  EmploiDuTempsDto? _edt;
  List<ModulePromotionDto> _modules = [];
  List<SalleDto> _salles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch EmploiDuTemps
      final edt = await _edtService.getEmploiDuTempsById(widget.id);
      
      // 2. Fetch Modules & Salles
      // Note: getAllSalles returns a Page object (Map), we need content list
      final sallesData = await _salleService.getAllSalles(size: 100); 
      List<SalleDto> sallesList = [];
      if (sallesData is Map && sallesData['content'] != null) {
        sallesList = (sallesData['content'] as List).map((e) => SalleDto.fromJson(e)).toList();
      }

      List<ModulePromotionDto> modulesList = [];
      if (edt.promotionId != null && edt.semestreId != null) {
          modulesList = await _moduleService.getModulesByPromotionAndSemester(edt.promotionId!, edt.semestreId!);
      }

      setState(() {
        _edt = edt;
        _salles = sallesList;
        _modules = modulesList;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Erreur de chargement: ${e.toString()}", isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGenerate() async {
    if (_edt == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Génération Automatique"),
        content: const Text("Voulez-vous générer les séances automatiquement ? Cela peut écraser les données existantes."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Générer")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _edtService.generateEmploiDuTemps(_edt!.classeId!, _edt!.semestreId!);
      _showSnackBar("Génération réussie");
      _loadData(); // Reload to see new seances
    } catch (e) {
      _showSnackBar("Erreur de génération: ${e.toString()}", isError: true);
    }
  }

  Future<void> _showAddSeanceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _AddSeanceDialog(
        edtId: widget.id,
        modules: _modules,
        salles: _salles,
        onSuccess: _loadData,
      ),
    );
  }

  Future<void> _handleDeleteSeance(int seanceId) async {
      final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Supprimer cette séance ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _edtService.deleteSeance(seanceId);
      _showSnackBar("Séance supprimée");
      _loadData();
    } catch (e) {
       _showSnackBar("Erreur: ${e.toString()}", isError: true);
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_edt == null) return const Scaffold(body: Center(child: Text("Emploi du temps introuvable")));

    final seances = _edt!.seanceDtos ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Gérer: ${_edt!.nom}"),
        actions: [
            IconButton(
                icon: const Icon(LucideIcons.refreshCw),
                tooltip: "Rafraîchir",
                onPressed: _loadData,
            )
        ],
      ),
      body: Column(
        children: [
            // Toolbar
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                    children: [
                        ElevatedButton.icon(
                            onPressed: _showAddSeanceDialog,
                            icon: const Icon(LucideIcons.plus),
                            label: const Text("Ajouter Séance Manuelle"),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                            onPressed: _handleGenerate,
                            icon: const Icon(LucideIcons.wand2),
                            label: const Text("Générer Automatiquement"),
                        ),
                    ],
                ),
            ),
            const Divider(),
            Expanded(
                child: seances.isEmpty 
                    ? const Center(child: Text("Aucune séance planifiée."))
                    : ListView.builder(
                        itemCount: seances.length,
                        itemBuilder: (context, index) {
                            final seance = seances[index];
                            return ListTile(
                                leading: CircleAvatar(child: Text(seance.jour?.substring(0, 2).toUpperCase() ?? "?")),
                                title: Text("${seance.modulePromotionLibelle ?? 'Module Inconnu'} (${seance.type})"),
                                subtitle: Text("${seance.heureDebut} - ${seance.heureFin} | ${seance.salleCode ?? 'Sans salle'} | ${seance.enseignantNomComplet ?? ''}"),
                                trailing: IconButton(
                                    icon: const Icon(LucideIcons.trash2, color: Colors.red),
                                    onPressed: () => _handleDeleteSeance(seance.id!),
                                ),
                            );
                        },
                    ),
            ),
        ],
      ),
    );
  }
}

class _AddSeanceDialog extends StatefulWidget {
  final int edtId;
  final List<ModulePromotionDto> modules;
  final List<SalleDto> salles;
  final VoidCallback onSuccess;

  const _AddSeanceDialog({
    required this.edtId,
    required this.modules,
    required this.salles,
    required this.onSuccess,
  });

  @override
  State<_AddSeanceDialog> createState() => _AddSeanceDialogState();
}

class _AddSeanceDialogState extends State<_AddSeanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminEmploiDuTempsService _edtService = AdminEmploiDuTempsService();
  
  String _jour = 'LUNDI';
  String _heureDebut = '08:00';
  String _heureFin = '10:00';
  String _type = 'COURS';
  int? _selectedModuleId;
  int? _selectedSalleId;
  bool _isLoading = false;

  final List<String> _jours = ['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI'];
  final List<String> _types = ['COURS', 'TP', 'TD'];

  Future<void> _submit() async {
      if (!_formKey.currentState!.validate()) return;
      
      setState(() => _isLoading = true);
      try {
          final request = SeanceRequest(
              emploiDuTempsId: widget.edtId,
              jour: _jour,
              heureDebut: _heureDebut, // Ensure format HH:mm
              heureFin: _heureFin,
              modulePromotionId: _selectedModuleId,
              salleId: _selectedSalleId,
              type: _type,
          );
          
          await _edtService.addSeance(request);
          if (mounted) {
              Navigator.pop(context);
              widget.onSuccess();
          }
      } catch (e) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      } finally {
          setState(() => _isLoading = false);
      }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter une Séance"),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                    value: _jour,
                    decoration: const InputDecoration(labelText: "Jour"),
                    items: _jours.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() => _jour = v!),
                ),
                const SizedBox(height: 12),
                Row(children: [
                    Expanded(child: TextFormField(
                        initialValue: _heureDebut,
                        decoration: const InputDecoration(labelText: "Début (HH:mm)"),
                        onChanged: (v) => _heureDebut = v,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(
                        initialValue: _heureFin,
                        decoration: const InputDecoration(labelText: "Fin (HH:mm)"),
                        onChanged: (v) => _heureFin = v,
                    )),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: "Type"),
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 12),
                 DropdownButtonFormField<int>(
                    value: _selectedModuleId,
                    decoration: const InputDecoration(labelText: "Module"),
                    items: widget.modules.map((m) => DropdownMenuItem(value: m.id, child: Text(m.moduleReferenceNom ?? m.code))).toList(),
                    onChanged: (v) => setState(() => _selectedModuleId = v),
                    validator: (v) => v == null ? "Requis" : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                    value: _selectedSalleId,
                    decoration: const InputDecoration(labelText: "Salle"),
                    items: widget.salles.map((s) => DropdownMenuItem(value: s.id, child: Text("${s.code} (${s.type})"))).toList(),
                    onChanged: (v) => setState(() => _selectedSalleId = v),
                    validator: (v) => v == null ? "Requis" : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(onPressed: _isLoading ? null : _submit, child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Ajouter")),
      ],
    );
  }
}
