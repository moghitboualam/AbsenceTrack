class SemestreDto {
  final int? id;
  final String? num; // S1, S2...
  final String? anneeUniv;

  SemestreDto({this.id, this.num, this.anneeUniv});

  factory SemestreDto.fromJson(Map<String, dynamic> json) {
    return SemestreDto(
      id: json['id'],
      num: json['num'],
      anneeUniv: json['anneeUniv'],
    );
  }
}
