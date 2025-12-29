class ClassesRequest {
  final String code;
  final int nbrEleves;
  final int promotionId;

  ClassesRequest({
    required this.code,
    required this.nbrEleves,
    required this.promotionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'nbrEleves': nbrEleves,
      'promotionId': promotionId,
    };
  }
}
