import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../apiservice/admin/admin_etudiant_service.dart';
import '../../../dto/etudiant/etudiant_request.dart';
import '../../../main.dart'; // Pour accéder à rootScaffoldMessengerKey

class EtudiantFormPage extends StatefulWidget {
  final int? id; // Si null = Création, sinon = Modification

  const EtudiantFormPage({super.key, this.id});

  @override
  State<EtudiantFormPage> createState() => _EtudiantFormPageState();
}

class _EtudiantFormPageState extends State<EtudiantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminEtudiantService _service = AdminEtudiantService();

  // Contrôleurs pour les champs de texte
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _numCarteController;
  late TextEditingController _codeMassarController;

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isPasswordVisible = false; // Pour l'oeil du mot de passe

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _numCarteController = TextEditingController();
    _codeMassarController = TextEditingController();

    // Si on a un ID, on charge les données (Mode Édition)
    if (widget.id != null) {
      _loadEtudiantData();
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _numCarteController.dispose();
    _codeMassarController.dispose();
    super.dispose();
  }

  // --- CHARGEMENT DES DONNÉES (EDIT MODE) ---
  Future<void> _loadEtudiantData() async {
    setState(() => _isLoading = true);
    try {
      // Adaptez cette méthode selon ce que retourne votre API (Map ou DTO)
      final data = await _service.getEtudiantById(widget.id!);
      print(data);
      setState(() {
        _nomController.text = data.nom ?? '';
        _prenomController.text = data.prenom ?? '';
        _emailController.text = data.email ?? '';
        _numCarteController.text = data.numCarte ?? '';
        _codeMassarController.text = data.codeMassar ?? '';
        // On ne remplit jamais le mot de passe
      });
    } catch (e) {
      _showSnackBar(
        "Erreur lors du chargement: ${e.toString()}",
        isError: true,
      );
      if (mounted) context.pop(); // On quitte si on ne peut pas charger
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- SOUMISSION DU FORMULAIRE ---
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return; // Si validation échoue, on arrête
    }

    setState(() => _isSubmitting = true);

    final request = EtudiantRequest(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      numCarte: _numCarteController.text.trim(),
      codeMassar: _codeMassarController.text.trim(),
      password: _passwordController.text.isEmpty
          ? null
          : _passwordController.text,
      // classeId: ... (Ajoutez la logique si vous activez le selecteur de classe)
    );

    try {
      if (widget.id != null) {
        // Mode UPDATE
        await _service.updateEtudiant(widget.id!, request);
        _showSnackBar("Étudiant mis à jour avec succès");
      } else {
        // Mode CREATE
        await _service.createEtudiant(request);
        _showSnackBar("Étudiant créé avec succès");
      }

      if (mounted) {
        context.pop(
          true,
        ); // Retourne true pour dire à la liste de se rafraîchir
      }
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
        title: Text(isEditMode ? 'Modifier Étudiant' : 'Nouvel Étudiant'),
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
                    // --- NOM & PRENOM ---
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nomController,
                            decoration: const InputDecoration(
                              labelText: "Nom *",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (val) => (val == null || val.length < 2)
                                ? "Min 2 caractères"
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _prenomController,
                            decoration: const InputDecoration(
                              labelText: "Prénom *",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (val) => (val == null || val.length < 2)
                                ? "Min 2 caractères"
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- EMAIL ---
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email *",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Email requis";
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(val)) return "Email invalide";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- MOT DE PASSE ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: isEditMode
                            ? "Mot de passe (Laisser vide pour garder l'actuel)"
                            : "Mot de passe *",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            );
                          },
                        ),
                      ),
                      validator: (val) {
                        // En création, obligatoire. En édition, optionnel.
                        if (!isEditMode && (val == null || val.length < 6)) {
                          return "Min 6 caractères requis";
                        }
                        if (isEditMode && val!.isNotEmpty && val.length < 6) {
                          return "Min 6 caractères si modifié";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- NUM CARTE & CODE MASSAR ---
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _numCarteController,
                            decoration: const InputDecoration(
                              labelText: "N° Carte *",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.badge),
                            ),
                            validator: (val) =>
                                (val == null || val.isEmpty) ? "Requis" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _codeMassarController,
                            decoration: const InputDecoration(
                              labelText: "Code Massar *",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.qr_code),
                            ),
                            validator: (val) =>
                                (val == null || val.isEmpty) ? "Requis" : null,
                          ),
                        ),
                      ],
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
