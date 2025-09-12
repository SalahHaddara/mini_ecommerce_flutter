import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/order.dart';
import '../models/product.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = {
      ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
    };

    if (_token != null) {
      headers[ApiConstants.authorizationHeader] = '${ApiConstants.bearerPrefix}$_token';
    }

    return headers;
  }
}
