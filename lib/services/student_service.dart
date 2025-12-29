import 'dart:io';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/student_models.dart';

class StudentService {
  final ApiService _apiService = ApiService();

  // Endpoints
  static const String _myDetails = '/etudiants/details';
  static const String _timetables = '/etudiants/emploi-du-temps';
  static String _timetablePdf(String id) =>
      '/etudiants/emploi-du-temps/$id/pdf';
  static String _timetableDetails(String id) =>
      '/etudiants/emploi-du-temps/$id';
  static const String _mesAbsences = '/etudiants/seances/absences';
  static const String _mesSeances = '/etudiants/seances';
  static const String _activeOpenSeances = '/etudiants/seances/active-open';
  static String _markPresence(int id) => '/etudiants/seances/$id/presence';

  /// Récupère la liste des absences de l'étudiant
  Future<List<EtudiantAbsence>> getMesAbsences() async {
    try {
      final response = await _apiService.dio.get(_mesAbsences);
      if (response.data is List) {
        return (response.data as List)
            .map((e) => EtudiantAbsence.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des absences: $e');
    }
  }

  /// Récupère la liste des séances de l'étudiant
  Future<List<Seance>> getMesSeances() async {
    try {
      final response = await _apiService.dio.get(_mesSeances);
      if (response.data is List) {
        return (response.data as List).map((e) => Seance.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des séances: $e');
    }
  }

  /// Récupère les détails de l'étudiant connecté
  Future<StudentDetails> getMyDetails() async {
    try {
      final response = await _apiService.dio.get(_myDetails);
      return StudentDetails.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil étudiant: $e');
    }
  }

  /// Récupère les emplois du temps pour une classe donnée
  Future<List<EmploiDuTemps>> getEmploiDuTempsByClassId(int classId) async {
    try {
      final response = await _apiService.dio.get(
        _timetables,
        queryParameters: {'classeId': classId},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((e) => EmploiDuTemps.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des emplois du temps: $e',
      );
    }
  }

  /// Récupère les détails d'un emploi du temps (avec séances)
  Future<EmploiDuTempsDetail> getEmploiDuTempsDetailsById(String id) async {
    try {
      final response = await _apiService.dio.get(_timetableDetails(id));
      return EmploiDuTempsDetail.fromJson(response.data);
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du détail de l\'emploi du temps: $e',
      );
    }
  }

  /// Télécharge le PDF de l'emploi du temps
  Future<List<int>> downloadEmploiDuTempsPdf(String id) async {
    try {
      final response = await _apiService.dio.get(
        _timetablePdf(id),
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du PDF: $e');
    }
  }

  /// Récupère les séances actives (ouvertes au marquage)
  Future<List<Seance>> getActiveOpenSeances() async {
    try {
      final response = await _apiService.dio.get(_activeOpenSeances);
      if (response.data is List) {
        return (response.data as List).map((e) => Seance.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des séances actives: $e');
    }
  }

  /// Marque la présence pour une séance donnée
  Future<bool> markPresence(int seanceId) async {
    try {
      final response = await _apiService.dio.post(_markPresence(seanceId));
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ??
              'Erreur lors du marquage de la présence',
        );
      }
      throw Exception('Erreur lors du marquage de la présence: $e');
    }
  }

  /// Justifier une absence
  Future<EtudiantAbsence> justifierAbsence(
    int absenceId,
    File? file,
    List<int>? fileBytes,
    String fileName,
    String? comment,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        if (comment != null) 'commentaire': comment,
      });

      if (file != null) {
        // Mobile / Desktop (Platform File)
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      } else if (fileBytes != null) {
        // Web (Bytes)
        formData.files.add(
          MapEntry(
            'file',
            MultipartFile.fromBytes(fileBytes, filename: fileName),
          ),
        );
      }

      final response = await _apiService.dio.post(
        '/etudiants/absences/$absenceId/justifier',
        data: formData,
      );
      return EtudiantAbsence.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Erreur lors de la justification',
        );
      }
      throw Exception('Erreur lors de la justification de l\'absence: $e');
    }
  }

  // Endpoint for justifie absences list
  static const String _mesJustifications = '/etudiants/absences';

  /// Récupère la liste des justifications de l'étudiant
  Future<List<EtudiantAbsence>> getMesJustifications() async {
    try {
      final response = await _apiService.dio.get(_mesJustifications);
      if (response.data is List) {
        return (response.data as List)
            .map((e) => EtudiantAbsence.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des justifications: $e');
    }
  }
}
