import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Pour le formatage de date, assurez-vous que le package intl est ajouté
import '../../../apiservice/admin/admin_departement_service.dart';
import '../../../dto/departement/departement_dto.dart';

class DepartementDetailsPage extends StatefulWidget {
  final int id;

  const DepartementDetailsPage({super.key, required this.id});

  @override
  State<DepartementDetailsPage> createState() => _DepartementDetailsPageState();
}

class _DepartementDetailsPageState extends State<DepartementDetailsPage> {
  final AdminDepartementService _service = AdminDepartementService();
  
  bool _isLoading = true;
  String? _error;
  DepartementDto? _departement;

  @override
  void initState() {
    super.initState();
    _fetchDepartementDetails();
  }

  Future<void> _fetchDepartementDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getDepartementById(widget.id);
      setState(() {
        _departement = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      // Utilisation de intl si disponible, sinon fallback simple
      return DateFormat('dd MMMM yyyy', 'fr').format(date);
    } catch (e) {
      // Fallback si locale 'fr' non initialisée ou intl absent
      return "${date.day}/${date.month}/${date.year}"; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du Département"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Erreur: $_error", style: const TextStyle(color: Colors.red)))
              : _departement == null
                  ? const Center(child: Text("Département non trouvé."))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _departement!.libelle ?? "Sans Libellé",
                                style: Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 16),
                              
                              _buildDetailRow("ID", _departement!.id?.toString() ?? "N/A"),
                              _buildDetailRow("Code", _departement!.code ?? "N/A"),
                              _buildDetailRow("Libellé", _departement!.libelle ?? "N/A"),
                              
                              _buildDetailRow(
                                "Chef de Département", 
                                _departement!.chefNom ?? 
                                (_departement!.chef != null 
                                    ? "${_departement!.chef!.prenom} ${_departement!.chef!.nom}" 
                                    : "Non assigné")
                              ),
                              
                              if ((_departement!.chefNom != null || _departement!.chef != null) && _departement!.dateNominationChef != null)
                                _buildDetailRow(
                                  "Date de Nomination Chef",
                                  _formatDate(_departement!.dateNominationChef),
                                ),

                              const SizedBox(height: 24),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => context.pop(),
                                    child: const Text("Retour à la liste"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Rediriger vers la modification
                                      // Note: GoRouter push peut retourner une valeur si la page est poppée
                                      context.push('/admin/departements/edit/${_departement!.id}');
                                    },
                                    child: const Text("Modifier"),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
