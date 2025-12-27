class EnseignantDto {
  final int? id;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? role;
  final String? specialite;
  final bool estChefDepartement;
  final DateTime? dateNominationChef;

  final int? departementId;

  EnseignantDto({
    this.id,
    this.nom,
    this.prenom,
    this.email,
    this.role,
    this.specialite,
    this.estChefDepartement = false,
    this.dateNominationChef,
    this.departementId,
  });

  // Factory pour créer l'objet depuis le JSON (Lecture)
  factory EnseignantDto.fromJson(Map<String, dynamic> json) {
    return EnseignantDto(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
      specialite: json['specialite'],
      estChefDepartement: json['estChefDepartement'] ?? false,
      dateNominationChef: json['dateNominationChef'] != null
          ? DateTime.tryParse(json['dateNominationChef'])
          : null,
      departementId: json['departementId'],
    );
  }

  // --- MÉTHODE AJOUTÉE : toJson (Écriture) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
      'specialite': specialite,
      'estChefDepartement': estChefDepartement,
      'dateNominationChef': dateNominationChef?.toIso8601String(),
      'departementId': departementId,
    };
  }
}
