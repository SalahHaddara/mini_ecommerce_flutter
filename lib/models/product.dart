class Product {
  final String id;
  final String name;
  final double price; // Price in dollars
  final int stock;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool outOfStock;
  final bool lowStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.outOfStock = false,
    this.lowStock = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      outOfStock: json['outOfStock'] ?? false,
      lowStock: json['lowStock'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'outOfStock': outOfStock,
      'lowStock': lowStock,
    };
  }

  // Legacy getter for backward compatibility
  String? get thumbnail => imageUrl;

  bool get isOutOfStock => outOfStock || stock == 0;
  bool get isLowStock => lowStock || stock < 5;

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }
}
