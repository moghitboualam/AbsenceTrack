class FiliereRequest {
  final String? code;
  final String? libelle;
  final int? dureeAnnees;
  final String? semistere;
  final int? departementId;
  final int? chefFiliereId;

  FiliereRequest({
    this.code,
    this.libelle,
    this.dureeAnnees,
    this.semistere,
    this.departementId,
    this.chefFiliereId,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'libelle': libelle,
      'dureeAnnees': dureeAnnees,
      'semistere': semistere,
      'departementId': departementId,
      'chefFiliereId': chefFiliereId,
    };
  }
}
