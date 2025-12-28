import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import 'admin_endpoints.dart';
import '../../dto/anneeuniversitaire/annee_universitaire_dto.dart';

class AdminAnneeUniversitaireService {
  final Dio _dio = ApiService().dio;

  Future<List<AnneeUniversitaireDto>> getAllAnnees() async {
    try {
      final response = await _dio.get(AdminEndpoints.anneeUnivBase);
      return (response.data as List)
          .map((e) => AnneeUniversitaireDto.fromJson(e))
          .toList();
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
