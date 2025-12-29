class TeacherDetails {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? specialite;
  final bool estChefDepartement;
  final List<DepartementDirige> departementsDiriges;
  final List<ModuleEnseigne> modulesEnseignes;

  TeacherDetails({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.specialite,
    this.estChefDepartement = false,
    this.departementsDiriges = const [],
    this.modulesEnseignes = const [],
  });

  factory TeacherDetails.fromJson(Map<String, dynamic> json) {
    return TeacherDetails(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      specialite: json['specialite'],
      estChefDepartement: json['estChefDepartement'] ?? false,
      departementsDiriges:
          (json['departementsDiriges'] as List?)
              ?.map((e) => DepartementDirige.fromJson(e))
              .toList() ??
          [],
      modulesEnseignes:
          (json['modulesEnseignes'] as List?)
              ?.map((e) => ModuleEnseigne.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DepartementDirige {
  final int id;
  final String libelle;
  final String code;

  DepartementDirige({
    required this.id,
    required this.libelle,
    required this.code,
  });

  factory DepartementDirige.fromJson(Map<String, dynamic> json) {
    return DepartementDirige(
      id: json['id'],
      libelle: json['libelle'],
      code: json['code'],
    );
  }
}

class ModuleEnseigne {
  final int id;
  final String moduleLibelle;
  final String? semestreLibelle;
  final String? promotionCode;
  final String? code;

  ModuleEnseigne({
    required this.id,
    required this.moduleLibelle,
    this.semestreLibelle,
    this.promotionCode,
    this.code,
  });

  factory ModuleEnseigne.fromJson(Map<String, dynamic> json) {
    return ModuleEnseigne(
      id: json['id'],
      moduleLibelle: json['moduleLibelle'],
      semestreLibelle: json['semestreLibelle'],
      promotionCode: json['promotionCode'],
      code: json['code'],
    );
  }
}

class TeacherTimetable {
  final String? enseignantNom;
  final String? enseignantPrenom;
  final List<TeacherSeance> seances;

  TeacherTimetable({
    this.enseignantNom,
    this.enseignantPrenom,
    this.seances = const [],
  });

  factory TeacherTimetable.fromJson(Map<String, dynamic> json) {
    return TeacherTimetable(
      enseignantNom: json['enseignantNom'],
      enseignantPrenom: json['enseignantPrenom'],
      seances:
          (json['seances'] as List?)
              ?.map((e) => TeacherSeance.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TeacherSeance {
  final int id;
  final String jour;
  final String heureDebut;
  final String heureFin;
  final String moduleLibelle;
  final String? type; // TD, TP, CM
  final String? salleCode;
  final String? classeCode;
  final String? promotionCode;

  TeacherSeance({
    required this.id,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    required this.moduleLibelle,
    this.type,
    this.salleCode,
    this.classeCode,
    this.promotionCode,
  });

  factory TeacherSeance.fromJson(Map<String, dynamic> json) {
    return TeacherSeance(
      id: json['id'] ?? 0,
      jour: json['jour'] ?? '',
      heureDebut: json['heureDebut'] ?? '',
      heureFin: json['heureFin'] ?? '',
      moduleLibelle: json['moduleLibelle'] ?? '',
      type: json['type'],
      salleCode: json['salleCode'],
      classeCode: json['classeCode'],
      promotionCode: json['promotionCode'],
    );
  }
}

class ProfesseurSeanceDto {
  final int id;
  final String moduleNom;
  final String typeSeance;
  final String jour;
  final String heureDebut;
  final String heureFin;
  final String classeCode;
  final String? salleNom;
  final bool sessionOuverte;
  final bool estAujourdhui;

  ProfesseurSeanceDto({
    required this.id,
    required this.moduleNom,
    required this.typeSeance,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    required this.classeCode,
    this.salleNom,
    required this.sessionOuverte,
    required this.estAujourdhui,
  });

  factory ProfesseurSeanceDto.fromJson(Map<String, dynamic> json) {
    return ProfesseurSeanceDto(
      id: json['id'] ?? 0,
      moduleNom: json['moduleNom'],
      typeSeance: json['typeSeance'],
      jour: json['jour'],
      heureDebut: json['heureDebut']?.toString() ?? '',
      heureFin: json['heureFin']?.toString() ?? '',
      classeCode: json['classeCode'],
      salleNom: json['salleNom'],
      sessionOuverte: json['sessionOuverte'] ?? false,
      estAujourdhui: json['estAujourdhui'] ?? false,
    );
  }
}

class SessionOuvertureRequest {
  final int dureeMinutes;

  SessionOuvertureRequest({required this.dureeMinutes});

  Map<String, dynamic> toJson() => {'dureeMinutes': dureeMinutes};
}

class AvertissementRequest {
  final String motif;

  AvertissementRequest({required this.motif});

  Map<String, dynamic> toJson() => {'motif': motif};
}

class SessionEtudiantsDto {
  final int seanceId;
  final String moduleLibelle;
  final String classeCode;
  final String jour;
  final String heureDebut;
  final String heureFin;
  final List<EtudiantDto> etudiants;

  SessionEtudiantsDto({
    required this.seanceId,
    required this.moduleLibelle,
    required this.classeCode,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    required this.etudiants,
  });

  factory SessionEtudiantsDto.fromJson(Map<String, dynamic> json) {
    return SessionEtudiantsDto(
      seanceId: json['seanceId'],
      moduleLibelle: json['moduleLibelle'],
      classeCode: json['classeCode'],
      jour: json['jour'],
      heureDebut: json['heureDebut']?.toString() ?? '',
      heureFin: json['heureFin']?.toString() ?? '',
      etudiants:
          (json['etudiants'] as List?)
              ?.map((e) => EtudiantDto.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EtudiantDto {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? photo;
  // Assuming there might be a presence status, but defaulting to false if not provided
  final bool present;

  EtudiantDto({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.photo,
    this.present = false,
  });

  factory EtudiantDto.fromJson(Map<String, dynamic> json) {
    return EtudiantDto(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'],
      // Adjust based on your actual backend EtudiantDto
      present: json['present'] ?? false,
    );
  }
}

class AbsenceDto {
  final int id;
  final int seanceId;
  final int etudiantId;
  final String? etudiantNom;
  final String? etudiantPrenom;
  final String? dateAbsence;
  final String? heureDebut;
  final String? heureFin;
  final String? justification;
  final String statut;
  final String? etatJustification; // NON_SOUMIS, EN_ATTENTE, VALIDE, REFUSE
  final String? pieceJustificativePath;

  AbsenceDto({
    required this.id,
    required this.seanceId,
    required this.etudiantId,
    this.etudiantNom,
    this.etudiantPrenom,
    this.dateAbsence,
    this.heureDebut,
    this.heureFin,
    this.justification,
    required this.statut,
    this.etatJustification,
    this.pieceJustificativePath,
  });

  factory AbsenceDto.fromJson(Map<String, dynamic> json) {
    return AbsenceDto(
      id: json['id'],
      seanceId: json['seanceId'],
      etudiantId: json['etudiantId'],
      etudiantNom: json['etudiantNom'],
      etudiantPrenom: json['etudiantPrenom'],
      dateAbsence: json['dateAbsence'],
      heureDebut: json['heureDebut']?.toString(),
      heureFin: json['heureFin']?.toString(),
      justification: json['justification'],
      statut: json['statut'] ?? 'ABSENT',
      etatJustification: json['etatJustification'],
      pieceJustificativePath: json['pieceJustificativePath'],
    );
  }
}

class AbsenceRequest {
  final int seanceId;
  final List<int> etudiantIds;
  final String dateAbsence; // yyyy-MM-dd
  final String heureDebut; // HH:mm:ss
  final String heureFin; // HH:mm:ss
  final String? justification;
  final String statut; // ABSENT

  AbsenceRequest({
    required this.seanceId,
    required this.etudiantIds,
    required this.dateAbsence,
    required this.heureDebut,
    required this.heureFin,
    this.justification,
    this.statut = 'ABSENT',
  });

  Map<String, dynamic> toJson() => {
    'seanceId': seanceId,
    'etudiantIds': etudiantIds,
    'dateAbsence': dateAbsence,
    'heureDebut': heureDebut,
    'heureFin': heureFin,
    'justification': justification,
    'statut': statut,
  };
}
