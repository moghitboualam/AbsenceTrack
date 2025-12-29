import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _loading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _user != null;
  bool get loading => _loading;
  String? get error => _error;

  // Initialisation au démarrage de l'app
  Future<void> initializeAuth() async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final storedUser = prefs.getString('user');

    if (storedToken != null && storedUser != null) {
      try {
        _user = User.fromJson(json.decode(storedUser));
        _token = storedToken;
      } catch (e) {
        await _clearStoredAuth();
      }
    }
    _loading = false;
    notifyListeners();
  }

  // Méthode de Login
  Future<User?> login(String username, String password) async {
    _error = null;
    _loading = true;
    notifyListeners();
    // print('Tentative de connexion pour l\'utilirsateur: $username');
    print('Avec le mot de passe: $password');
    print('username $username');
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      final data = response.data;

      print(data);

      // Normalisation comme dans ton React
      final userData = User(
        role: data['role'].toString().toLowerCase(),
        email: data['email'] ?? username,
        name: data['nom'],
        prenom: data['prenom'],
      );

      _user = userData;
      _token = data['access_token'];

      // Persistance
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      if (data['refresh_token'] != null) {
        await prefs.setString('refreshToken', data['refresh_token']);
      }
      await prefs.setString('user', json.encode(userData.toJson()));

      _loading = false;
      notifyListeners();
      return userData;
    } catch (err) {
      _error = "Identifiants invalides ou erreur serveur";
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get the appropriate home route based on user role
  String getHomeRoute() {
    if (_user?.role == 'admin') {
      return '/espace-employe/admin';
    } else if (_user?.role == 'enseignant') {
      return '/enseignant';
    } else if (_user?.role == 'etudiant') {
      return '/etudiant';
    } else {
      return '/login';
    }
  }

  Future<void> logout() async {
    await _clearStoredAuth();
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
