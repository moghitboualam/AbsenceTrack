class PromotionDto {
  final int id;
  final String codePromotion;
  final int filiereId;
  final String? filiereNom;
  final int anneeUniversitaireId;
  final String? anneeUniversitaireNom;
  final int annee;
  final int dureeAnnees;

  PromotionDto({
    required this.id,
    required this.codePromotion,
    required this.filiereId,
    this.filiereNom,
    required this.anneeUniversitaireId,
    this.anneeUniversitaireNom,
    required this.annee,
    required this.dureeAnnees,
  });

  factory PromotionDto.fromJson(Map<String, dynamic> json) {
    return PromotionDto(
      id: json['id'],
      codePromotion: json['codePromotion'] ?? 'N/A',
      filiereId: json['filiereId'],
      filiereNom: json['filiereNom'],
      anneeUniversitaireId: json['anneeUniversitaireId'],
      anneeUniversitaireNom: json['anneeUniversitaireNom'],
      annee: json['annee'],
      dureeAnnees: json['dureeAnnees'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codePromotion': codePromotion,
      'filiereId': filiereId,
      'filiereNom': filiereNom,
      'anneeUniversitaireId': anneeUniversitaireId,
      'anneeUniversitaireNom': anneeUniversitaireNom,
      'annee': annee,
      'dureeAnnees': dureeAnnees,
    };
  }
}
