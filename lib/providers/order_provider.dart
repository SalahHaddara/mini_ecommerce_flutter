import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Order> _myOrders = [];
  List<Order> _allOrders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get myOrders => List.unmodifiable(_myOrders);
  List<Order> get allOrders => List.unmodifiable(_allOrders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createOrder(List<Map<String, dynamic>> items) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newOrder = await _apiService.createOrder(items);
      _myOrders.insert(0, newOrder); // Add to beginning of list
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myOrders = await _apiService.getMyOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allOrders = await _apiService.getAllOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refreshMyOrders() {
    loadMyOrders();
  }

  void refreshAllOrders() {
    loadAllOrders();
  }
}
