class User {
  final String? role;
  final String? email;
  final String? name;
  final String? prenom;

  User({this.role, this.email, this.name, this.prenom});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      role: json['role'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      prenom: json['prenom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'email': email, 'name': name, 'prenom': prenom};
  }

  User copyWith({String? role, String? email, String? name, String? prenom}) {
    return User(
      role: role ?? this.role,
      email: email ?? this.email,
      name: name ?? this.name,
      prenom: prenom ?? this.prenom,
    );
  }
}
