class SeanceDto {
  final int? id;
  final String? jour;
  final String? heureDebut;
  final String? heureFin;
  final int? modulePromotionId;
  final String? modulePromotionCode;
  final String? modulePromotionLibelle;
  final String? enseignantNomComplet;
  final int? salleId;
  final String? salleCode;
  final int? emploiDuTempsId;
  final String? type;

  SeanceDto({
    this.id,
    this.jour,
    this.heureDebut,
    this.heureFin,
    this.modulePromotionId,
    this.modulePromotionCode,
    this.modulePromotionLibelle,
    this.enseignantNomComplet,
    this.salleId,
    this.salleCode,
    this.emploiDuTempsId,
    this.type,
  });

  factory SeanceDto.fromJson(Map<String, dynamic> json) {
    return SeanceDto(
      id: json['id'],
      jour: json['jour'],
      heureDebut: json['heureDebut'],
      heureFin: json['heureFin'],
      modulePromotionId: json['modulePromotionId'],
      modulePromotionCode: json['modulePromotionCode'],
      modulePromotionLibelle: json['modulePromotionLibelle'],
      enseignantNomComplet: json['enseignantNomComplet'],
      salleId: json['salleId'],
      salleCode: json['salleCode'],
      emploiDuTempsId: json['emploiDuTempsId'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jour': jour,
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'modulePromotionId': modulePromotionId,
      'modulePromotionCode': modulePromotionCode,
      'modulePromotionLibelle': modulePromotionLibelle,
      'enseignantNomComplet': enseignantNomComplet,
      'salleId': salleId,
      'salleCode': salleCode,
      'emploiDuTempsId': emploiDuTempsId,
      'type': type,
    };
  }
}
