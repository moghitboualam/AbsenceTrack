import 'package:dio/dio.dart';
import 'package:flutter_dashboard_app/dto/emploi_du_temps/emploi_du_temps_dto.dart';
import 'package:flutter_dashboard_app/dto/emploi_du_temps/emploi_du_temps_request.dart';
import 'package:flutter_dashboard_app/dto/seance/seance_request.dart';
import 'package:flutter_dashboard_app/services/api_service.dart';
import 'admin_endpoints.dart';

class AdminEmploiDuTempsService {
  final Dio _dio = ApiService().dio;

  Future<List<EmploiDuTempsDto>> getAllEmploiDuTemps() async {
    try {
      final response = await _dio.get(AdminEndpoints.edtGetAll);
      return (response.data as List)
          .map((e) => EmploiDuTempsDto.fromJson(e))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<EmploiDuTempsDto> getEmploiDuTempsById(int id) async {
    try {
      final response = await _dio.get(AdminEndpoints.edtGetById(id));
      return EmploiDuTempsDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<EmploiDuTempsDto> createEmploiDuTemps(EmploiDuTempsRequest request) async {
    try {
      final response = await _dio.post(
        AdminEndpoints.edtCreate,
        data: request.toJson(),
      );
      return EmploiDuTempsDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<EmploiDuTempsDto> updateEmploiDuTemps(int id, EmploiDuTempsRequest request) async {
    try {
      final response = await _dio.put(
        AdminEndpoints.edtUpdate(id),
        data: request.toJson(),
      );
      return EmploiDuTempsDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteEmploiDuTemps(int id) async {
    try {
      await _dio.delete(AdminEndpoints.edtDelete(id));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> addSeance(SeanceRequest request) async {
    try {
      final response = await _dio.post(
        AdminEndpoints.edtSeanceAdd,
        data: request.toJson(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> updateSeance(int id, SeanceRequest request) async {
    try {
      final response = await _dio.put(
        AdminEndpoints.edtUpdateSeance(id),
        data: request.toJson(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSeance(int id) async {
    try {
      await _dio.delete(AdminEndpoints.edtDeleteSeance(id));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<EmploiDuTempsDto> generateEmploiDuTemps(int classeId, int semestreId) async {
    try {
      final response = await _dio.post(AdminEndpoints.edtGenerate(classeId, semestreId));
      return EmploiDuTempsDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Retourne les octets du PDF
  Future<List<int>> downloadTimetablePdf(int id) async {
    try {
      final response = await _dio.get(
        AdminEndpoints.edtDownloadPdf(id),
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    String msg = "Une erreur inconnue est survenue";
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          msg = data['message'];
        } else {
          msg = "Erreur serveur (${error.response?.statusCode})";
        }
      } else {
        msg = "Erreur de connexion au serveur";
      }
    }
    return Exception(msg);
  }
}
