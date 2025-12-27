import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EnvService {
  static String get apiUrl {
    try {
      return dotenv.env['VITE_API_URL'] ?? 'http://localhost:8080';
    } catch (e) {
      // Return default value if dotenv is not initialized
      return 'http://localhost:8080';
    }
  }

  static String get appTitle {
    try {
      return dotenv.env['VITE_APP_TITLE'] ?? 'Mon Application';
    } catch (e) {
      // Return default value if dotenv is not initialized
      return 'Mon Application';
    }
  }

  static Future<void> loadEnv() async {
    try {
      if (kIsWeb) {
        // For web, we need to handle differently
        print('Running on web - using default environment variables');
      } else {
        await dotenv.load(fileName: ".env");
      }
      print('Connexion à l\'API: $apiUrl');
    } catch (e) {
      print('Erreur lors du chargement du fichier .env: $e');
      // Use default values if .env file is not found
      print('Using default environment variables');
    }
  }
}
