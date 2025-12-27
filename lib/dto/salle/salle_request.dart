class SalleRequest {
  final String code;
  final int capacite;
  final String type;
  final int blocId;

  SalleRequest({
    required this.code,
    required this.capacite,
    required this.type,
    required this.blocId,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'capacite': capacite,
      'type': type,
      'blocId': blocId,
    };
  }
}
