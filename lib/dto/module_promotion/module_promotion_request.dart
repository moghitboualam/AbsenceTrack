class ModulePromotionRequest {
  final String code;
  final int moduleReferenceId;
  final int semestreId;
  final int? enseignantResponsableId;
  final int promotionId;

  ModulePromotionRequest({
    required this.code,
    required this.moduleReferenceId,
    required this.semestreId,
    this.enseignantResponsableId,
    required this.promotionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'moduleReferenceId': moduleReferenceId,
      'semestreId': semestreId,
      'enseignantResponsableId': enseignantResponsableId,
      'promotionId': promotionId,
    };
  }
}
