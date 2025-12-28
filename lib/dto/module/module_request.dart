class ModuleRequest {
  final String libelle;
  final int volumeHoraire;
  final int semestreReferenceId;
  final int filiereId;

  ModuleRequest({
    required this.libelle,
    required this.volumeHoraire,
    required this.semestreReferenceId,
    required this.filiereId,
  });

  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'volumeHoraire': volumeHoraire,
      'semestreReferenceId': semestreReferenceId,
      'filiereId': filiereId,
    };
  }
}
