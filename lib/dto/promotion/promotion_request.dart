class PromotionRequest {
  final String codePromotion;
  final int filiereId;
  final int annee;
  final int anneeUniversitaireId;

  PromotionRequest({
    required this.codePromotion,
    required this.filiereId,
    required this.annee,
    required this.anneeUniversitaireId,
  });

  Map<String, dynamic> toJson() {
    return {
      'codePromotion': codePromotion,
      'filiereId': filiereId,
      'annee': annee,
      'anneeUniversitaireId': anneeUniversitaireId,
    };
  }
}
