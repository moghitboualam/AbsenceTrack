class AnneeUniversitaireDto {
  final int id;
  final String annee;

  AnneeUniversitaireDto({
    required this.id,
    required this.annee,
  });

  factory AnneeUniversitaireDto.fromJson(Map<String, dynamic> json) {
    return AnneeUniversitaireDto(
      id: json['id'],
      annee: json['annee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'annee': annee,
    };
  }
}
