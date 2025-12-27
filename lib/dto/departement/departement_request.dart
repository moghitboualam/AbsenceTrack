class DepartementRequest {
  final String code;
  final String libelle;

  DepartementRequest({required this.code, required this.libelle});

  // Méthode pour convertir l'objet en JSON (pour l'envoyer au backend)
  Map<String, dynamic> toJson() {
    return {'code': code, 'libelle': libelle};
  }

  // Factory utile si vous avez besoin de pré-remplir depuis un JSON
  factory DepartementRequest.fromJson(Map<String, dynamic> json) {
    return DepartementRequest(
      code: json['code'] ?? '',
      libelle: json['libelle'] ?? '',
    );
  }
}
