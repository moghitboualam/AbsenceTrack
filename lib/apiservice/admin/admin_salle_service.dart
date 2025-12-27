import 'package:dio/dio.dart';
import '../../dto/salle/salle_dto.dart';
import '../../dto/salle/salle_request.dart';
import '../../services/api_service.dart';

class AdminSalleService {
  final Dio _dio = ApiService().dio;
  final String _basePath = '/admin/salles';

  Future<dynamic> getAllSalles({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        _basePath,
        queryParameters: {'page': page, 'size': size},
      );
      return response.data;
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  Future<SalleDto> getSalleById(int id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      return SalleDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  Future<SalleDto> createSalle(SalleRequest request) async {
    try {
      final response = await _dio.post(
        _basePath,
        data: request.toJson(),
      );
      return SalleDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  Future<SalleDto> updateSalle(int id, SalleRequest request) async {
    try {
      final response = await _dio.put(
        '$_basePath/$id',
        data: request.toJson(),
      );
      return SalleDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  Future<void> deleteSalle(int id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  Exception _handleServiceError(Object e) {
    if (e is DioException) {
      return Exception(
        e.response?.data['message'] ?? 'Erreur API: ${e.message}',
      );
    }
    return Exception("Erreur inattendue: $e");
  }
}
