import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
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

  User? _buildUserFromTokenPayload(Map<String, dynamic> payload) {
    final dynamic rawEmail = payload['email'] ?? payload['sub'] ?? payload['user_name'];
    final String? email = rawEmail?.toString();

    String? detectedRole;
    final dynamic roleClaim = payload['role'];
    final dynamic rolesClaim = payload['roles'] ?? payload['authorities'] ?? payload['scope'];

    bool hasAdminSignal(dynamic value) {
      if (value == null) return false;
      if (value is String) {
        final v = value.toLowerCase();
        return v.contains('admin');
      }
      if (value is List) {
        return value.any((e) => e.toString().toLowerCase().contains('admin'));
      }
      return false;
    }

    if (hasAdminSignal(roleClaim) || hasAdminSignal(rolesClaim)) {
      detectedRole = 'admin';
    } else {
      detectedRole = 'user';
    }

    final dynamic rawId = payload['userId'] ?? payload['id'] ?? payload['uid'];
    final String id = (rawId ?? '').toString();

    if (email == null || email.isEmpty) return null;

    return User(
      id: id.isEmpty ? email : id,
      email: email,
      role: detectedRole,
    );
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);

    if (_token != null) {
      _apiService.setToken(_token!);
      final userJson = prefs.getString(AppConstants.userKey);
      if (userJson != null) {
        try {
          final userMap = json.decode(userJson) as Map<String, dynamic>;
          _currentUser = User.fromJson(userMap);
        } catch (e) {
          await prefs.remove(AppConstants.userKey);
          _currentUser = null;
        }
      }

      if (_currentUser == null) {
        final payload = _decodeJwtPayload(_token!);
        debugPrint('[AuthService] init: jwt payload=$payload');
        if (payload != null) {
          final derivedUser = _buildUserFromTokenPayload(payload);
          if (derivedUser != null) {
            _currentUser = derivedUser;
            await prefs.setString(AppConstants.userKey, json.encode(_currentUser!.toJson()));
          }
        }
      }

      await _probeAndSetAdminIfAllowed();

      debugPrint('[AuthService] init: email=${_currentUser?.email} role=${_currentUser?.role} isAdmin=$isAdmin');
    }
  }
}
