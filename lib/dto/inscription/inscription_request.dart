
class InscriptionRequest {
  final int? etudiantId;
  final int? promotionId;
  final bool redoublant;
  final int annee;

  InscriptionRequest({
    this.etudiantId,
    this.promotionId,
    this.redoublant = false, // Default to false
    this.annee = 1, // Default to 1
  });

  Map<String, dynamic> toJson() {
    return {
      'etudiantId': etudiantId,
      'promotionId': promotionId,
      'redoublant': redoublant,
      'annee': annee,
    };
  }
}
