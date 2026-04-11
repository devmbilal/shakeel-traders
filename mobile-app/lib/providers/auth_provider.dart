import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  int? _userId;
  String? _role;
  String? _userName;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  int? get userId => _userId;
  String? get role => _role;
  String? get userName => _userName;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;
  bool get isOrderBooker => _role == AppConstants.roleOrderBooker;
  bool get isSalesman => _role == AppConstants.roleSalesman;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.keyJwt);
    _userId = prefs.getInt(AppConstants.keyUserId);
    _role = prefs.getString(AppConstants.keyUserRole);
    _userName = prefs.getString(AppConstants.keyUserName);
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.login(username, password);
      _token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>;
      _userId = user['id'] as int;
      _role = user['role'] as String;
      _userName = user['full_name'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyJwt, _token!);
      await prefs.setInt(AppConstants.keyUserId, _userId!);
      await prefs.setString(AppConstants.keyUserRole, _role!);
      await prefs.setString(AppConstants.keyUserName, _userName!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _role = null;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyJwt);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyUserName);
    notifyListeners();
  }
}
