import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EnvService {
  static String get apiUrl {
    try {
      return dotenv.env['API_URL'] ?? 'http://localhost:8080';
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
      } else {
        await dotenv.load(fileName: ".env");
      }
    } catch (e) {
      // Use default values if .env file is not found
    }
  }
}
