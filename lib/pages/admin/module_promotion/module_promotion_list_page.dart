import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_module_promotion_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_promotion_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_semestre_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_enseignant_service.dart';
import 'package:flutter_dashboard_app/dto/module_promotion/module_promotion_dto.dart';
import 'package:flutter_dashboard_app/dto/promotion/promotion_dto.dart';
import 'package:flutter_dashboard_app/dto/semestre/semestre_dto.dart';
import 'package:flutter_dashboard_app/dto/enseignant/enseignant_dto.dart';
import 'package:flutter_dashboard_app/main.dart'; 

class ModulePromotionListPage extends StatefulWidget {
  const ModulePromotionListPage({super.key});

  @override
  State<ModulePromotionListPage> createState() => _ModulePromotionListPageState();
}

class _ModulePromotionListPageState extends State<ModulePromotionListPage> {
  // Services
  final AdminModulePromotionService _modPromoService = AdminModulePromotionService();
  final AdminPromotionService _promoService = AdminPromotionService();
  final AdminSemestreService _semestreService = AdminSemestreService();
  final AdminEnseignantService _enseignantService = AdminEnseignantService();

  // Data for Dropdowns
  List<PromotionDto> _promotions = [];
  List<SemestreDto> _semestres = [];
  List<EnseignantDto> _enseignants = [];

  // Table Data
  List<ModulePromotionDto> _modulePromotions = [];

  // Selections
  int? _selectedPromotionId;
  int? _selectedSemestreId;

  // Estados
  bool _isLoading = false;
  bool _isLoadingData = false; // For generating/fetching modules
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final promos = await _promoService.getAllPromotions(size: 100);
      _promotions = (promos['content'] as List).map((e) => PromotionDto.fromJson(e)).toList();
    
      _semestres = await _semestreService.getAllSemestres();

      final ens = await _enseignantService.getAllEnseignants(size: 100);
      _enseignants = (ens['content'] as List).map((e) => EnseignantDto.fromJson(e)).toList();
    } catch (e) {
      _showSnackBar("Erreur chargement init: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchModulePromotions() async {
    if (_selectedPromotionId == null || _selectedSemestreId == null) return;

    setState(() => _isLoadingData = true);
    try {
      _modulePromotions = await _modPromoService.getModulesByPromotionAndSemester(
        _selectedPromotionId!,
        _selectedSemestreId!,
      );
    } catch (e) {
      _showSnackBar("Erreur chargement modules: ${e.toString()}", isError: true);
      _modulePromotions = [];
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _generateModules() async {
    if (_selectedPromotionId == null) return;

    setState(() => _isLoadingData = true);
    try {
      await _modPromoService.generateModulesForPromotion(_selectedPromotionId!);
      _showSnackBar("Modules générés avec succès");
      if (_selectedSemestreId != null) {
        _fetchModulePromotions();
      }
    } catch (e) {
      _showSnackBar("Erreur génération: ${e.toString()}", isError: true);
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _assignEnseignant(ModulePromotionDto mp) async {
    EnseignantDto? selectedTeacher;
    // Pre-select if exists
    if (mp.enseignantResponsableId != null) {
       try {
         selectedTeacher = _enseignants.firstWhere((e) => e.id == mp.enseignantResponsableId);
       } catch (e) {}
    }

    final result = await showDialog<EnseignantDto>(
      context: context,
      builder: (ctx) {
        EnseignantDto? tempSelected = selectedTeacher;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Assigner Enseignant - ${mp.moduleReferenceNom ?? ''}"),
              content: SizedBox(
                width: 400,
                child: DropdownButtonFormField<EnseignantDto>(
                  value: tempSelected,
                  decoration: const InputDecoration(
                    labelText: "Enseignant Responsable",
                    border: OutlineInputBorder(),
                  ),
                  items: _enseignants.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text("${e.nom} ${e.prenom}"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() => tempSelected = val);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, tempSelected),
                  child: const Text("Assigner"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        await _modPromoService.assignEnseignantToModule(
          mp.id,
          result.id!,
        );
        _showSnackBar("Enseignant assigné");
        _fetchModulePromotions();
      } catch (e) {
        _showSnackBar("Indices: ${e.toString()}", isError: true);
      }
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Affectation Modules & Enseignants"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedPromotionId,
                    decoration: const InputDecoration(
                      labelText: "Promotion",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _promotions.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p.codePromotion),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedPromotionId = val;
                        // Reset module list AND selected semester when promotion changes
                        // This prevents the "There should be exactly one item with [DropdownButton]'s value" error
                        _selectedSemestreId = null;
                        _modulePromotions = []; 
                      });
                      // No need to fetch modules immediately as semester is now null
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedSemestreId,
                    decoration: const InputDecoration(
                      labelText: "Semestre",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _getFilteredSemestres().map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(s.num ?? "S?"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSemestreId = val;
                      });
                      if (_selectedPromotionId != null) _fetchModulePromotions();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: (_selectedPromotionId == null || _isLoadingData) 
                    ? null 
                    : _generateModules,
                icon: const Icon(Icons.autorenew),
                label: const Text("Générer les Modules"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedPromotionId == null || _selectedSemestreId == null) {
      return const Center(child: Text("Veuillez sélectionner une promotion et un semestre."));
    }

    if (_modulePromotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Aucun module trouvé pour cette sélection."),
            const SizedBox(height: 12),
            ElevatedButton(
               onPressed: _generateModules,
               child: const Text("Générer les modules maintenant"),
            )
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileView();
        } else {
          return _buildWebView();
        }
      },
    );
  }

  Widget _buildMobileView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _modulePromotions.length,
      itemBuilder: (context, index) {
        final mp = _modulePromotions[index];
        final isAssigned = mp.enseignantResponsableId != null;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mp.moduleReferenceNom ?? "-",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        mp.code,
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mp.enseignantResponsableNomComplet ?? "Non assigné",
                        style: TextStyle(
                          color: isAssigned ? Colors.black87 : Colors.red,
                          fontWeight: isAssigned ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _assignEnseignant(mp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
          columns: const [
            DataColumn(label: Text("Module", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Enseignant Responsable", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _modulePromotions.map((mp) {
            return DataRow(
              cells: [
                DataCell(Text(mp.moduleReferenceNom ?? "-")),
                DataCell(Text(mp.code)),
                DataCell(
                  Text(
                    mp.enseignantResponsableNomComplet ?? "Non assigné",
                    style: TextStyle(
                      color: mp.enseignantResponsableId == null ? Colors.red : Colors.black,
                      fontStyle: mp.enseignantResponsableId == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.blue),
                    tooltip: "Assigner Enseignant",
                    onPressed: () => _assignEnseignant(mp),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
  List<SemestreDto> _getFilteredSemestres() {
    if (_selectedPromotionId == null) return _semestres;
    
    PromotionDto? promo;
    try {
      promo = _promotions.firstWhere((p) => p.id == _selectedPromotionId);
    } catch (e) {
      return _semestres;
    }

    List<String> validNums = [];
    if (promo.dureeAnnees == 2) {
      // Prep cycle
      if (promo.annee == 1) validNums = ["S1", "S2"];
      else if (promo.annee == 2) validNums = ["S3", "S4"];
    } else if (promo.dureeAnnees == 3) {
      // Engineering cycle
      if (promo.annee == 1) validNums = ["S5", "S6"];
      else if (promo.annee == 2) validNums = ["S7", "S8"];
      else if (promo.annee == 3) validNums = ["S9", "S10"];
    } else if (promo.dureeAnnees == 1) {
       validNums = ["S1", "S2"];
    }

    if (validNums.isEmpty) return _semestres;

    // Filter semesters based on logical number AND academic year
    return _semestres.where((s) => 
        validNums.contains(s.num) && 
        s.anneeUniversitaireId == promo!.anneeUniversitaireId
    ).toList();
  }
}

