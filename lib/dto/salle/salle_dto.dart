class SalleDto {
  final int id;
  final String code;
  final int capacite;
  final String type;
  final int blocId;
  final String? blocNom;

  SalleDto({
    required this.id,
    required this.code,
    required this.capacite,
    required this.type,
    required this.blocId,
    this.blocNom,
  });

  factory SalleDto.fromJson(Map<String, dynamic> json) {
    return SalleDto(
      id: json['id'],
      code: json['code'],
      capacite: json['capacite'],
      type: json['type'],
      blocId: json['blocId'],
      blocNom: json['blocNom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'capacite': capacite,
      'type': type,
      'blocId': blocId,
    };
  }
}
