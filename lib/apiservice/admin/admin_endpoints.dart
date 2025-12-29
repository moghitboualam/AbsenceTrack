class AdminEndpoints {
  // ===========================================================================
  // ETUDIANT
  // ===========================================================================
  static const String etudiantBase = '/admin/etudiants';
  static const String etudiantGetAll = etudiantBase;
  static const String etudiantCreate = etudiantBase;
  static const String etudiantSansInscription =
      '$etudiantBase/sans-inscription';
  static const String etudiantImportExcel = '$etudiantBase/import';

  static String etudiantGetById(dynamic id) => '$etudiantBase/$id';
  static String etudiantUpdate(dynamic id) => '$etudiantBase/$id';
  static String etudiantDelete(dynamic id) => '$etudiantBase/$id';
  static String etudiantGetByClasse(dynamic classeId) =>
      '$etudiantBase/$classeId/etudiants';
  // ===========================================================================
  // DEPARTEMENT
  // ===========================================================================
  static const String departementBase = '/admin/departements';
  static const String departementGetAll = departementBase;
  static const String departementCreate = departementBase;
  static String departementGetById(dynamic id) => '$departementBase/$id';
  static String departementUpdate(dynamic id) => '$departementBase/$id';
  static String departementDelete(dynamic id) => '$departementBase/$id';
  
  // ===========================================================================
  // ENSEIGNANT
  // ===========================================================================
  static const String enseignantBase = '/admin/enseignants';
  static const String enseignantGetAll = enseignantBase;

  static String enseignantGetById(dynamic id) => '$enseignantBase/$id';
  static String enseignantAssignChef(dynamic id) =>
      '$enseignantBase/$id/assign-chef';

  // ===========================================================================
  // FILIERE & MODULE
  // ===========================================================================
  static const String filiereBase = '/admin/filieres';
  static const String filiereGetAll = filiereBase;
  static const String filiereCreate = filiereBase;
  static String filiereGetById(dynamic id) => '$filiereBase/$id';
  static String filiereUpdate(dynamic id) => '$filiereBase/$id';
  static String filiereDelete(dynamic id) => '$filiereBase/$id';

  static const String moduleBase = '/admin/modules';
  static const String moduleGetAll = moduleBase;
  static const String moduleCreate = moduleBase;
  static String moduleGetById(dynamic id) => '$moduleBase/$id';
  static String moduleUpdate(dynamic id) => '$moduleBase/$id';
  static String moduleDelete(dynamic id) => '$moduleBase/$id';

  // ===========================================================================
  // CLASSES
  // ===========================================================================
  static const String classesBase = '/admin/classess';
  static String classesGetById(dynamic id) => '$classesBase/$id';
  static String classesByPromotion(dynamic promotionId) =>
      '$classesBase/byPromotion/$promotionId';
  static String classesAssignStudents(dynamic promotionId) =>
      '$classesBase/assign-students/$promotionId';

  // ===========================================================================
  // SEMESTRES & ANNEE UNIVERSITAIRE
  // ===========================================================================
  static const String semestreBase = '/admin/semestres';
  static String semestreGetByAcademicYear(dynamic id) =>
      '$semestreBase/annee-universitaire/$id';
  static String semestreGenerate(dynamic id) => '$semestreBase/generate/$id';

  static const String anneeUnivBase = '/admin/annees-universitaires';
  static String anneeUnivByYear(String annee) =>
      '$anneeUnivBase/by-annee/$annee';

  // ===========================================================================
  // SALLES & BLOCS
  // ===========================================================================
  static const String salleBase = '/admin/salles';
  static const String salleFilter = '$salleBase/filter';
  static String salleGetById(dynamic id) => '$salleBase/$id';

  static const String blocBase = '/admin/blocs';

  // ===========================================================================
  // PROMOTIONS
  // ===========================================================================
  static const String promotionBase = '/admin/promotions';
  static const String promotionGetAll = promotionBase;
  static const String promotionCreate = promotionBase;
  static String promotionGetById(dynamic id) => '$promotionBase/$id';
  static String promotionUpdate(dynamic id) => '$promotionBase/$id';
  static String promotionDelete(dynamic id) => '$promotionBase/$id';

  static String promotionByFiliere(dynamic id) =>
      '$promotionBase/byFiliere/$id';
  static String promotionByAnnee(dynamic id) =>
      '$promotionBase/byAnneeUniversitaire/$id';

  // ===========================================================================
  // MODULE PROMOTION (Logique de liaison)
  // ===========================================================================
  static const String modulePromoBase = '/admin/module-promotions';

  static String modulePromoGenerate(dynamic promoId) =>
      '$modulePromoBase/promotion/$promoId';

  static String modulePromoByPromoAndSemestre(dynamic promoId, dynamic semId) =>
      '$modulePromoBase/promotion/$promoId/semestre/$semId';

  static String modulePromoAssignEnseignant(dynamic modulePromoId) =>
      '$modulePromoBase/$modulePromoId/assign-enseignant';

  // ===========================================================================
  // EMPLOI DU TEMPS
  // ===========================================================================
  static const String edtBase = '/admin/emploidutemps';
  static const String edtGetAll = edtBase;
  static const String edtCreate = edtBase;
  static String edtUpdate(dynamic id) => '$edtBase/$id';
  static String edtDelete(dynamic id) => '$edtBase/$id';

  static const String edtSeanceAdd = '$edtBase/seances';

  static String edtGetById(dynamic id) => '$edtBase/$id';
  static String edtUpdateSeance(dynamic seanceId) =>
      '$edtBase/seances/$seanceId';
  static String edtDeleteSeance(dynamic seanceId) =>
      '$edtBase/seances/$seanceId';
  static String edtGenerate(dynamic classeId, dynamic semId) =>
      '$edtBase/generate/$classeId/$semId';
  static String edtDownloadPdf(dynamic id) => '$edtBase/$id/pdf';
}
