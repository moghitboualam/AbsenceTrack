import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dashboard_app/dto/departement/departement_dto.dart';
import 'package:flutter_dashboard_app/dto/enseignant/enseignant_dto.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_filiere_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_departement_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_enseignant_service.dart';
import 'package:flutter_dashboard_app/dto/filiere/filiere_request.dart';
import 'package:flutter_dashboard_app/main.dart'; 

class FiliereFormPage extends StatefulWidget {
  final int? id; // null = Création, sinon = Modification

  const FiliereFormPage({super.key, this.id});

  @override
  State<FiliereFormPage> createState() => _FiliereFormPageState();
}

class _FiliereFormPageState extends State<FiliereFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminFiliereService _filiereService = AdminFiliereService();
  final AdminDepartementService _departementService = AdminDepartementService();
  final AdminEnseignantService _enseignantService = AdminEnseignantService();

  // Contrôleurs
  late TextEditingController _codeController;
  late TextEditingController _libelleController;


  // États
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Dropdown Data
  List<DepartementDto> _departements = [];
  List<EnseignantDto> _enseignants = [];

  // Selections
  int? _selectedDepartementId;
  int? _selectedChefId;
  int? _selectedDuree; // 1 or 2
  List<String> _selectedSemestres = [];

  final List<String> _semestresPreparatoire = ['S1', 'S2', 'S3', 'S4'];
  final List<String> _semestresIngenieur = ['S5', 'S6', 'S7', 'S8', 'S9', 'S10'];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _libelleController = TextEditingController();


    _loadData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _libelleController.dispose();

    super.dispose();
  }

  // --- CHARGEMENT DES DONNÉES ---
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Charger les referentiels (Departements, Enseignants)
      // On charge tout (page size grand ou pagination loop si besoin, ici simple fetch page 0 size 100)
      final deptResponse = await _departementService.getAllDepartements(size: 100);
      final ensResponse = await _enseignantService.getAllEnseignants(size: 100);

      _departements = (deptResponse['content'] as List)
          .map((e) => DepartementDto.fromJson(e))
          .toList();
      _enseignants = (ensResponse['content'] as List)
          .map((e) => EnseignantDto.fromJson(e))
          .toList();

      // 2. Si Edit Mode, charger la filiere
      if (widget.id != null) {
        final data = await _filiereService.getFiliereById(widget.id!);
        _codeController.text = data.code ?? '';
        _libelleController.text = data.libelle ?? '';
        // _dureeController.text = data.dureeAnnees?.toString() ?? '0'; // Removed
        // _semistereController.text = data.semistere ?? ''; // Removed
        _selectedDepartementId = data.departement?.id;
        _selectedChefId = data.chefFiliere?.id;
        _selectedDuree = data.dureeAnnees;
        if (data.semistere != null && data.semistere!.isNotEmpty) {
           _selectedSemestres = data.semistere!.split(',');
        } else {
           _selectedSemestres = [];
        }
        print("JSON DATA: ${data.toJson()}");
        print("selectedDepartementId: $_selectedDepartementId");
        print("selectedChefId: $_selectedChefId");
        print("selectedDuree: $_selectedDuree");
        print("selectedSemestres: $_selectedSemestres");
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

    setState(() => _isSubmitting = true);

    final request = FiliereRequest(
      code: _codeController.text.trim(),
      libelle: _libelleController.text.trim(),
      dureeAnnees: _selectedDuree,
      semistere: _selectedSemestres.join(','),
      departementId: _selectedDepartementId,
      chefFiliereId: _selectedChefId,
    );

    try {
      if (widget.id != null) {
        print("JSON DATA: ${request.toJson()}");
        await _filiereService.updateFiliere(widget.id!, request);
        _showSnackBar("Filière mise à jour");
      } else {
        await _filiereService.createFiliere(request);
        _showSnackBar("Filière créée");
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

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Modifier Filière' : 'Nouvelle Filière',
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
                            
                            // Code & Libelle
                            TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                labelText: "Code *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.code),
                              ),
                              validator: (val) => (val == null || val.length < 2) ? "Min 2 caractères" : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _libelleController,
                              decoration: const InputDecoration(
                                labelText: "Libellé *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.label),
                              ),
                              validator: (val) => (val == null || val.length < 2) ? "Min 2 caractères" : null,
                            ),
                            const SizedBox(height: 16),

                            // Duree Dropdown
                            DropdownButtonFormField<int>(
                              value: _selectedDuree,
                              decoration: const InputDecoration(
                                labelText: "Durée (années) *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.timer),
                              ),
                              items: const [
                                DropdownMenuItem(value: 2, child: Text("2 ans (Cycle Préparatoire)")),
                                DropdownMenuItem(value: 3, child: Text("3 ans (Cycle Ingénieur)")),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedDuree = val;
                                  _selectedSemestres.clear(); // Clear semesters on duration change
                                });
                              },
                              validator: (val) => val == null ? "Requis" : null,
                            ),
                            const SizedBox(height: 16),

                            // Semesters Checkboxes
                            if (_selectedDuree != null) ...[
                              const Text("Sélectionnez les semestres *", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: (_selectedDuree == 2 ? _semestresPreparatoire : _semestresIngenieur).map((semestre) {
                                  final isSelected = _selectedSemestres.contains(semestre);
                                  return FilterChip(
                                    label: Text(semestre),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedSemestres.add(semestre);
                                        } else {
                                          _selectedSemestres.remove(semestre);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              if (_selectedSemestres.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text("Au moins un semestre requis", style: TextStyle(color: Colors.red, fontSize: 12)),
                                ),
                            ],
                            const SizedBox(height: 16),

                            // Departement Dropdown
                            DropdownButtonFormField<int>(
                              value: _selectedDepartementId,
                              decoration: const InputDecoration(
                                labelText: "Département",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              items: _departements.map((d) {
                                return DropdownMenuItem<int>(
                                  value: d.id,
                                  child: Text(d.libelle ?? d.code ?? "Unknown"),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedDepartementId = val),
                            ),
                            const SizedBox(height: 16),

                            // Chef Filiere Dropdown
                            DropdownButtonFormField<int>(
                              value: _selectedChefId,
                              decoration: const InputDecoration(
                                labelText: "Chef de Filière",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: _enseignants.map((e) {
                                return DropdownMenuItem<int>(
                                  value: e.id,
                                  child: Text("${e.nom} ${e.prenom}"),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedChefId = val),
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
