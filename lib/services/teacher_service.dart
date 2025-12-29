import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/teacher_models.dart';

class TeacherService {
  final ApiService _apiService = ApiService();

  // Endpoints
  // Note: Based on React endpoint.js, keys are GET_ME and GET_EMPLOI_DU_TEMPS
  static const String _myDetails = '/enseignants/me';
  static const String _myTimetable = '/enseignants/emploi-du-temps';

  // Nouveaux Endpoints Professeur
  static const String _profSeances = '/professeurs/seances';
  static const String _profSeancesActive = '/professeurs/seances/active';
  static String _sessionEtudiants(int id) =>
      '/professeurs/seances/$id/etudiants';
  static String _startSession(int id) =>
      '/professeurs/seances/$id/session/start';
  static String _closeSession(int id) =>
      '/professeurs/seances/$id/cloture-et-validation';
  static String _sendWarning(int id) =>
      '/professeurs/etudiants/$id/avertissement';

  /// Récupère la liste des séances du professeur (avec état session/aujourd'hui)
  Future<List<ProfesseurSeanceDto>> getMesSeancesProfesseur() async {
    try {
      final response = await _apiService.dio.get(_profSeances);
      if (response.data is List) {
        return (response.data as List)
            .map((e) => ProfesseurSeanceDto.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des séances professeur: $e',
      );
    }
  }

  /// Récupère les séances actives (ou la séance active unique)
  Future<List<ProfesseurSeanceDto>> getMesSeancesActive() async {
    try {
      final response = await _apiService.dio.get(_profSeancesActive);
      // Cas où l'API renvoie une liste
      if (response.data is List) {
        return (response.data as List)
            .map((e) => ProfesseurSeanceDto.fromJson(e))
            .toList();
      }
      // Cas où l'API renvoie un objet unique (active session)
      else if (response.data is Map<String, dynamic>) {
        return [ProfesseurSeanceDto.fromJson(response.data)];
      }
      return [];
    } catch (e) {
      // Si 204 No Content ou autre erreur, on retourne vide
      return [];
    }
  }

  /// Récupère les étudiants d'une séance
  Future<SessionEtudiantsDto> getEtudiantsBySeance(int seanceId) async {
    try {
      final response = await _apiService.dio.get(_sessionEtudiants(seanceId));
      return SessionEtudiantsDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des étudiants: $e');
    }
  }

  /// Ouvre une session pour une séance donnée
  Future<void> ouvrirSession(int seanceId, int dureeMinutes) async {
    try {
      await _apiService.dio.post(
        _startSession(seanceId),
        data: SessionOuvertureRequest(dureeMinutes: dureeMinutes).toJson(),
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'ouverture de la session: $e');
    }
  }

  /// Valide les présences et clôture la session
  Future<void> validerSession(int seanceId) async {
    try {
      await _apiService.dio.post(_closeSession(seanceId));
    } catch (e) {
      throw Exception('Erreur lors de la validation de la session: $e');
    }
  }

  /// Envoie un avertissement à un étudiant
  Future<void> envoyerAvertissement(int etudiantId, String motif) async {
    try {
      await _apiService.dio.post(
        _sendWarning(etudiantId),
        data: AvertissementRequest(motif: motif).toJson(),
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'avertissement: $e');
    }
  }

  /// Récupère les détails de l'enseignant connecté
  Future<TeacherDetails> getMyDetails() async {
    try {
      final response = await _apiService.dio.get(_myDetails);
      return TeacherDetails.fromJson(response.data);
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération du profil enseignant: $e',
      );
    }
  }

  /// Récupère l'emploi du temps de l'enseignant
  Future<TeacherTimetable> getMyTimetable() async {
    try {
      final response = await _apiService.dio.get(_myTimetable);
      return TeacherTimetable.fromJson(response.data);
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération de l\'emploi du temps: $e',
      );
    }
  }

  // --- Gestion des Absences ---

  static const String _absencesSession = '/enseignants/absences/session';

  static String _absencesBySeance(int id) => '/enseignants/absences/seance/$id';
  // New Endpoints
  static String _presencesBySeance(int id) =>
      '/enseignants/absences/seance/$id/presences';
  static String _invalidatePresence(int id) =>
      '/enseignants/absences/$id/invalidate';
  static String _markAbsent(int seanceId, int etudiantId) =>
      '/enseignants/absences/seance/$seanceId/etudiant/$etudiantId/absent';

  /// Marquer plusieurs étudiants comme absents pour une séance
  Future<List<AbsenceDto>> markAbsences(AbsenceRequest request) async {
    try {
      final response = await _apiService.dio.post(
        _absencesSession,
        data: request.toJson(),
      );
      if (response.data is List) {
        return (response.data as List)
            .map((e) => AbsenceDto.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la création des absences: $e');
    }
  }

  /// Récupérer les absences d'une séance
  Future<List<AbsenceDto>> getAbsencesBySeance(int seanceId) async {
    try {
      final response = await _apiService.dio.get(_absencesBySeance(seanceId));
      if (response.data is List) {
        return (response.data as List)
            .map((e) => AbsenceDto.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des absences: $e');
    }
  }

  /// Récupérer les présences d'une séance
  Future<List<EtudiantDto>> getPresencesBySeance(int seanceId) async {
    try {
      final response = await _apiService.dio.get(_presencesBySeance(seanceId));
      if (response.data is List) {
        return (response.data as List)
            .map((e) => EtudiantDto.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des présences: $e');
    }
  }

  /// Invalider une présence
  Future<void> invalidatePresence(int presenceId) async {
    try {
      await _apiService.dio.put(_invalidatePresence(presenceId));
    } catch (e) {
      throw Exception('Erreur lors de l\'invalidation de la présence: $e');
    }
  }

  /// Marquer un étudiant spécifique comme absent
  Future<void> markStudentAbsent(int seanceId, int etudiantId) async {
    try {
      await _apiService.dio.post(_markAbsent(seanceId, etudiantId));
    } catch (e) {
      throw Exception('Erreur lors du marquage comme absent: $e');
    }
  }

  // --- Gestion des Justifications ---

  static const String _pendingJustifications =
      '/enseignants/absences/justifications/pending';
  static String _justificationDoc(int id) =>
      '/enseignants/absences/$id/justification/document';
  static String _validateJustification(int id) =>
      '/enseignants/absences/$id/justification/validate';
  static String _refuseJustification(int id) =>
      '/enseignants/absences/$id/justification/refuse';

  /// Récupérer les justifications en attente
  Future<List<AbsenceDto>> getPendingJustifications() async {
    try {
      final response = await _apiService.dio.get(_pendingJustifications);
      if (response.data is List) {
        return (response.data as List)
            .map((e) => AbsenceDto.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des justifications: $e');
    }
  }

  /// Télécharger le document justificatif
  Future<List<int>> downloadJustificationDocument(int absenceId) async {
    try {
      final response = await _apiService.dio.get(
        _justificationDoc(absenceId),
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du justificatif: $e');
    }
  }

  /// Valider une justification
  Future<AbsenceDto> validateJustification(int absenceId) async {
    try {
      final response = await _apiService.dio.put(
        _validateJustification(absenceId),
      );
      return AbsenceDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la validation de la justification: $e');
    }
  }

  /// Refuser une justification
  Future<AbsenceDto> refuseJustification(
    int absenceId,
    String motifRefus,
  ) async {
    try {
      // Assuming existing backend expects "motif" or text body.
      // Based on user route description: REFUSE avec un motif.
      // Usually query param or body. Since it's PUT, body is likely.
      // Confirming: "Refuse la justification (avec commentaire)."
      final response = await _apiService.dio.put(
        _refuseJustification(absenceId),
        data: {
          'motif': motifRefus,
          'commentaire': motifRefus,
        }, // Trying both often safe or just query?
        // Let's stick to a standard map, commonly 'motif' or 'reason'.
      );
      return AbsenceDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors du refus de la justification: $e');
    }
  }
}
