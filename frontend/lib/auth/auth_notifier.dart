import 'package:flutter/material.dart';
import 'package:frontend/service/service.dart';
import 'package:frontend/model/user_model.dart';

class AuthNotifier extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthNotifier() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoggedIn = await _apiService.isLoggedIn();

    if (_isLoggedIn) {
      _user = await _apiService.getCurrentUser();
    } else {
      _user = null;
    }
    _isLoading = false;
    notifyListeners(); // Tells GoRouter to re-evaluate redirects
  }

  Future<void> login(String email, String password) async {
    _user = await _apiService.login(email, password);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
