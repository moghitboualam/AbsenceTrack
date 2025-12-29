import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:universal_html/html.dart' as html;

import '../../models/teacher_models.dart';
import '../../services/teacher_service.dart';

class JustificationManagementPage extends StatefulWidget {
  const JustificationManagementPage({super.key});

  @override
  State<JustificationManagementPage> createState() =>
      _JustificationManagementPageState();
}

class _JustificationManagementPageState
    extends State<JustificationManagementPage> {
  final TeacherService _teacherService = TeacherService();
  List<AbsenceDto> _pendingJustifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _teacherService.getPendingJustifications();
      if (mounted) {
        setState(() {
          _pendingJustifications = data;
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

  Future<void> _viewDocument(int absenceId) async {
    try {
      final bytes = await _teacherService.downloadJustificationDocument(
        absenceId,
      );

      if (kIsWeb) {
        final blob = html.Blob([
          bytes,
        ], 'application/pdf'); // Assuming PDF or check extension/mime
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, '_blank');
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile only
        // Simply download to temp and show for now or open?
        // Let's assume viewing like PDF Viewer
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/justif_$absenceId.pdf',
        ); // Assuming PDF validation on upload or mime check
        await file.writeAsBytes(bytes);

        if (mounted) {
          // Navigate to a viewer page or show open dialog
          // For simplicity, showing success message or implement local viewer if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Document téléchargé: ${file.path}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur téléchargement: $e")));
      }
    }
  }

  Future<void> _validate(int id) async {
    try {
      await _teacherService.validateJustification(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Justification validée")));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    }
  }

  Future<void> _refuse(int id) async {
    String reason = "";
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Refuser la justification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Veuillez indiquer le motif du refus :"),
              const SizedBox(height: 12),
              ShadInput(
                placeholder: const Text(
                  "Motif (ex: Illisible, Date incorrecte...)",
                ),
                onChanged: (val) => reason = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirmer le Refus"),
            ),
          ],
        );
      },
    );

    if (confirmed == true && reason.isNotEmpty) {
      try {
        await _teacherService.refuseJustification(id, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Justification refusée")),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des Justifications")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Erreur: $_error"))
          : _pendingJustifications.isEmpty
          ? const Center(child: Text("Aucune justification en attente."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingJustifications.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final item = _pendingJustifications[i];
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
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              "${item.etudiantNom} ${item.etudiantPrenom}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text("Séance ID: ${item.seanceId}"),
                        Text("Date Absence: ${item.dateAbsence ?? 'N/A'}"),
                        if (item.justification != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Commentaire: ${item.justification}",
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            ShadButton.outline(
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility, size: 16),
                                  SizedBox(width: 8),
                                  Text("Voir Document"),
                                ],
                              ),
                              onPressed: () => _viewDocument(item.id),
                            ),
                            ShadButton(
                              backgroundColor: Colors.green,
                              child: const Text("Valider"),
                              onPressed: () => _validate(item.id),
                            ),
                            ShadButton.destructive(
                              child: const Text("Refuser"),
                              onPressed: () => _refuse(item.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
