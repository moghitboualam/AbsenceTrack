import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dashboard_app/dto/filiere/filiere_dto.dart';
import 'package:flutter_dashboard_app/dto/module/module_request.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_module_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_filiere_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_semestre_service.dart';
import 'package:flutter_dashboard_app/dto/semestre/semestre_dto.dart';
import 'package:flutter_dashboard_app/main.dart'; // For rootScaffoldMessengerKey

class ModuleFormPage extends StatefulWidget {
  final int? id; // null = Creation, else = Modification

  const ModuleFormPage({super.key, this.id});

  @override
  State<ModuleFormPage> createState() => _ModuleFormPageState();
}

class _ModuleFormPageState extends State<ModuleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminModuleService _moduleService = AdminModuleService();
  final AdminFiliereService _filiereService = AdminFiliereService();
  final AdminSemestreService _semestreService = AdminSemestreService();

  // Controllers
  late TextEditingController _libelleController;
  late TextEditingController _volumeHoraireController;

  // State
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Dropdown Data
  List<FiliereDto> _filieres = [];
  List<String> _availableSemestres = []; // Strings from Filiere
  List<SemestreDto> _allSemestres = []; // Objects from API

  // Selections
  int? _selectedFiliereId;
  String? _selectedSemestre;

  @override
  void initState() {
    super.initState();
    _libelleController = TextEditingController();
    _volumeHoraireController = TextEditingController(text: "30");
    _loadData();
  }

  @override
  void dispose() {
    _libelleController.dispose();
    _volumeHoraireController.dispose();
    super.dispose();
  }

  // --- DATA LOADING ---

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Filieres
      final filiereResponse = await _filiereService.getAllFilieres(size: 100);
      _filieres = (filiereResponse['content'] as List)
          .map((e) => FiliereDto.fromJson(e))
          .toList();

      // 2. Fetch All Semestres
      _allSemestres = await _semestreService.getAllSemestres();

      // 2. If Edit Mode, Fetch Module
      if (widget.id != null) {
        final data = await _moduleService.getModuleById(widget.id!);
        _libelleController.text = data.libelle ?? '';
        _volumeHoraireController.text = data.volumeHoraire?.toString() ?? '30';
        
        // Triggers semester population implicitly via logic if we set ID first, 
        // but easier to set ID then call populate manually or rely on logic.
        if (data.filiereLibelle != null) {
          final matchedFiliere = _filieres.firstWhere(
            (f) => f.libelle == data.filiereLibelle,
            orElse: () => FiliereDto(id: -1),
          );
          if (matchedFiliere.id != -1) {
            _selectedFiliereId = matchedFiliere.id;
            _updateAvailableSemesters(_selectedFiliereId);
          }
        }
        
        // Set semester AFTER population
        if (_availableSemestres.contains(data.semestreReference)) {
          _selectedSemestre = data.semestreReference;
        }
      }
    } catch (e) {
      _showSnackBar("Erreur chargement: ${e.toString()}", isError: true);
      if (mounted && widget.id != null) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateAvailableSemesters(int? filiereId) {
    if (filiereId == null) {
      _availableSemestres = [];
      _selectedSemestre = null;
      return;
    }

    final filiere = _filieres.firstWhere(
      (f) => f.id == filiereId, 
      orElse: () => FiliereDto(id: -1),
    );

    if (filiere.id != -1 && filiere.semistere != null && filiere.semistere!.isNotEmpty) {
      setState(() {
        _availableSemestres = filiere.semistere!.split(',');
        // Reset selection if not in new list
        if (_selectedSemestre != null && !_availableSemestres.contains(_selectedSemestre)) {
          _selectedSemestre = null;
        }
      });
    } else {
      setState(() {
        _availableSemestres = [];
        _selectedSemestre = null;
      });
    }
  }

  // --- SUBMISSION ---

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFiliereId == null) {
      _showSnackBar("Veuillez sélectionner une filière", isError: true);
      return;
    }
    if (_selectedSemestre == null) {
      _showSnackBar("Veuillez sélectionner un semestre", isError: true);
      return;
    }

    // Resolve Semestre ID
    // Find all semesters matching the selected name (e.g. "S1")
    final matchingSemestres = _allSemestres.where((s) => s.num == _selectedSemestre).toList();
    
    if (matchingSemestres.isEmpty) {
      _showSnackBar("Aucun semestre correspondant trouvé en base de données", isError: true);
      setState(() => _isSubmitting = false);
      return;
    }

    // Sort by ID descending to get the most recent one (heuristic)
    matchingSemestres.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    final selectedSemestreId = matchingSemestres.first.id!;

    setState(() => _isSubmitting = true);

    try {
      final request = ModuleRequest(
        libelle: _libelleController.text.trim(),
        volumeHoraire: int.tryParse(_volumeHoraireController.text) ?? 30,
        semestreReferenceId: selectedSemestreId,
        filiereId: _selectedFiliereId!,
      );

      if (widget.id != null) {
        await _moduleService.updateModule(widget.id!, request);
        _showSnackBar("Module mis à jour");
      } else {
        await _moduleService.createModule(request);
        _showSnackBar("Module créé");
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

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Modifier Module' : 'Nouveau Module'),
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
                            const Text(
                              "Informations Générales",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Libellé
                            TextFormField(
                              controller: _libelleController,
                              decoration: const InputDecoration(
                                labelText: "Libellé *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.label),
                              ),
                              validator: (val) =>
                                  (val == null || val.length < 2) ? "Min 2 caractères" : null,
                            ),
                            const SizedBox(height: 16),

                            // Volume Horaire
                            TextFormField(
                              controller: _volumeHoraireController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Volume Horaire (heures) *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.timer),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return "Requis";
                                if (int.tryParse(val) == null) return "Nombre valide requis";
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),



                            // Filière Dropdown
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
                              onChanged: (val) {
                                setState(() {
                                  _selectedFiliereId = val;
                                  _updateAvailableSemesters(val);
                                });
                              },
                              validator: (val) => val == null ? "Requis" : null,
                            ),
                            const SizedBox(height: 16),

                            // Semestre Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedSemestre,
                              decoration: InputDecoration(
                                labelText: "Semestre de Référence *",
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_view_day),
                                errorText: (_selectedFiliereId != null && _availableSemestres.isEmpty) 
                                    ? "Aucun semestre pour cette filière" 
                                    : null,
                              ),
                              items: _availableSemestres.map((sem) {
                                return DropdownMenuItem<String>(
                                  value: sem,
                                  child: Text(sem),
                                );
                              }).toList(),
                              onChanged: _availableSemestres.isEmpty 
                                  ? null 
                                  : (val) => setState(() => _selectedSemestre = val),
                              validator: (val) => val == null ? "Requis" : null,
                              // Disable if no semesters available or filiere not selected
                              disabledHint: Text(_selectedFiliereId == null 
                                  ? "Sélectionnez d'abord une filière" 
                                  : "Aucun semestre disponible"),
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
