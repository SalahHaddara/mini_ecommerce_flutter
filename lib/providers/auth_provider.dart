import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get user => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isAdmin => _authService.isAdmin;
  bool get isLoading => _isLoading;

  bool _isLoading = false;
  String? _error;

  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.initialize();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
