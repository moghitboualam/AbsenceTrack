import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Ajoutez le package intl dans pubspec.yaml pour formater les dates
import '../../../apiservice/admin/admin_enseignant_service.dart';
import '../../../dto/enseignant/enseignant_request.dart';
import '../../../main.dart'; // Pour rootScaffoldMessengerKey

class EnseignantFormPage extends StatefulWidget {
  final int? id; // null = Création, sinon Modification

  const EnseignantFormPage({super.key, this.id});

  @override
  State<EnseignantFormPage> createState() => _EnseignantFormPageState();
}

class _EnseignantFormPageState extends State<EnseignantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminEnseignantService _enseignantService = AdminEnseignantService();
  // Contrôleurs
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _specialiteController;

  // États
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadDependencies();
  }

  void _initControllers() {
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _specialiteController = TextEditingController();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _specialiteController.dispose();
    super.dispose();
  }

  // --- CHARGEMENT DES DONNÉES ---
  Future<void> _loadDependencies() async {
    try {
      // 2. Si mode édition, charger l'enseignant
      if (widget.id != null) {
        final data = await _enseignantService.getEnseignantById(widget.id!);

        setState(() {
          _nomController.text = data.nom ?? '';
          _prenomController.text = data.prenom ?? '';
          _emailController.text = data.email ?? '';
          _specialiteController.text = data.specialite ?? '';
        });
      }
    } catch (e) {
      _showSnackBar("Erreur chargement: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // --- SOUMISSION ---
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Préparation de la requête
    final request = EnseignantRequest(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.isEmpty
          ? null
          : _passwordController.text,
      specialite: _specialiteController.text.trim(),
    );

    try {
      if (widget.id != null) {
        // UPDATE
        await _enseignantService.updateEnseignant(widget.id!, request);
        _showSnackBar("Enseignant mis à jour avec succès");
      } else {
        // CREATE
        await _enseignantService.createEnseignant(request);
        _showSnackBar("Enseignant créé avec succès");
      }

      if (mounted) context.pop(true); // Retour succès
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

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Modifier Enseignant' : 'Nouvel Enseignant'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- NOM & PRENOM ---
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nomController,
                            decoration: const InputDecoration(
                              labelText: "Nom *",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.length < 2)
                                ? "Min 2 car."
                                : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _prenomController,
                            decoration: const InputDecoration(
                              labelText: "Prénom *",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.length < 2)
                                ? "Min 2 car."
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // --- EMAIL ---
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email *",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? "Email invalide"
                          : null,
                    ),
                    const SizedBox(height: 15),

                    // --- MOT DE PASSE ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: isEditMode
                            ? "Mot de passe (Optionnel)"
                            : "Mot de passe *",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (!isEditMode && (v == null || v.length < 6))
                          return "Min 6 caractères";
                        if (isEditMode && v!.isNotEmpty && v.length < 6)
                          return "Min 6 caractères";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // --- SPÉCIALITÉ ---
                    TextFormField(
                      controller: _specialiteController,
                      decoration: const InputDecoration(
                        labelText: "Spécialité",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
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
                        const SizedBox(width: 15),
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
