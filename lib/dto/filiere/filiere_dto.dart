import 'package:flutter_dashboard_app/dto/departement/departement_dto.dart';
import 'package:flutter_dashboard_app/dto/enseignant/enseignant_dto.dart';

class FiliereDto {
  final int? id;
  final String? code;
  final String? libelle;
  final int? dureeAnnees;
  final String? semistere;
  final DepartementDto? departement;
  final EnseignantDto? chefFiliere;

  FiliereDto({
    this.id,
    this.code,
    this.libelle,
    this.dureeAnnees,
    this.semistere,
    this.departement,
    this.chefFiliere,
  });

  factory FiliereDto.fromJson(Map<String, dynamic> json) {
    return FiliereDto(
      id: json['id'],
      code: json['code'],
      libelle: json['libelle'],
      dureeAnnees: json['dureeAnnees'],
      semistere: json['semistere'],
      departement: json['departement'] != null
          ? DepartementDto.fromJson(json['departement'])
          : (json['departementId'] != null
              ? DepartementDto(id: json['departementId'], libelle: json['departementNom'])
              : null),
      chefFiliere: json['chefFiliere'] != null
          ? EnseignantDto.fromJson(json['chefFiliere'])
          : (json['chefFiliereId'] != null
              ? EnseignantDto(id: json['chefFiliereId'], nom: json['chefFiliereNomComplet'], prenom: "")
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'libelle': libelle,
      'dureeAnnees': dureeAnnees,
      'semistere': semistere,
      'departement': departement?.toJson(),
      'chefFiliere': chefFiliere?.toJson(),
    };
  }
}
