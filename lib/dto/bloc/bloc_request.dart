class BlocRequest {
  final String nom;
  final String localisation;

  BlocRequest({
    required this.nom,
    required this.localisation,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'localisation': localisation,
    };
  }
}
