import 'package:dio/dio.dart';
import '../../dto/promotion/promotion_dto.dart';
import '../../dto/promotion/promotion_request.dart';
import '../../services/api_service.dart';
import 'admin_endpoints.dart';

class AdminPromotionService {
  final Dio _dio = ApiService().dio;

  Future<PromotionDto> createPromotion(PromotionRequest request) async {
    try {
      final response = await _dio.post(
        AdminEndpoints.promotionCreate,
        data: request.toJson(),
      );
      return PromotionDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PromotionDto> getPromotionById(int id) async {
    try {
      final response = await _dio.get(AdminEndpoints.promotionGetById(id));
      return PromotionDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAllPromotions({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        AdminEndpoints.promotionGetAll,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'id,asc',
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PromotionDto> updatePromotion(int id, PromotionRequest request) async {
    try {
      final response = await _dio.put(
        AdminEndpoints.promotionUpdate(id),
        data: request.toJson(),
      );
      return PromotionDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePromotion(int id) async {
    try {
      await _dio.delete(AdminEndpoints.promotionDelete(id));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<PromotionDto>> getPromotionsByFiliereId(int filiereId) async {
    try {
      final response = await _dio.get(AdminEndpoints.promotionByFiliere(filiereId));
      return (response.data as List)
          .map((e) => PromotionDto.fromJson(e))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<PromotionDto>> getPromotionsByAnneeUniversitaireId(int anneeId) async {
    try {
      final response = await _dio.get(AdminEndpoints.promotionByAnnee(anneeId));
      return (response.data as List)
          .map((e) => PromotionDto.fromJson(e))
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
