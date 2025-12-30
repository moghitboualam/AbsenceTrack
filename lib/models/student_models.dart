class StudentDetails {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? codeMassar;
  final String? numCarte;
  final String? anneeUniversitaire;
  final String? filiereNom;
  final int? filiereId;
  final String? classeCode;
  final int? classId;
  final String? promotionCode;
  final String? avatarUrl;

  StudentDetails({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.codeMassar,
    this.numCarte,
    this.anneeUniversitaire,
    this.filiereNom,
    this.filiereId,
    this.classeCode,
    this.classId,
    this.promotionCode,
    this.avatarUrl,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      codeMassar: json['codeMassar'],
      numCarte: json['numCarte'],
      anneeUniversitaire: json['anneeUniversitaire'],
      filiereNom: json['filiereNom'],
      filiereId: json['filiereId'],
      classeCode: json['classeCode'],
      classId: json['classId'],
      promotionCode: json['promotionCode'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

class EmploiDuTemps {
  final int id;
  final String nom; // e.g. "Emploi du temps S1"
  final String? dateDebut;
  final String? dateFin;
  final String? semestreNum;
  final String? classeCode;
  final int? classeId;

  EmploiDuTemps({
    required this.id,
    required this.nom,
    this.dateDebut,
    this.dateFin,
    this.semestreNum,
    this.classeCode,
    this.classeId,
  });

  factory EmploiDuTemps.fromJson(Map<String, dynamic> json) {
    return EmploiDuTemps(
      id: json['id'],
      nom: json['nom'] ?? 'Emploi du temps',
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      semestreNum: json['semestreNum']?.toString(),
      classeCode: json['classeCode'],
      classeId: json['classeId'],
    );
  }
}

class EtudiantAbsence {
  final int id;
  final int? seanceId;
  final String? moduleNom;
  final String? typeSeance; // COURS, TD, TP
  final String? date;
  final String? heureDebut;
  final String? heureFin;
  final String? statut; // PRESENT, ABSENT, JUSTIFIE
  final String? justification;
  final String? etatJustification; // NON_SOUMIS, EN_ATTENTE, VALIDE, REFUSE
  final String? pieceJustificativePath;

  EtudiantAbsence({
    required this.id,
    this.seanceId,
    this.moduleNom,
    this.typeSeance,
    this.date,
    this.heureDebut,
    this.heureFin,
    this.statut,
    this.justification,
    this.etatJustification,
    this.pieceJustificativePath,
  });

  factory EtudiantAbsence.fromJson(Map<String, dynamic> json) {
    return EtudiantAbsence(
      id: json['id'],
      seanceId: json['seanceId'],
      moduleNom: json['moduleNom'],
      typeSeance: json['typeSeance'],
      date: json['date'],
      heureDebut: json['heureDebut'],
      heureFin: json['heureFin'],
      statut: json['statut'],
      justification: json['justification'],
      etatJustification: json['etatJustification'],
      pieceJustificativePath: json['pieceJustificativePath'],
    );
  }
}

class Seance {
  final int id;
  final String jour; // LUNDI, MARDI...
  final String heureDebut; // "08:30"
  final String heureFin; // "10:00"

  // Specific to Schedule Detail
  final String?
  moduleLibelle; // Keeping for backward compatibility if needed, or mapping from modulePromotionLibelle

  // DTO fields
  final int? modulePromotionId;
  final String? modulePromotionCode;
  final String? modulePromotionLibelle;
  final String? enseignantNomComplet;
  final int? salleId;
  final String? salleCode;
  final int? emploiDuTempsId;
  final String? type;
  final bool? isPresent;

  Seance({
    required this.id,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    this.moduleLibelle,
    this.modulePromotionLibelle,
    this.enseignantNomComplet,
    this.salleCode,
    this.modulePromotionId,
    this.modulePromotionCode,
    this.salleId,
    this.emploiDuTempsId,
    this.type,
    this.isPresent,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: json['id'],
      jour: json['jour'] ?? '',
      heureDebut: json['heureDebut'] ?? '',
      heureFin: json['heureFin'] ?? '',
      moduleLibelle:
          json['moduleLibelle'] ??
          json['modulePromotionLibelle'] ??
          '', // Fallback
      modulePromotionLibelle: json['modulePromotionLibelle'],
      enseignantNomComplet: json['enseignantNomComplet'],
      salleCode: json['salleCode'],
      modulePromotionId: json['modulePromotionId'],
      modulePromotionCode: json['modulePromotionCode'],
      salleId: json['salleId'],
      emploiDuTempsId: json['emploiDuTempsId'],
      type: json['type'],
      isPresent: json['isPresent'],
    );
  }
}

class EmploiDuTempsDetail extends EmploiDuTemps {
  final List<Seance> seanceDtos;

  EmploiDuTempsDetail({
    required super.id,
    required super.nom,
    super.dateDebut,
    super.dateFin,
    super.semestreNum,
    super.classeCode,
    super.classeId,
    required this.seanceDtos,
  });

  factory EmploiDuTempsDetail.fromJson(Map<String, dynamic> json) {
    var list = json['seanceDtos'] as List? ?? [];
    List<Seance> seanceList = list.map((i) => Seance.fromJson(i)).toList();

    return EmploiDuTempsDetail(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? 'Emploi du temps',
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      semestreNum: json['semestreNum']?.toString(),
      classeCode: json['classeCode'],
      classeId: json['classeId'],
      seanceDtos: seanceList,
    );
  }
}
