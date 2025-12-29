import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../services/student_service.dart';
import '../../models/student_models.dart';

class MesAbsencesPage extends StatefulWidget {
  const MesAbsencesPage({super.key});

  @override
  State<MesAbsencesPage> createState() => _MesAbsencesPageState();
}

class _MesAbsencesPageState extends State<MesAbsencesPage> {
  final StudentService _studentService = StudentService();
  List<EtudiantAbsence> _absences = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  Future<void> _loadAbsences() async {
    try {
      final data = await _studentService.getMesAbsences();
      if (mounted) {
        setState(() {
          _absences = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showJustificationDialog(EtudiantAbsence absence) async {
    FilePickerResult? result;
    String? comment;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Justifier l'absence"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Veuillez joindre un justificatif (PDF, Image)"),
                  const SizedBox(height: 12),
                  ShadButton.outline(
                    child: Text(
                      result != null
                          ? "Fichier: ${result!.files.single.name}"
                          : "Choisir un fichier",
                    ),
                    onPressed: () async {
                      final picked = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                      );
                      if (picked != null) {
                        setDialogState(() {
                          result = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ShadInput(
                    placeholder: const Text("Commentaire (optionnel)"),
                    onChanged: (val) => comment = val,
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ShadButton(
                  onPressed: (result == null || isSubmitting)
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          try {
                            final file = result!.files.single;
                            // Check platform
                            File? ioFile;
                            List<int>? bytes;
                            if (kIsWeb) {
                              bytes = file.bytes;
                            } else {
                              ioFile = File(file.path!);
                            }

                            await _studentService.justifierAbsence(
                              absence.id,
                              ioFile,
                              bytes,
                              file.name,
                              comment,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Justification envoyée !"),
                                ),
                              );
                              _loadAbsences();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erreur: $e")),
                              );
                              setDialogState(() => isSubmitting = false);
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Envoyer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Absences')),
        body: Center(child: Text("Erreur : $_error")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Absences')),
      body: _absences.isEmpty
          ? const Center(child: Text("Aucune absence enregistrée."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _absences.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final absence = _absences[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                absence.moduleNom ?? "Module inconnu",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            _buildStatusBadge(context, absence),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(absence.date ?? "N/A"),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text("${absence.heureDebut} - ${absence.heureFin}"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Type: ${absence.typeSeance ?? 'N/A'}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (absence.justification != null &&
                            absence.justification!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Justification: ${absence.justification}",
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (absence.statut == 'ABSENT' &&
                            (absence.etatJustification == 'NON_SOUMIS' ||
                                absence.etatJustification == null ||
                                absence.etatJustification == 'REFUSE'))
                          ShadButton.outline(
                            child: const Text("Justifier"),
                            onPressed: () => _showJustificationDialog(absence),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, EtudiantAbsence absence) {
    Color color;
    String text;

    // Priority to Etat Justification if present
    if (absence.etatJustification == 'EN_ATTENTE') {
      return _badge(Colors.blue, 'En attente');
    } else if (absence.etatJustification == 'VALIDE') {
      return _badge(Colors.green, 'Justifiée');
    } else if (absence.etatJustification == 'REFUSE') {
      return _badge(Colors.red[800]!, 'Refusée');
    }

    // Fallback to statuts
    switch (absence.statut?.toUpperCase()) {
      case 'PRESENT':
        color = Colors.green;
        text = 'Présent';
        break;
      case 'ABSENT':
        color = Colors.red;
        text = 'Absent';
        break;
      case 'JUSTIFIE':
        color = Colors.orange;
        text = 'Justifié';
        break;
      default:
        color = Colors.grey;
        text = absence.statut ?? 'Inconnu';
    }

    return _badge(color, text);
  }

  Widget _badge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
