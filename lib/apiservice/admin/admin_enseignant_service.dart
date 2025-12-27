import 'package:dio/dio.dart';
import '../../services/api_service.dart'; // Votre singleton ApiService
import '../../dto/enseignant/enseignant_dto.dart';
import '../../dto/enseignant/enseignant_request.dart';

class AdminEnseignantService {
  final Dio _dio = ApiService().dio;

  // Constantes pour les endpoints (similaire à ADMIN_ENDPOINTS)
  static const String _basePath = '/admin/enseignants';

  /// Récupérer tous les enseignants avec pagination
  /// @param page : numéro de la page (0 par défaut)
  /// @param size : taille de la page (10 par défaut)
  Future<Map<String, dynamic>> getAllEnseignants({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        _basePath,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'id,asc', // Tri par défaut comme dans votre React
        },
      );
      return response.data;
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  /// Récupérer un enseignant par ID
  Future<EnseignantDto> getEnseignantById(int id) async {
    try {
      final response = await _dio.get('$_basePath/$id');
      return EnseignantDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  /// Créer un nouvel enseignant
  Future<EnseignantDto> createEnseignant(EnseignantRequest request) async {
    try {
      final response = await _dio.post(_basePath, data: request.toJson());
      return EnseignantDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  /// Mettre à jour un enseignant existant
  Future<EnseignantDto> updateEnseignant(
    int id,
    EnseignantRequest request,
  ) async {
    try {
      final response = await _dio.put('$_basePath/$id', data: request.toJson());
      print('$_basePath/$id');
      return EnseignantDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  /// Supprimer un enseignant
  Future<void> deleteEnseignant(int id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  /// Assigner un enseignant comme Chef de Département
  /// On utilise une Map pour la requête car c'est une action spécifique
  Future<EnseignantDto> assignChefDepartement(
    int id,
    Map<String, dynamic> assignRequest,
  ) async {
    try {
      // endpoint supposé: /admin/enseignants/{id}/assign-chef
      final response = await _dio.post(
        '$_basePath/$id/assign-chef',
        data: assignRequest,
      );
      return EnseignantDto.fromJson(response.data);
    } catch (e) {
      throw _handleServiceError(e);
    }
  }

  // --- GESTION DES ERREURS (Traduction de handleServiceError) ---

  Exception _handleServiceError(dynamic error) {
    String errorMessage = "Une erreur s'est produite";

    if (error is DioException) {
      if (error.response != null) {
        // Le serveur a répondu avec un code d'erreur
        switch (error.response?.statusCode) {
          case 400:
            errorMessage =
                error.response?.data['message'] ?? "Données invalides";
            break;
          case 401:
            errorMessage = "Non autorisé (Veuillez vous reconnecter)";
            break;
          case 403:
            errorMessage = "Accès refusé";
            break;
          case 404:
            errorMessage =
                error.response?.data['message'] ?? "Ressource non trouvée";
            break;
          case 409:
            errorMessage =
                error.response?.data['message'] ??
                "Conflit: La ressource existe déjà";
            break;
          case 500:
            errorMessage = "Erreur serveur";
            break;
          default:
            errorMessage = error.response?.data['message'] ?? errorMessage;
        }
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Le serveur ne répond pas. Vérifiez votre connexion.";
      } else if (error.type == DioExceptionType.connectionError) {
        errorMessage = "Aucune connexion internet.";
      } else {
        errorMessage = error.message ?? errorMessage;
      }
    } else {
      // Erreur non-Dio (ex: erreur de parsing)
      errorMessage = error.toString();
    }

    return Exception(errorMessage);
  }
}
