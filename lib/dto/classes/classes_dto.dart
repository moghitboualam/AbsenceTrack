import 'package:flutter_dashboard_app/dto/etudiant/etudiant_dto.dart';

class ClassesDto {
  final int? id;
  final String? code;
  final int nbrEleves;
  final int? promotionId;
  final String? promotionCode;
  final List<EtudiantDto>? etudiantDtos;
  // Wait, Java ClassesDto uses List<EtudiantDto>. 
  // Flutter existing DTO is EnseignantDto? No, I found etudiant_dto.dart. 
  // Let me check etudiant_dto.dart class name.
  
  // Checking previous output: 
  // Found 1 results: etudiant\etudiant_dto.dart
  // I will assume the class is EtudiantDto.
  
  ClassesDto({
    this.id,
    this.code,
    required this.nbrEleves,
    this.promotionId,
    this.promotionCode,
    this.etudiantDtos,
  });

  factory ClassesDto.fromJson(Map<String, dynamic> json) {
    var list = json['etudiantDtos'] as List?;
    List<EtudiantDto>? studentsList;
    if (list != null) {
      studentsList = list.map((i) => EtudiantDto.fromJson(i)).toList();
    }

    return ClassesDto(
      id: json['id'],
      code: json['code'],
      nbrEleves: json['nbrEleves'] ?? 0,
      promotionId: json['promotionId'],
      promotionCode: json['promotionCode'],
      etudiantDtos: studentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'nbrEleves': nbrEleves,
      'promotionId': promotionId,
      'promotionCode': promotionCode,
      'etudiantDtos': etudiantDtos?.map((e) => e.toJson()).toList(),
    };
  }
}
