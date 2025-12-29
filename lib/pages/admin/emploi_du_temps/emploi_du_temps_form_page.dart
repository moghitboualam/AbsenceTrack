import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_emploi_du_temps_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_classes_service.dart';
import 'package:flutter_dashboard_app/apiservice/admin/admin_semestre_service.dart';
import 'package:flutter_dashboard_app/dto/emploi_du_temps/emploi_du_temps_request.dart';
import 'package:flutter_dashboard_app/dto/classes/classes_dto.dart';
import 'package:flutter_dashboard_app/dto/semestre/semestre_dto.dart';
import 'package:flutter_dashboard_app/main.dart'; // For rootScaffoldMessengerKey

class AdminEmploiDuTempsFormPage extends StatefulWidget {
  final int? id;
  const AdminEmploiDuTempsFormPage({super.key, this.id});

  @override
  State<AdminEmploiDuTempsFormPage> createState() => _AdminEmploiDuTempsFormPageState();
}

class _AdminEmploiDuTempsFormPageState extends State<AdminEmploiDuTempsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _edtService = AdminEmploiDuTempsService();
  final _classesService = AdminClassesService();
  final _semestreService = AdminSemestreService();

  bool _isLoading = false;
  bool _isInit = true;

  // Form Fields
  final _nomController = TextEditingController();
  int? _selectedClasseId;
  int? _selectedSemestreId;

  // Data Sources
  List<ClassesDto> _classes = [];
  List<SemestreDto> _semestres = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadData();
      _isInit = false;
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load Dropdown Data
      final classesData = await _classesService.getAllClasses(page: 0, size: 100); // Assuming pagination, get enough
      final semestresData = await _semestreService.getAllSemestres();

      setState(() {
        _classes = (classesData['content'] as List).map((e) => ClassesDto.fromJson(e)).toList();
        _semestres = semestresData; // Assuming getAllSemestres returns List<SemestreDto> directly
      });

      // 2. If Editing, Load Existing Data
      if (widget.id != null) {
        final edt = await _edtService.getEmploiDuTempsById(widget.id!);
        _nomController.text = edt.libelle ?? '';
        _selectedClasseId = edt.classeId;
        _selectedSemestreId = edt.semestreId;
      }
    } catch (e) {
      _showSnackBar("Erreur de chargement: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClasseId == null) {
      _showSnackBar("Veuillez sélectionner une classe", isError: true);
      return;
    }
    if (_selectedSemestreId == null) {
      _showSnackBar("Veuillez sélectionner un semestre", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final request = EmploiDuTempsRequest(
      nom: _nomController.text,
      classeId: _selectedClasseId,
      semestreId: _selectedSemestreId,
    );

    try {
      if (widget.id == null) {
        await _edtService.createEmploiDuTemps(request);
        _showSnackBar("Emploi du temps créé avec succès");
      } else {
        await _edtService.updateEmploiDuTemps(widget.id!, request);
        _showSnackBar("Emploi du temps mis à jour avec succès");
      }
      if (mounted) context.pop(true);
    } catch (e) {
      _showSnackBar("Erreur d'enregistrement: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
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
        title: Text(widget.id == null ? "Créer Emploi du Temps" : "Modifier Emploi du Temps"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading && _classes.isEmpty // Show loading only on initial load
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Informations Générales",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),

                            // Nom
                            TextFormField(
                              controller: _nomController,
                              decoration: const InputDecoration(
                                labelText: "Nom de l'Emploi du Temps",
                                hintText: "Ex: Emploi du temps S1 - Génie Info",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              validator: (val) => val == null || val.isEmpty ? "Ce champ est requis" : null,
                            ),
                            const SizedBox(height: 16),

                            // Classe Dropdown
                            DropdownButtonFormField<int>(
                              value: _selectedClasseId,
                              decoration: const InputDecoration(
                                labelText: "Classe",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.class_),
                              ),
                              items: _classes.map((classe) {
                                return DropdownMenuItem<int>(
                                  value: classe.id,
                                  child: Text(classe.code ?? "Classe #${classe.id}"),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedClasseId = val),
                              validator: (val) => val == null ? "Requis" : null,
                            ),
                            const SizedBox(height: 16),

                            // Semestre Dropdown
                            DropdownButtonFormField<int>(
                              value: _selectedSemestreId,
                              decoration: const InputDecoration(
                                labelText: "Semestre",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              items: _semestres.map((sem) {
                                return DropdownMenuItem<int>(
                                  value: sem.id,
                                  child: Text(sem.num ?? "Semestre #${sem.id}"),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedSemestreId = val),
                              validator: (val) => val == null ? "Requis" : null,
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(widget.id == null ? "Créer" : "Mettre à jour"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
