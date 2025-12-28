class ModulePromotionDto {
  final int id;
  final String code;
  final int? moduleReferenceId;
  final String? moduleReferenceNom;
  final int? semestreId;
  final String? semestreNom;
  final int? enseignantResponsableId;
  final String? enseignantResponsableNomComplet;
  final int? promotionId;
  final String? promotionCode;

  ModulePromotionDto({
    required this.id,
    required this.code,
    this.moduleReferenceId,
    this.moduleReferenceNom,
    this.semestreId,
    this.semestreNom,
    this.enseignantResponsableId,
    this.enseignantResponsableNomComplet,
    this.promotionId,
    this.promotionCode,
  });

  factory ModulePromotionDto.fromJson(Map<String, dynamic> json) {
    return ModulePromotionDto(
      id: json['id'],
      code: json['code'],
      moduleReferenceId: json['moduleReferenceId'],
      moduleReferenceNom: json['moduleReferenceNom'],
      semestreId: json['semestreId'],
      semestreNom: json['semestreNom'],
      enseignantResponsableId: json['enseignantResponsableId'],
      enseignantResponsableNomComplet: json['enseignantResponsableNomComplet'],
      promotionId: json['promotionId'],
      promotionCode: json['promotionCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'moduleReferenceId': moduleReferenceId,
      'moduleReferenceNom': moduleReferenceNom,
      'semestreId': semestreId,
      'semestreNom': semestreNom,
      'enseignantResponsableId': enseignantResponsableId,
      'enseignantResponsableNomComplet': enseignantResponsableNomComplet,
      'promotionId': promotionId,
      'promotionCode': promotionCode,
    };
  }
}
