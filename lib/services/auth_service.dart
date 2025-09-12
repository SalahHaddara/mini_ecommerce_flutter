import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  final ApiService _apiService = ApiService();
  User? _currentUser;
  String? _token;
  bool _isAdminOverride = false;

  User? get currentUser => _currentUser;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  bool get isAdmin => _currentUser?.isAdmin ?? _isAdminOverride;

  Future<void> _probeAndSetAdminIfAllowed() async {
    if (_token == null) return;

    if (_currentUser?.role != null && _currentUser!.role!.isNotEmpty) return;
    try {
      await _apiService.getAllOrders();
      _isAdminOverride = true;
    } catch (e) {
      debugPrint('[AuthService] admin probe failed: $e');
      _isAdminOverride = false;
    }
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64.decode(payload));
      final map = json.decode(decoded);
      if (map is Map<String, dynamic>) return map;
      return null;
    } catch (_) {
      return null;
    }
  }
}
