import 'package:dio/dio.dart';
import '../../dto/bloc/bloc_dto.dart';
import '../../dto/bloc/bloc_request.dart';
import '../../services/api_service.dart';

class AdminBlocService {
  final Dio _dio = ApiService().dio;
  final String _basePath = '/admin/blocs';

  Future<dynamic> getAllBlocs({int page = 0, int size = 10}) async {
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

  Future<BlocDto> getBlocById(int id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      return BlocDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  Future<BlocDto> createBloc(BlocRequest request) async {
    try {
      final response = await _dio.post(
        _basePath,
        data: request.toJson(),
      );
      return BlocDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  Future<BlocDto> updateBloc(int id, BlocRequest request) async {
    try {
      final response = await _dio.put(
        '$_basePath/$id',
        data: request.toJson(),
      );
      return BlocDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  Future<void> deleteBloc(int id) async {
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
