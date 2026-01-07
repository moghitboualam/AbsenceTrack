import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/pages/admin/etudiant/etudiant_form_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Vos imports existants...
import 'services/env_service.dart';
import 'services/auth_service.dart';
import 'layouts/dashboard_layout.dart';
import 'pages/auth/login_page.dart';
import 'pages/admin/admin_home.dart';
import 'pages/admin/enseignant/enseignant_list_page.dart';
import 'pages/admin/enseignant/enseignant_form_page.dart';
import 'pages/admin/etudiant/etudiant_list_page.dart'; // Vérifiez ce chemin
import 'pages/admin/departement/departement_list_page.dart';
import 'pages/admin/departement/departement_form_page.dart';
import 'pages/admin/departement/departement_details_page.dart';
import 'pages/admin/bloc/bloc_list_page.dart';
import 'pages/admin/bloc/bloc_form_page.dart';
import 'pages/admin/salle/salle_list_page.dart';
import 'pages/admin/salle/salle_form_page.dart';
import 'pages/admin/filiere/filiere_list_page.dart';
import 'pages/admin/filiere/filiere_form_page.dart';
import 'pages/admin/module/module_list_page.dart';
import 'pages/admin/module/module_form_page.dart';
import 'pages/admin/promotion/promotion_list_page.dart';
import 'pages/admin/promotion/promotion_form_page.dart';
import 'pages/admin/classes/promotion_classes_page.dart';
import 'pages/admin/inscription/promotion_inscriptions_page.dart';
import 'pages/admin/module_promotion/module_promotion_list_page.dart';
import 'pages/etudiant/etudiant_dashboard_page.dart';
import 'pages/etudiant/emploi_du_temps_list_page.dart';
import 'pages/etudiant/emploi_du_temps_detail_page.dart';
import 'pages/etudiant/emploi_du_temps_pdf_view_page.dart';
import 'pages/etudiant/emploi_du_temps_pdf_view_page.dart';
import 'pages/etudiant/mes_absences_page.dart';
import 'pages/etudiant/mes_seances_page.dart';
import 'pages/etudiant/mes_justifications_page.dart';
import 'pages/enseignant/enseignant_dashboard_page.dart';
import 'pages/enseignant/emploi_du_temps_page.dart';
import 'pages/enseignant/enseignant_mes_seances_page.dart';
import 'pages/enseignant/justification_management_page.dart';
import 'pages/enseignant/enseignant_seance_detail_page.dart';

import 'pages/admin/emploi_du_temps/emploi_du_temps_list_page.dart';
import 'pages/admin/emploi_du_temps/emploi_du_temps_form_page.dart';
import 'pages/admin/emploi_du_temps/emploi_du_temps_manage_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.loadEnv();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService()..initializeAuth(), // On lance l'init ici
      child: const MyApp(),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // On déclare le router comme 'late' mais on l'initialise une seule fois
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    final authService = Provider.of<AuthService>(context, listen: false);

    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: authService,
      debugLogDiagnostics: true, // Verification debug
      redirect: (context, state) {
        // 1. Si l'auth charge encore
        if (authService.loading) return null;

        final bool loggedIn = authService.isAuthenticated;
        final bool isLoggingIn = state.matchedLocation == '/login';

        // 2. Si non connecté et pas sur login -> Login
        if (!loggedIn && !isLoggingIn) return '/login';

        // 3. Si connecté et sur login -> Accueil
        if (loggedIn && isLoggingIn) {
          final route = authService.getHomeRoute();
          print("Redirecting to Home Route: '$route'"); // Debug print
          return route;
        }

        // 4. Vérification des Rôles
        if (loggedIn && authService.user != null) {
            final role = authService.user!.role;
            // ... (rest of logic same)
            if (state.matchedLocation.startsWith('/etudiant') && role != 'etudiant') {
                 print("Role mismatch! User role: $role, Path: ${state.matchedLocation}");
                 return authService.getHomeRoute();
            }
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        ShellRoute(
          builder: (context, state, child) => DashboardLayout(child: child),
          routes: [
            // --- ROUTES ADMIN ---
            GoRoute(
              path: '/espace-employe/admin', // Route d'accueil Admin
              builder: (context, state) => const AdminHomePage(),
            ),
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminHomePage(),
            ),
            GoRoute(
              path: '/admin/etudiants',
              builder: (context, state) => const EtudiantListPage(),
            ),
            // Route pour AJOUTER (/admin/etudiants/new)
            GoRoute(
              path:
                  '/admin/etudiant/new', // Notez l'absence de '/' au début pour une sous-route
              builder: (context, state) => const EtudiantFormPage(id: null),
            ),
            // Route pour MODIFIER (/admin/etudiants/edit/12)
            GoRoute(
              path: '/admin/etudiant/edit/:id',
              builder: (context, state) {
                // On récupère l'ID depuis l'URL
                final idStr = state.pathParameters['id'];
                final id = int.tryParse(idStr ?? '');
                return EtudiantFormPage(id: id);
              },
            ),
            GoRoute(
              path: '/admin/enseignants',
              builder: (context, state) => const EnseignantListPage(),
            ),
             GoRoute(
              path: '/admin/enseignants/new',
              builder: (context, state) => const EnseignantFormPage(id: null),
            ),
            GoRoute(
              path: '/admin/enseignants/edit/:id',
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final id = int.tryParse(idStr ?? '');
                return EnseignantFormPage(id: id);
              },
            ),
            GoRoute(
              path: '/admin/departements',
              builder: (context, state) => const DepartementListPage(),
            ),
            GoRoute(
              path: '/admin/departements/new',
              builder: (context, state) => const DepartementFormPage(id: null),
            ),
            GoRoute(
              path: '/admin/departements/edit/:id',
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final id = int.tryParse(idStr ?? '');
                return DepartementFormPage(id: id);
              },
            ),
             GoRoute(
              path: '/admin/departements/details/:id',
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final id = int.tryParse(idStr ?? '');
                // Handle invalid ID case if necessary
                 if (id == null) {
                    return const Scaffold(body: Center(child: Text("ID Invalide")));
                }
                return DepartementDetailsPage(id: id);
              },
            ),
            GoRoute(
              path: '/admin/filieres',
              builder: (context, state) => const FiliereListPage(),
            ),
            GoRoute(
              path: '/admin/filieres/new',
              builder: (context, state) => const FiliereFormPage(id: null),
            ),
            GoRoute(
              path: '/admin/filieres/edit/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return FiliereFormPage(id: id);
              },
            ),

            // --- ROUTE MODULES ---
            GoRoute(
              path: '/admin/modules',
              builder: (context, state) => const ModuleListPage(),
            ),
            GoRoute(
              path: '/admin/modules/new',
              builder: (context, state) => const ModuleFormPage(id: null),
            ),
            GoRoute(
              path: '/admin/modules/edit/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return ModuleFormPage(id: id);
              },
            ),

            // --- ROUTE PROMOTIONS ---
            GoRoute(
              path: '/admin/promotions',
              builder: (context, state) => const PromotionListPage(),
            ),
            GoRoute(
              path: '/admin/promotions/new',
              builder: (context, state) => const PromotionFormPage(id: null),
            ),
            GoRoute(
              path: '/admin/promotions/edit/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return PromotionFormPage(id: id);
              },
            ),
            GoRoute(
              path: '/admin/promotions/:id/classes',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                final code = state.extra as String?;
                if (id == null) return const Scaffold(body: Center(child: Text("ID Invalide")));
                return PromotionClassesPage(promotionId: id, promotionCode: code);
              },
            ),
            GoRoute(
              path: '/admin/promotions/:id/inscriptions',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                final code = state.extra as String?;
                if (id == null) return const Scaffold(body: Center(child: Text("ID Invalide")));
                return PromotionInscriptionsPage(promotionId: id, promotionCode: code);
              },
            ),

            // --- ROUTE MODULE PROMOTIONS (PLANIFICATION) ---
            GoRoute(
              path: '/admin/module-promotions',
              builder: (context, state) => const ModulePromotionListPage(),
            ),

            // --- ROUTE BLOCS ---
            GoRoute(
              path: '/admin/blocs',
              builder: (context, state) => const BlocListPage(),
            ),
            GoRoute(
              path: '/admin/blocs/new',
              builder: (context, state) => const BlocFormPage(),
            ),
            GoRoute(
              path: '/admin/blocs/edit/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return BlocFormPage(id: id);
              },
            ),

            GoRoute(
              path: '/admin/blocs/edit/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return BlocFormPage(id: id);
              },
            ),

             // --- ROUTE SALLES ---
            GoRoute(
              path: '/admin/salles',
              builder: (context, state) => const SalleListPage(),
            ),
            GoRoute(
              path: '/admin/salles/new',
              builder: (context, state) => const SalleFormPage(),
            ),
            GoRoute(
              path: '/admin/salles/edit/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return SalleFormPage(id: id);
              },
            ),

            // --- ROUTES ENSEIGNANT ---
            GoRoute(
              path: '/enseignant',
              builder: (context, state) => const EnseignantDashboardPage(),
            ),
            GoRoute(
              path: '/enseignant/edt',
              builder: (context, state) => const EnseignantEmploiDuTempsPage(),
            ),
            GoRoute(
              path: '/enseignant/seances',
              builder: (context, state) => const EnseignantMesSeancesPage(),
            ),
            GoRoute(
              path: '/enseignant/seances/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) {
                  return const Scaffold(body: Center(child: Text("ID Invalide")));
                }
                return EnseignantSeanceDetailPage(seanceId: id);
              },
            ),
            // GoRoute(
            //   path: '/enseignant/absences',
            //   builder: (context, state) => const EnseignantAbsencesPage(),
            // ),
            GoRoute(
              path: '/enseignant/justifications',
              builder: (context, state) {
                return JustificationManagementPage();
              },
            ),
            


            // --- ROUTES ADMIN EMPLOI DU TEMPS ---
            GoRoute(
              path: '/admin/emploi-du-temps',
              builder: (context, state) => const AdminEmploiDuTempsListPage(),
            ),
            GoRoute(
              path: '/admin/emploi-du-temps/new',
              builder: (context, state) => const AdminEmploiDuTempsFormPage(id: null),
            ),
            GoRoute(
              path: '/admin/emploi-du-temps/edit/:id',
              builder: (context, state) {
                 final id = int.tryParse(state.pathParameters['id'] ?? '');
                 return AdminEmploiDuTempsFormPage(id: id);
              },
            ),
            GoRoute(
              path: '/admin/emploi-du-temps/:id/manage',
              builder: (context, state) {
                 final id = int.tryParse(state.pathParameters['id'] ?? '');
                 return AdminEmploiDuTempsManagePage(id: id ?? 0);
              },
            ),

            // --- ROUTES ETUDIANT ---
            GoRoute(
              path: '/etudiant',
              builder: (context, state) => const EtudiantDashboardPage(),
            ),
            GoRoute(
              path: '/etudiant/emploi-du-temps',
              builder: (context, state) => const EmploiDuTempsListPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      EmploiDuTempsDetailPage(id: state.pathParameters['id']),
                ),
                GoRoute(
                  path: 'view-pdf/:id',
                  builder: (context, state) =>
                      EmploiDuTempsPdfViewPage(id: state.pathParameters['id']),
                ),
              ],
            ),
            GoRoute(
              path: '/etudiant/absences',
              builder: (context, state) => const MesAbsencesPage(),
            ),
            GoRoute(
              path: '/etudiant/seances',
              builder: (context, state) => const MesSeancesPage(),
            ),
            GoRoute(
              path: '/etudiant/justifications',
              builder: (context, state) => const MesJustificationsPage(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text("Page introuvable")),
        body: Center(
          child: Text("Erreur : La page ${state.uri.path} n'existe pas."),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CRUCIAL : On écoute l'état de l'auth ici
    final authService = context.watch<AuthService>();

    // Si l'authentification est en cours de chargement (vérification du token),
    // on affiche un écran de chargement simple au lieu du routeur.
    if (authService.loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // 1. On remplace ShadApp.router par MaterialApp.router
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // 2. La clé fonctionne ici car c'est un paramètre natif de MaterialApp
      scaffoldMessengerKey: rootScaffoldMessengerKey,

      routerConfig: _router,

      // 3. On injecte le thème Shadcn via le builder
      builder: (context, child) {
        return ShadTheme(
          data: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadZincColorScheme.light(),
          ),
          // On enveloppe le contenu de l'app (child) avec le thème
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
