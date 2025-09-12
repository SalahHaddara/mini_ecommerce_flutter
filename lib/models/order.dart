import 'product.dart';

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      productId: json['productId'].toString(),
      productName: json['productName'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'],
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  // Legacy getter for backward compatibility
  double get price => unitPrice;
  double get totalPrice => subtotal;

  String get formattedPrice {
    return '\$${unitPrice.toStringAsFixed(2)}';
  }

  String get formattedTotalPrice {
    return '\$${subtotal.toStringAsFixed(2)}';
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> orderItems;
  final double total;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.orderItems,
    required this.total,
    required this.createdAt,
    this.updatedAt,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      orderItems: (json['orderItems'] as List? ?? []).map((item) => OrderItem.fromJson(item)).toList(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: json['status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
    };
  }

  // Legacy getter for backward compatibility
  List<OrderItem> get items => orderItems;

  String get formattedTotal {
    return '\$${total.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
