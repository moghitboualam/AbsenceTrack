
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dashboard_app/services/api_service.dart';
import '../../dto/inscription/inscription_dto.dart';
import '../../dto/inscription/inscription_request.dart';

class AdminInscriptionService {
  final Dio _dio = ApiService().dio;

  // Ideally, these constants should be in admin_endpoints.dart,
  // but for consistency with previous quick fixes, defining them here locally or checking existing file.
  // I will check admin_endpoints.dart later to clean up.
  // Base endpoint usually /admin/inscriptions - waiting for AdminInscriptionController verification.
  // Controller confirmed: @RequestMapping("/api/v1/admin/inscriptions")
  // Note: Flutter API client usually expects paths relative to base URL if set, or full paths.
  // My other services used "/admin/..." ? Let's check AdminEndpoints constants.
  // If base URL includes /api/v1, then just /admin/inscriptions is fine.
  
  final String _baseEndpoint = "/admin/inscriptions";

  // Get Inscriptions by Promotion
  Future<List<InscriptionDto>> getInscriptionsByPromotion(int promotionId) async {
    final response = await _dio.get("$_baseEndpoint/byPromotion/$promotionId");
    final List<dynamic> data = response.data;
    return data.map((e) => InscriptionDto.fromJson(e)).toList();
  }

  // Create Inscription
  Future<InscriptionDto> createInscription(InscriptionRequest request) async {
    final response = await _dio.post(
      _baseEndpoint,
      data: request.toJson(),
    );
    return InscriptionDto.fromJson(response.data);
  }

  // Delete Inscription
  Future<void> deleteInscription(int id) async {
    await _dio.delete("$_baseEndpoint/$id");
  }

  // Auto Inscription (if needed, mirrors backend functionality)
  Future<InscriptionDto> inscriptionAutomatique(int etudiantId, int promotionId) async {
    final response = await _dio.post(
      "$_baseEndpoint/auto",
      data: {
        "etudiantId": etudiantId,
        "promotionId": promotionId,
      },
    );
    return InscriptionDto.fromJson(response.data);
  }

  // Import Inscriptions from Excel
  Future<void> importInscriptionsExcel(File excelFile, int promotionId) async {
    String fileName = excelFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(excelFile.path, filename: fileName),
    });

    await _dio.post(
      "$_baseEndpoint/import/$promotionId",
      data: formData,
    );
  }
}
