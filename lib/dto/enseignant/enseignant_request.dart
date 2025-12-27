class EnseignantRequest {
  final String nom;
  final String prenom;
  final String email;
  final String? password; // Nullable pour la modification
  final String? specialite;
  final bool estChefDepartement;
  final DateTime? dateNominationChef;

  EnseignantRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    this.password,
    this.specialite,
    this.estChefDepartement = false,
    this.dateNominationChef,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'specialite': specialite,
      'estChefDepartement': estChefDepartement,
      'dateNominationChef': dateNominationChef?.toIso8601String().split(
        'T',
      )[0], // Format YYYY-MM-DD
    };

    // On n'envoie le mot de passe que s'il n'est pas vide
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    return data;
  }

  // Utile si vous voulez pré-remplir un formulaire à partir d'un objet existant
  factory EnseignantRequest.fromDto(Map<String, dynamic> json) {
    return EnseignantRequest(
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      specialite: json['specialite'],
      estChefDepartement: json['estChefDepartement'] ?? false,
      dateNominationChef: json['dateNominationChef'] != null
          ? DateTime.tryParse(json['dateNominationChef'])
          : null,
    );
  }
}
