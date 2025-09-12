import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static void init() {
    baseUrl = dotenv.env['API_BASE_URL']!;
  }

  // Base URL from .env
  static late final String baseUrl;

  // Auth endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';

  // Product endpoints
  static const String productsEndpoint = '/products';

  // Order endpoints
  static const String ordersEndpoint = '/orders';
  static const String myOrdersEndpoint = '/orders/me';

  // Admin endpoints
  static const String adminOrdersEndpoint = '/admin/orders';
  static const String adminLowStockEndpoint = '/admin/low-stock';

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentTypeHeader = 'Content-Type';
  static const String applicationJson = 'application/json';
}
