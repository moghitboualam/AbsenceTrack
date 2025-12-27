import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../apiservice/admin/admin_departement_service.dart';
import '../../../apiservice/admin/admin_enseignant_service.dart'; // Import Service Enseignant
import '../../../dto/departement/departement_request.dart';
import '../../../dto/departement/assigne_chef_request.dart';
import '../../../dto/enseignant/enseignant_dto.dart';
import '../../../main.dart'; // Pour rootScaffoldMessengerKey

class DepartementFormPage extends StatefulWidget {
  final int? id; // null = Création, sinon = Modification

  const DepartementFormPage({super.key, this.id});

  @override
  State<DepartementFormPage> createState() => _DepartementFormPageState();
}

class _DepartementFormPageState extends State<DepartementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminDepartementService _service = AdminDepartementService();
  final AdminEnseignantService _enseignantService = AdminEnseignantService();

  // Contrôleurs
  late TextEditingController _codeController;
  late TextEditingController _libelleController;
  late TextEditingController _dateNominationController;

  // États
  bool _isLoading = true; 
  bool _isSubmitting = false;
  
  // Gestion Chef
  List<EnseignantDto> _enseignants = [];
  int? _selectedChefId;
  int? _initialChefId; // Pour détecter la désélection
  DateTime? _selectedDateNomination;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _libelleController = TextEditingController();
    _dateNominationController = TextEditingController();

    _loadData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _libelleController.dispose();
    _dateNominationController.dispose();
    super.dispose();
  }

  // --- CHARGEMENT DES DONNÉES ---
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Charger la liste des enseignants pour le dropdown
      // On suppose une méthode getAllEnseignants qui retourne une page ou une liste.
      // Adaptation selon votre service réel. Ici on suppose un retour paginé standard.
      try {
        final ensResponse = await _enseignantService.getAllEnseignants(page: 0, size: 100);
        if (ensResponse is Map && ensResponse.containsKey('content')) {
           final content = ensResponse['content'] as List;
           _enseignants = content.map((e) => EnseignantDto.fromJson(e)).toList();
        }
      } catch (e) {
        print("Erreur chargement enseignants: $e");
        // On ne bloque pas tout si les enseignants ne chargent pas, mais on logue
      }

      // 2. Si Edit Mode, charger le département
      if (widget.id != null) {
        final data = await _service.getDepartementById(widget.id!);
        _codeController.text = data.code ?? '';
        _libelleController.text = data.libelle ?? '';
        
        if (data.chefId != null) {
          _selectedChefId = data.chefId;
          _initialChefId = data.chefId; // Sauvegarde de l'initial
        } else if (data.chef != null) {
          _selectedChefId = data.chef!.id;
          _initialChefId = data.chef!.id; // Sauvegarde de l'initial
        }

        if (data.dateNominationChef != null) {
          _selectedDateNomination = data.dateNominationChef;
          _dateNominationController.text = DateFormat('yyyy-MM-dd').format(data.dateNominationChef!);
        }
      }

    } catch (e) {
      _showSnackBar("Erreur chargement: ${e.toString()}", isError: true);
      if (mounted && widget.id != null) context.pop(); // Si erreur critique en edit, on sort
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI HELPERS ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateNomination ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateNomination) {
      setState(() {
        _selectedDateNomination = picked;
        _dateNominationController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- SOUMISSION DU FORMULAIRE ---
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation Custom: Si Chef sélectionné, Date obligatoire (Logique React Zod)
    if (_selectedChefId != null && _selectedDateNomination == null) {
      _showSnackBar("La date de nomination est obligatoire pour un chef.", isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final request = DepartementRequest(
      code: _codeController.text.trim(),
      libelle: _libelleController.text.trim(),
    );

    try {
      int departementId;
      
      if (widget.id != null) {
        // UPDATE
        await _service.updateDepartement(widget.id!, request);
        departementId = widget.id!;
        _showSnackBar("Département mis à jour");
      } else {
        // CREATE
        final created = await _service.createDepartement(request);
        departementId = created.id!; // On suppose que l'ID est retourné
        _showSnackBar("Département créé");
      }

      // ASSIGNATION CHEF (Si sélectionné)
      if (_selectedChefId != null && _selectedDateNomination != null) {
        final assignRequest = AssignChefRequest(
          departementId: departementId,
          estChefDepartement: true,
          enseignantId: _selectedChefId!,
          dateNominationChef: _selectedDateNomination!,
        );
        await _service.assignChefToDepartement(departementId, assignRequest);
        _showSnackBar("Chef de département assigné");
      } 
      // DÉSASSIGNATION (Si désélectionné et qu'il y en avait un avant)
      else if (_selectedChefId == null && _initialChefId != null) {
         // On "désassigne" l'ancien chef
         // On envoie estChefDepartement = false
         final assignRequest = AssignChefRequest(
          departementId: departementId,
          estChefDepartement: false,
          enseignantId: _initialChefId!,
          dateNominationChef: DateTime.now(), // Date requise mais ignorée par logique métier "false"
        );
        await _service.assignChefToDepartement(departementId, assignRequest);
         _showSnackBar("Ancien chef désassigné");
      }

      await Future.delayed(const Duration(milliseconds: 500));
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
          isEditMode ? 'Modifier Département' : 'Nouveau Département',
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
                            // --- CODE & LIBELLE ---
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _codeController,
                                    decoration: const InputDecoration(
                                      labelText: "Code *",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.code),
                                    ),
                                    validator: (val) => (val == null || val.length < 2)
                                        ? "Min 2 caractères"
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _libelleController,
                                    decoration: const InputDecoration(
                                      labelText: "Libellé *",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.label),
                                    ),
                                    validator: (val) => (val == null || val.length < 2)
                                        ? "Min 2 caractères"
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // --- SECTION CHEF ---
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text("Chef de Département", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            
                            // Dropdown Chef
                            DropdownButtonFormField<int>(
                              value: _selectedChefId,
                              decoration: const InputDecoration(
                                labelText: "Sélectionner un Chef",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text("Aucun chef"),
                                ),
                                ..._enseignants.map((e) => DropdownMenuItem<int>(
                                  value: e.id,
                                  child: Text("${e.prenom} ${e.nom}"),
                                )).toList(),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedChefId = val;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Date Nomination
                            TextFormField(
                              controller: _dateNominationController,
                              readOnly: true, // Empêcher l'édition manuelle
                              onTap: () => _selectDate(context),
                              decoration: const InputDecoration(
                                labelText: "Date de Nomination",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                                hintText: "Sélectionner une date",
                              ),
                              validator: (val) {
                                // Validation conditionnelle gérée dans _handleSubmit, 
                                // ou ici si on veut un feedback immédiat
                                if (_selectedChefId != null && (val == null || val.isEmpty)) {
                                  return "Date requise si un chef est sélectionné";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- BOUTONS ---
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
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
