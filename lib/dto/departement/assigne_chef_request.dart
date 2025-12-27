class AssignChefRequest {
  final int departementId;
  final bool estChefDepartement;
  final int enseignantId;
  final DateTime dateNominationChef;

  AssignChefRequest({
    required this.departementId,
    required this.estChefDepartement,
    required this.enseignantId,
    required this.dateNominationChef,
  });

  Map<String, dynamic> toJson() {
    return {
      'departementId': departementId,
      'estChefDepartement': estChefDepartement,
      'enseignantId': enseignantId,
      'dateNominationChef': dateNominationChef.toIso8601String(),
    };
  }
}
