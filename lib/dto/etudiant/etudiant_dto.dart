class EtudiantDto {
  final int? id;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? numCarte;
  final String? codeMassar;
  final int? classeId;
  final String? classeNom;

  EtudiantDto({
    this.id,
    this.nom,
    this.prenom,
    this.email,
    this.numCarte,
    this.codeMassar,
    this.classeId,
    this.classeNom,
  });

  factory EtudiantDto.fromJson(Map<String, dynamic> json) {
    return EtudiantDto(
      id: json['id'] as int?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      numCarte: json['numCarte'] as String?,
      codeMassar: json['codeMassar'] as String?,
      classeId: json['classeId'] as int?,
      classeNom: json['classeNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'numCarte': numCarte,
      'codeMassar': codeMassar,
      'classeId': classeId,
      'classeNom': classeNom,
    };
  }
}
