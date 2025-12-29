
class InscriptionDto {
  final int? id;
  final int? etudiantId;
  final String? etudiantNomComplet;
  final int? promotionId;
  final String? promotionCode;
  final bool redoublant;
  final int annee;

  InscriptionDto({
    this.id,
    this.etudiantId,
    this.etudiantNomComplet,
    this.promotionId,
    this.promotionCode,
    required this.redoublant,
    required this.annee,
  });

  factory InscriptionDto.fromJson(Map<String, dynamic> json) {
    return InscriptionDto(
      id: json['id'],
      etudiantId: json['etudiantId'],
      etudiantNomComplet: json['etudiantNomComplet'],
      promotionId: json['promotionId'],
      promotionCode: json['promotionCode'],
      redoublant: json['redoublant'] ?? false,
      annee: json['annee'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'etudiantId': etudiantId,
      'etudiantNomComplet': etudiantNomComplet,
      'promotionId': promotionId,
      'promotionCode': promotionCode,
      'redoublant': redoublant,
      'annee': annee,
    };
  }
}
