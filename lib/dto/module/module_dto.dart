import 'package:flutter_dashboard_app/dto/filiere/filiere_dto.dart';

class ModuleDto {
  final int? id;
  final String? libelle;
  final int? volumeHoraire;
  final String? semestreReference; // Keep for legacy/fallback
  final String? semestreLibelle;
  final String? filiereLibelle;

  ModuleDto({
    this.id,
    this.libelle,
    this.volumeHoraire,
    this.semestreReference,
    this.semestreLibelle,
    this.filiereLibelle,
  });

  factory ModuleDto.fromJson(Map<String, dynamic> json) {
    return ModuleDto(
      id: json['id'],
      libelle: json['libelle'],
      volumeHoraire: json['volumeHoraire'],
      semestreReference: json['semestreReference'],
      semestreLibelle: json['semestreReferenceLibelle'], // Matched to backend
      filiereLibelle: json['filiereLibelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'volumeHoraire': volumeHoraire,
      'semestreReference': semestreReference,
      'semestreLibelle': semestreLibelle,
      'filiereLibelle': filiereLibelle,
    };
  }
}

