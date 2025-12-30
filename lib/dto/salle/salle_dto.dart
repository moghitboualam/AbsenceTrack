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
      id: json['id'] ?? 0,
      code: json['code'] ?? 'Unknown',
      capacite: json['capacite'] ?? 0,
      type: json['type'] ?? 'Standard',
      blocId: json['blocId'] ?? 0,
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
