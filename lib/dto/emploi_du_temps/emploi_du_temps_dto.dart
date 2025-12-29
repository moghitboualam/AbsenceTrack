import 'package:flutter_dashboard_app/dto/seance/seance_dto.dart';

class EmploiDuTempsDto {
  final int? id;
  final String? nom;
  final int? classeId;
  final int? promotionId;
  final String? classeCode;
  final int? semestreId;
  final String? semestreNum;
  final List<SeanceDto>? seanceDtos;

  EmploiDuTempsDto({
    this.id,
    this.nom,
    this.classeId,
    this.promotionId,
    this.classeCode,
    this.semestreId,
    this.semestreNum,
    this.seanceDtos,
  });

  factory EmploiDuTempsDto.fromJson(Map<String, dynamic> json) {
    var seanceList = json['seanceDtos'] as List?;
    List<SeanceDto>? seances;
    if (seanceList != null) {
      seances = seanceList.map((e) => SeanceDto.fromJson(e)).toList();
    }

    return EmploiDuTempsDto(
      id: json['id'],
      nom: json['nom'],
      classeId: json['classeId'],
      promotionId: json['promotionId'],
      classeCode: json['classeCode'],
      semestreId: json['semestreId'],
      semestreNum: json['semestreNum'],
      seanceDtos: seances,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'classeId': classeId,
      'promotionId': promotionId,
      'classeCode': classeCode,
      'semestreId': semestreId,
      'semestreNum': semestreNum,
      'seanceDtos': seanceDtos?.map((e) => e.toJson()).toList(),
    };
  }
}
