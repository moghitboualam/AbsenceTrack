import 'package:dio/dio.dart';
import 'package:flutter_dashboard_app/dto/module/module_dto.dart';
import 'package:flutter_dashboard_app/dto/module/module_request.dart';
import '../../services/api_service.dart';
import 'admin_endpoints.dart';

class AdminModuleService {
  final Dio _dio = ApiService().dio;

  Future<ModuleDto> createModule(ModuleRequest request) async {
    try {
      final response = await _dio.post(
        AdminEndpoints.moduleCreate,
        data: request.toJson(),
      );
      return ModuleDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ModuleDto> getModuleById(int id) async {
    try {
      final response = await _dio.get(AdminEndpoints.moduleGetById(id));
      return ModuleDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAllModules({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        AdminEndpoints.moduleGetAll,
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

  Future<ModuleDto> updateModule(int id, ModuleRequest request) async {
    try {
      final response = await _dio.put(
        AdminEndpoints.moduleUpdate(id),
        data: request.toJson(),
      );
      return ModuleDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteModule(int id) async {
    try {
      await _dio.delete(AdminEndpoints.moduleDelete(id));
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
