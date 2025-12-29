import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio dio;
  final String baseUrl =
      "http://localhost:8080/api/v1"; // Utilise ton EnvService ici

  String _getBaseUrl() {
    // 1. Priorité à la variable d'environnement (pour tunnel Ngrok ou Prod)
    final envUrl = dotenv.env['API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8080/api/v1'; // Web
    } else if (Platform.isAndroid) {
      // Pour l'émulateur Android standard
      return 'http://10.0.2.2:8080/api/v1';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080/api/v1'; // Simulateur iOS
    }
    return 'http://localhost:8080/api/v1';
  }

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    // AJOUT DES INTERCEPTEURS (Équivalent de withForbiddenHandler)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if ((e.response?.statusCode == 401 ||
                  e.response?.statusCode == 403) &&
              e.requestOptions.extra['retry'] != true) {
            // Logique de Refresh Token
            bool refreshed = await _handleTokenRefresh();

            if (refreshed) {
              // Re-tenter la requête initiale
              e.requestOptions.extra['retry'] = true;
              final prefs = await SharedPreferences.getInstance();
              final newToken = prefs.getString('token');
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> _handleTokenRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      if (refreshToken == null) return false;

      // Appel au refresh (adapte l'URL à ton backend Spring Boot)
      final response = await Dio().post(
        "$baseUrl/auth/refresh",
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await prefs.setString('token', response.data['access_token']);
        if (response.data['refresh_token'] != null) {
          await prefs.setString('refreshToken', response.data['refresh_token']);
        }
        return true;
      }
    } catch (e) {
      // Si le refresh échoue, on déconnecte
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
    return false;
  }
}
