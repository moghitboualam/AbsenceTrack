import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../apiservice/admin/admin_departement_service.dart';
import '../../../dto/departement/departement_request.dart';
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
  // Contrôleurs
  late TextEditingController _codeController;
  late TextEditingController _libelleController;

  // États
  bool _isLoading = true; 
  bool _isSubmitting = false;

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
      // Si Edit Mode, charger le département
      if (widget.id != null) {
        final data = await _service.getDepartementById(widget.id!);
        _codeController.text = data.code ?? '';
        _libelleController.text = data.libelle ?? '';
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

    final request = DepartementRequest(
      code: _codeController.text.trim(),
      libelle: _libelleController.text.trim(),
    );

    try {
      if (widget.id != null) {
        // UPDATE
        await _service.updateDepartement(widget.id!, request);
        _showSnackBar("Département mis à jour");
      } else {
        // CREATE
        await _service.createDepartement(request);
        _showSnackBar("Département créé");
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
