import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dashboard_app/dto/filiere/filiere_dto.dart';
import 'package:flutter_dashboard_app/dto/anneeuniversitaire/annee_universitaire_dto.dart';
import 'package:flutter_dashboard_app/dto/promotion/promotion_request.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_promotion_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_filiere_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_annee_universitaire_service.dart';
import 'package:flutter_dashboard_app/main.dart'; 

class PromotionFormPage extends StatefulWidget {
  final int? id; // null = Création, sinon = Modification

  const PromotionFormPage({super.key, this.id});

  @override
  State<PromotionFormPage> createState() => _PromotionFormPageState();
}

class _PromotionFormPageState extends State<PromotionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminPromotionService _promotionService = AdminPromotionService();
  final AdminFiliereService _filiereService = AdminFiliereService();
  final AdminAnneeUniversitaireService _anneeUnivService = AdminAnneeUniversitaireService();

  // Contrôleurs
  late TextEditingController _codeController;

  // États
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Dropdown Data
  List<FiliereDto> _filieres = [];
  List<AnneeUniversitaireDto> _anneesUniv = [];

  // Selections
  int? _selectedFiliereId;
  int? _selectedAnneeUnivId;
  int? _selectedAnnee; // 1, 2, 3...

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // --- CHARGEMENT DES DONNÉES ---
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Charger les referentiels
      final filiereResponse = await _filiereService.getAllFilieres(size: 100);
      final listAnnees = await _anneeUnivService.getAllAnnees();

      _filieres = (filiereResponse['content'] as List)
          .map((e) => FiliereDto.fromJson(e))
          .toList();
      _anneesUniv = listAnnees;

      // 2. Si Edit Mode, charger la promotion
      if (widget.id != null) {
        final data = await _promotionService.getPromotionById(widget.id!);
        _codeController.text = data.codePromotion;
        _selectedFiliereId = data.filiereId;
        _selectedAnneeUnivId = data.anneeUniversitaireId;
        _selectedAnnee = data.annee;
      }
    } catch (e) {
      _showSnackBar("Erreur chargement: ${e.toString()}", isError: true);
      if (mounted && widget.id != null) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- SOUMISSION DU FORMULAIRE ---
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFiliereId == null || _selectedAnneeUnivId == null || _selectedAnnee == null) {
      _showSnackBar("Veuillez sélectionner tous les champs requis", isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final request = PromotionRequest(
      codePromotion: _codeController.text.trim(),
      filiereId: _selectedFiliereId!,
      anneeUniversitaireId: _selectedAnneeUnivId!,
      annee: _selectedAnnee!,
    );

    try {
      if (widget.id != null) {
        await _promotionService.updatePromotion(widget.id!, request);
        _showSnackBar("Promotion mise à jour");
      } else {
        await _promotionService.createPromotion(request);
        _showSnackBar("Promotion créée");
      }

      if (mounted) context.pop(true);
    } catch (e) {
      _showSnackBar("Erreur: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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

  List<DropdownMenuItem<int>> _buildAnneeItems() {
    int duration = 3; // Default
    if (_selectedFiliereId != null) {
      try {
        final f = _filieres.firstWhere((element) => element.id == _selectedFiliereId, orElse: () => _filieres.first);
        duration = f.dureeAnnees ?? 3;
      } catch (e) {
        // Silent catch is acceptable here as it's just trying to set a default duration from a list
      }
    }

    if (duration == 2) {
      // Cycle Préparatoire (CP1, CP2) -> Backend 1, 2
      return const [
        DropdownMenuItem(value: 1, child: Text("1ère Année (CP1)")),
        DropdownMenuItem(value: 2, child: Text("2ème Année (CP2)")),
      ];
    } else if (duration == 3) {
      // Cycle Ingénieur (CI1, CI2, CI3) -> Backend 1, 2, 3
      // UI: 3ème Année, 4ème Année, 5ème Année
      return const [
         DropdownMenuItem(value: 1, child: Text("3ème Année")),
         DropdownMenuItem(value: 2, child: Text("4ème Année")),
         DropdownMenuItem(value: 3, child: Text("5ème Année")),
      ];
    }
    
    // Default fallback
    return const [
      DropdownMenuItem(value: 1, child: Text("1ère Année")),
      DropdownMenuItem(value: 2, child: Text("2ème Année")),
      DropdownMenuItem(value: 3, child: Text("3ème Année")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Modifier Promotion' : 'Nouvelle Promotion',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text("Informations Générales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            
                            // Code Promotion
                            TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                labelText: "Code Promotion *",
                                hintText: "Ex: L1 Info 2023",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.code),
                              ),
                              validator: (val) => (val == null || val.length < 2) ? "Min 2 caractères" : null,
                            ),
                            const SizedBox(height: 16),

                            // Filiere Dropdown
                            DropdownButtonFormField<int>(
                              value: _selectedFiliereId,
                              decoration: const InputDecoration(
                                labelText: "Filière *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.school),
                              ),
                              items: _filieres.map((f) {
                                return DropdownMenuItem<int>(
                                  value: f.id,
                                  child: Text(f.libelle ?? f.code ?? "Unknown"),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedFiliereId = val),
                              validator: (val) => val == null ? "Requis" : null,
                            ),
                            const SizedBox(height: 16),

                             // Annee Universitaire Dropdown
                            DropdownButtonFormField<int>(
                              value: _selectedAnneeUnivId,
                              decoration: const InputDecoration(
                                labelText: "Année Universitaire *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              items: _anneesUniv.map((a) {
                                return DropdownMenuItem<int>(
                                  value: a.id,
                                  child: Text(a.annee),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedAnneeUnivId = val),
                              validator: (val) => val == null ? "Requis" : null,
                            ),
                            const SizedBox(height: 16),

                             // Annee Cursus Dropdown (1, 2, 3...)
                             DropdownButtonFormField<int>(
                              value: _selectedAnnee,
                              decoration: const InputDecoration(
                                labelText: "Année du Cursus *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text("1ère Année")),
                                DropdownMenuItem(value: 2, child: Text("2ème Année")),
                                DropdownMenuItem(value: 3, child: Text("3ème Année")),
                              ],
                              onChanged: (val) => setState(() => _selectedAnnee = val),
                              validator: (val) => val == null ? "Requis" : null,
                            ),

                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text("Annuler"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save),
                          label: Text(
                            _isSubmitting
                                ? "Enregistrement..."
                                : (isEditMode ? "Mettre à jour" : "Ajouter"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
