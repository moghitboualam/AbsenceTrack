class EmploiDuTempsRequest {
  final String? nom;
  final int? classeId;
  final int? semestreId;

  EmploiDuTempsRequest({
    this.nom,
    this.classeId,
    this.semestreId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'classeId': classeId,
      'semestreId': semestreId,
    };
  }
}
