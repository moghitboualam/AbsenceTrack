// Assurez-vous d'importer votre DTO Enseignant existant
import '../enseignant/enseignant_dto.dart';

class DepartementDto {
  final int? id;
  final String? code;
  final String? libelle;
  final EnseignantDto? chef; // Gardé au cas où, mais probablement null
  final String? chefNom; // FIELD AJOUTÉ
  final int? chefId; // FIELD AJOUTÉ
  final DateTime? dateNominationChef;
  final List<dynamic>? filieres;

  DepartementDto({
    this.id,
    this.code,
    this.libelle,
    this.chef,
    this.chefNom,
    this.chefId,
    this.dateNominationChef,
    this.filieres,
  });

  factory DepartementDto.fromJson(Map<String, dynamic> json) {
    return DepartementDto(
      id: json['id'],
      code: json['code'],
      libelle: json['libelle'],
      chef: json['chef'] != null ? EnseignantDto.fromJson(json['chef']) : null,
      chefNom: json['chefNom'], // MAPPING
      chefId: json['chefId'], // MAPPING
      dateNominationChef: json['dateNominationChef'] != null
          ? DateTime.tryParse(json['dateNominationChef'])
          : null,
      filieres: json['filieres'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'libelle': libelle,
      'chef': chef?.toJson(),
      'chefNom': chefNom,
      'chefId': chefId,
      'dateNominationChef': dateNominationChef?.toIso8601String(),
      'filieres': filieres,
    };
  }
}
