class EtudiantRequest {
  final String nom;
  final String prenom;
  final String email;
  final String? password; // Peut être null en édition
  final String numCarte;
  final String codeMassar;
  final int? classeId;

  EtudiantRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    this.password,
    required this.numCarte,
    required this.codeMassar,
    this.classeId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'numCarte': numCarte,
      'codeMassar': codeMassar,
      'classeId': classeId,
    };
    // On n'envoie le mot de passe que s'il est renseigné
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    return data;
  }
}
