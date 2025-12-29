import 'package:dio/dio.dart';
import '../../dto/module_promotion/module_promotion_dto.dart';
import '../../services/api_service.dart';
import 'admin_endpoints.dart';

class AdminModulePromotionService {
  final Dio _dio = ApiService().dio;

  Future<void> generateModulesForPromotion(int promotionId) async {
    try {
      final request = await _dio.post(AdminEndpoints.modulePromoGenerate(promotionId), options: Options(contentType: Headers.jsonContentType));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ModulePromotionDto>> getModulesByPromotionAndSemester(
    int promotionId,
    int semestreId,
  ) async {
    try {
      final response = await _dio.get(
        AdminEndpoints.modulePromoByPromoAndSemestre(promotionId, semestreId),
      );
      return (response.data as List)
          .map((e) => ModulePromotionDto.fromJson(e))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> assignEnseignantToModule(
    int modulePromotionId,
    int enseignantId,
  ) async {
    try {
      // Backend expects raw ID in body, not JSON object according to React code:
      // await apiClient.put(..., enseignantId);
      await _dio.put(
        AdminEndpoints.modulePromoAssignEnseignant(modulePromotionId),
        data: enseignantId,
        options: Options(
          contentType: Headers.jsonContentType, // Ensure it sends as JSON number if needed, or text
        ),
      );
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
