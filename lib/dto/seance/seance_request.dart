class SeanceRequest {
  final int? id;
  final String? jour;
  final String? heureDebut;
  final String? heureFin;
  final int? modulePromotionId;
  final int? salleId;
  final int? emploiDuTempsId;
  final String? type;

  SeanceRequest({
    this.id,
    this.jour,
    this.heureDebut,
    this.heureFin,
    this.modulePromotionId,
    this.salleId,
    this.emploiDuTempsId,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jour': jour,
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'modulePromotionId': modulePromotionId,
      'salleId': salleId,
      'emploiDuTempsId': emploiDuTempsId,
      'type': type,
    };
  }
}
