import 'package:dio/dio.dart';
import 'package:flutter_dashboard_app/dto/departement/assigne_chef_request.dart';
import '../../services/api_service.dart';
import '../../dto/departement/departement_dto.dart';
import '../../dto/departement/departement_request.dart';

class AdminDepartementService {
  // Instance du Dio via votre Singleton
  final Dio _dio = ApiService().dio;

  // Base URL (Assurez-vous qu'elle correspond à votre Controller Java)
  static const String _basePath = '/admin/departements';

  // 1. CREATE (Correspond à createDepartement)
  Future<DepartementDto> createDepartement(DepartementRequest request) async {
    try {
      final response = await _dio.post(_basePath, data: request.toJson());
      return DepartementDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 2. GET BY ID (Correspond à getDepartementById)
  Future<DepartementDto> getDepartementById(int id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      return DepartementDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 3. GET ALL (Correspond à getAllDepartements)
  Future<Map<String, dynamic>> getAllDepartements({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        _basePath,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'id,asc', // Tri par défaut
        },
      );
      return response.data; // Retourne la Page<DepartementDto>
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 4. UPDATE (Correspond à updateDepartement)
  Future<DepartementDto> updateDepartement(
    int id,
    DepartementRequest request,
  ) async {
    try {
      final response = await _dio.put('$_basePath/$id', data: request.toJson());
      return DepartementDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 5. DELETE (Correspond à deleteDepartement)
  Future<void> deleteDepartement(int id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 6. ASSIGN CHEF (Correspond à assignChefToDepartement)
  // Note: Vérifiez l'URL exacte dans votre Controller Java. Souvent c'est /{id}/chef ou /assign-chef
  Future<DepartementDto> assignChefToDepartement(
    int departementId,
    AssignChefRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '$_basePath/$departementId/assign-chef', // Adaptez selon votre Controller (@PutMapping ou @PostMapping)
        data: request.toJson(),
      );
      return DepartementDto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- Gestion centralisée des erreurs (Style React/Axios) ---
  Exception _handleError(dynamic error) {
    String msg = "Une erreur inconnue est survenue";
    if (error is DioException) {
      if (error.response != null) {
        // Erreur renvoyée par Spring Boot (ex: ResourceNotFoundException, IllegalArgumentException)
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
