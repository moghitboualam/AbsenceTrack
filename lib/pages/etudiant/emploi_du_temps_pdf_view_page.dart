import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:universal_html/html.dart' as html;
import '../../services/student_service.dart';

class EmploiDuTempsPdfViewPage extends StatefulWidget {
  final String? id;

  const EmploiDuTempsPdfViewPage({super.key, this.id});

  @override
  State<EmploiDuTempsPdfViewPage> createState() =>
      _EmploiDuTempsPdfViewPageState();
}

class _EmploiDuTempsPdfViewPageState extends State<EmploiDuTempsPdfViewPage> {
  final StudentService _studentService = StudentService();
  String? localPath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (widget.id == null) return;
    try {
      // 1. Download bytes
      final bytes = await _studentService.downloadEmploiDuTempsPdf(widget.id!);

      if (kIsWeb) {
        // Web: Trigger download / Open in new tab
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'emploi_${widget.id}.pdf';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = "Le PDF a été téléchargé.";
          });
        }
      } else {
        // Mobile: Save to temp file
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/emploi_${widget.id}.pdf');
        await file.writeAsBytes(bytes, flush: true);

        if (mounted) {
          setState(() {
            localPath = file.path;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Impossible de charger le PDF. \nErreur: $e";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document ${widget.id ?? ""}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kIsWeb
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.download_done,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage ?? "Le fichier a été téléchargé.",
                    textAlign: TextAlign.center,
                    style: ShadTheme.of(context).textTheme.p,
                  ),
                  const SizedBox(height: 16),
                  ShadButton(
                    child: const Text("Retour"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            )
          : localPath != null
          ? PDFView(
              filePath: localPath,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
              onError: (error) {
                print(error.toString());
              },
              onPageError: (page, error) {
                print('$page: ${error.toString()}');
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage ?? "Erreur inconnue",
                      textAlign: TextAlign.center,
                      style: ShadTheme.of(context).textTheme.p,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
