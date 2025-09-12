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

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw Exception('Expected a Map but got \\${decoded.runtimeType}: \\${decoded.toString()}');
      }
    } else if (response.statusCode == 401) {
      clearToken();
      throw Exception('Unauthorized - Please login again');
    } else {
      final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {'message': 'Unknown error occurred'};
      throw Exception(errorBody['message'] ?? 'Request failed');
    }
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    return await _handleResponse(response);
  }

  // Product endpoints
  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}'),
      headers: _headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: \\${response.body}');
    }
  }
}
