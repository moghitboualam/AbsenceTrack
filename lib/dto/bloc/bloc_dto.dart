class BlocDto {
  final int id;
  final String nom;
  final String localisation;

  BlocDto({
    required this.id,
    required this.nom,
    required this.localisation,
  });

  factory BlocDto.fromJson(Map<String, dynamic> json) {
    return BlocDto(
      id: json['id'],
      nom: json['nom'],
      localisation: json['localisation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'localisation': localisation,
    };
  }
}
