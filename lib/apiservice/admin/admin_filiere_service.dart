import 'package:dio/dio.dart';
import 'package:flutter_dashboard_app/dto/filiere/filiere_dto.dart';
import 'package:flutter_dashboard_app/dto/filiere/filiere_request.dart';
import '../../services/api_service.dart';
import 'admin_endpoints.dart';

class AdminFiliereService {
  final Dio _dio = ApiService().dio;

  Future<FiliereDto> createFiliere(FiliereRequest request) async {
    try {
      final response = await _dio.post(
        AdminEndpoints.filiereCreate,
        data: request.toJson(),
      );
      return FiliereDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<FiliereDto> getFiliereById(int id) async {
    try {
      final response = await _dio.get(AdminEndpoints.filiereGetById(id));
      return FiliereDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAllFilieres({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        AdminEndpoints.filiereGetAll,
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

  Future<FiliereDto> updateFiliere(int id, FiliereRequest request) async {
    try {
      final response = await _dio.put(
        AdminEndpoints.filiereUpdate(id),
        data: request.toJson(),
      );
      return FiliereDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteFiliere(int id) async {
    try {
      await _dio.delete(AdminEndpoints.filiereDelete(id));
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
