import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../apiservice/admin/admin_salle_service.dart';
import '../../../../apiservice/admin/admin_bloc_service.dart';
import '../../../../dto/salle/salle_request.dart';
import '../../../../dto/bloc/bloc_dto.dart';
import '../../../../main.dart';

class SalleFormPage extends StatefulWidget {
  final int? id;

  const SalleFormPage({super.key, this.id});

  @override
  State<SalleFormPage> createState() => _SalleFormPageState();
}

class _SalleFormPageState extends State<SalleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminSalleService _salleService = AdminSalleService();
  final AdminBlocService _blocService = AdminBlocService(); // Pour le dropdown Bloc

  late TextEditingController _codeController;
  late TextEditingController _capaciteController;
  
  String? _selectedType;
  int? _selectedBlocId;
  List<BlocDto> _blocs = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<String> _typeOptions = [
    'TP',
    'PETITE_AMPHI',
    'GRANDE_AMPHI',
    'COURS_NORMAL'
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _capaciteController = TextEditingController(text: '20');

    _loadData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // 1. Charger les blocs pour le dropdown
      final blocResponse = await _blocService.getAllBlocs(page: 0, size: 100);
      List<BlocDto> loadedBlocs = [];

      if (blocResponse is Map<String, dynamic> && blocResponse.containsKey('content')) {
        loadedBlocs = (blocResponse['content'] as List)
            .map((e) => BlocDto.fromJson(e))
            .toList();
      } else if (blocResponse is List) {
        loadedBlocs = blocResponse.map((e) => BlocDto.fromJson(e)).toList();
      }

      setState(() {
        _blocs = loadedBlocs;
      });

      // 2. Si mode édition, charger la salle
      if (widget.id != null) {
        final salle = await _salleService.getSalleById(widget.id!);
        _codeController.text = salle.code;
        _capaciteController.text = salle.capacite.toString();
        _selectedType = salle.type;
        _selectedBlocId = salle.blocId;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      _showSnackBar("Erreur chargement: ${e.toString()}", isError: true);
      // En cas d'erreur critique, on sort
      if (widget.id != null && mounted) context.pop();
      else setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      _showSnackBar("Veuillez sélectionner un type", isError: true);
      return;
    }
    if (_selectedBlocId == null) {
      _showSnackBar("Veuillez sélectionner un bloc", isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final request = SalleRequest(
      code: _codeController.text.trim(),
      capacite: int.tryParse(_capaciteController.text) ?? 0,
      type: _selectedType!,
      blocId: _selectedBlocId!,
    );

    try {
      if (widget.id != null) {
        await _salleService.updateSalle(widget.id!, request);
        _showSnackBar("Salle mise à jour");
      } else {
        await _salleService.createSalle(request);
        _showSnackBar("Salle créée");
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
        title: Text(isEditMode ? 'Modifier Salle' : 'Nouvelle Salle'),
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
                            // CODE
                            TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                labelText: "Code Salle *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.meeting_room),
                              ),
                              validator: (v) => (v == null || v.length < 2)
                                  ? "Min 2 caractères"
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // CAPACITÉ
                            TextFormField(
                              controller: _capaciteController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Capacité *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.groups),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return "Requis";
                                if (int.tryParse(v) == null) return "Nombre valide requis";
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // TYPE DROPDOWN
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: "Type de Salle *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _typeOptions.map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              )).toList(),
                              onChanged: (val) => setState(() => _selectedType = val),
                            ),
                            const SizedBox(height: 20),

                            // BLOC DROPDOWN
                            DropdownButtonFormField<int>(
                              value: _selectedBlocId,
                              decoration: const InputDecoration(
                                labelText: "Bloc *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              items: _blocs.map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.nom),
                              )).toList(),
                              onChanged: (val) => setState(() => _selectedBlocId = val),
                              hint: const Text("Sélectionner un bloc"),
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
