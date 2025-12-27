import 'dart:io';
import 'package:dio/dio.dart';
import '../../dto/etudiant/etudiant_dto.dart';
import '../../dto/etudiant/etudiant_request.dart';
import '../../services/api_service.dart'; // Importez votre ApiService global
import 'admin_endpoints.dart';

class AdminEtudiantService {
  // Utilisation de l'instance Dio configurée avec les intercepteurs (JWT/Refresh)
  final Dio _dio = ApiService().dio;

  // 1. Créer un étudiant
  Future<EtudiantDto> createEtudiant(EtudiantRequest request) async {
    final response = await _dio.post(
      AdminEndpoints.etudiantCreate,
      data: request.toJson(),
    );
    return EtudiantDto.fromJson(response.data);
  }

  // 2. Importer Excel (Gestion Multipart/FormData)
  Future<void> importEtudiantsExcel(File excelFile) async {
    String fileName = excelFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(excelFile.path, filename: fileName),
    });

    await _dio.post(
      AdminEndpoints.etudiantImportExcel,
      data: formData,
      // Le Content-Type est géré automatiquement par Dio pour le FormData
    );
  }

  // 3. Récupérer tous les étudiants (Pagination Spring Data JPA)
  Future<Map<String, dynamic>> getAllEtudiants({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      AdminEndpoints.etudiantGetAll,
      queryParameters: {"page": page, "size": size},
    );

    // On accède à 'content' car Spring Boot renvoie un objet Page
    List<dynamic> content = response.data['content'];
    List<EtudiantDto> students = content
        .map((json) => EtudiantDto.fromJson(json))
        .toList();

    // Extract pagination info
    int totalPages = response.data['totalPages'] ?? 1;
    int totalElements = response.data['totalElements'] ?? students.length;
    bool last = response.data['last'] ?? true;

    return {
      'students': students,
      'totalPages': totalPages,
      'totalElements': totalElements,
      'last': last,
    };
  }

  // 4. Récupérer par ID
  Future<EtudiantDto> getEtudiantById(int id) async {
    final response = await _dio.get(AdminEndpoints.etudiantGetById(id));
    return EtudiantDto.fromJson(response.data);
  }

  // 5. Mettre à jour
  Future<EtudiantDto> updateEtudiant(int id, EtudiantRequest request) async {
    final response = await _dio.put(
      AdminEndpoints.etudiantUpdate(id),
      data: request.toJson(),
    );
    return EtudiantDto.fromJson(response.data);
  }

  // 6. Supprimer
  Future<void> deleteEtudiant(int id) async {
    await _dio.delete(AdminEndpoints.etudiantDelete(id));
  }

  // 7. Sans inscription
  Future<List<EtudiantDto>> getEtudiantsSansInscription() async {
    final response = await _dio.get(AdminEndpoints.etudiantSansInscription);
    return (response.data as List)
        .map((json) => EtudiantDto.fromJson(json))
        .toList();
  }

  // 8. Par classe (Utilisation de la méthode dynamique)
  Future<List<EtudiantDto>> getEtudiantsByClasseId(int classeId) async {
    final response = await _dio.get(
      AdminEndpoints.etudiantGetByClasse(classeId),
    );
    return (response.data as List)
        .map((json) => EtudiantDto.fromJson(json))
        .toList();
  }
}
