class SemestreDto {
  final int? id;
  final String? num; // S1, S2...
  final String? anneeUniv;
  final int? anneeUniversitaireId;

  SemestreDto({this.id, this.num, this.anneeUniv, this.anneeUniversitaireId});

  factory SemestreDto.fromJson(Map<String, dynamic> json) {
    return SemestreDto(
      id: json['id'],
      num: json['num'],
      anneeUniv: json['anneeUniv'],
      anneeUniversitaireId: json['anneeUniversitaireId'],
    );
  }
}
