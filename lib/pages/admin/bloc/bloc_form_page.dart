import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../apiservice/admin/admin_bloc_service.dart';
import '../../../../dto/bloc/bloc_request.dart';
import '../../../../main.dart';

class BlocFormPage extends StatefulWidget {
  final int? id; // null = Création

  const BlocFormPage({super.key, this.id});

  @override
  State<BlocFormPage> createState() => _BlocFormPageState();
}

class _BlocFormPageState extends State<BlocFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminBlocService _service = AdminBlocService();

  late TextEditingController _nomController;
  late TextEditingController _localisationController;

  bool _isLoading = true; 
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _localisationController = TextEditingController();
    
    _loadData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.id == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final bloc = await _service.getBlocById(widget.id!);
      _nomController.text = bloc.nom;
      _localisationController.text = bloc.localisation;
    } catch (e) {
      _showSnackBar("Erreur chargement: ${e.toString()}", isError: true);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final request = BlocRequest(
      nom: _nomController.text.trim(),
      localisation: _localisationController.text.trim(),
    );

    try {
      if (widget.id != null) {
        await _service.updateBloc(widget.id!, request);
        _showSnackBar("Bloc mis à jour");
      } else {
        await _service.createBloc(request);
        _showSnackBar("Bloc créé");
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
        title: Text(isEditMode ? 'Modifier Bloc' : 'Nouveau Bloc'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nomController,
                              decoration: const InputDecoration(
                                labelText: "Nom du Bloc *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              validator: (v) => (v == null || v.length < 2)
                                  ? "Min 2 caractères"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _localisationController,
                              decoration: const InputDecoration(
                                labelText: "Localisation *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (v) => (v == null || v.length < 3)
                                  ? "Min 3 caractères"
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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
                          label: Text(_isSubmitting
                              ? "Enregistrement..."
                              : (isEditMode ? "Mettre à jour" : "Créer")),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
