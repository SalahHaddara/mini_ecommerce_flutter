import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ecommerce_flutter/models/product.dart';
import 'package:mini_ecommerce_flutter/providers/cart_provider.dart';

void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;
    late Product testProduct1;
    late Product testProduct2;

    setUp(() {
      cartProvider = CartProvider();
      testProduct1 = Product(
        id: '1',
        name: 'Test Product 1',
        price: 10.00, // $10.00 in dollars
        stock: 5,
      );
      testProduct2 = Product(
        id: '2',
        name: 'Test Product 2',
        price: 25.00, // $25.00 in dollars
        stock: 3,
      );
    });

    test('should start with empty cart', () {
      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.subtotal, equals(0.0));
      expect(cartProvider.tax, equals(0.0));
      expect(cartProvider.total, equals(0.0));
      expect(cartProvider.isEmpty, isTrue);
    });

    test('should add item to cart', () {
      cartProvider.addItem(testProduct1, quantity: 2);

      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.itemCount, equals(2));
      expect(cartProvider.isInCart(testProduct1.id), isTrue);
      expect(cartProvider.getQuantity(testProduct1.id), equals(2));
    });

    test('should increment quantity when adding existing item', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.addItem(testProduct1, quantity: 1);

      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.itemCount, equals(3));
      expect(cartProvider.getQuantity(testProduct1.id), equals(3));
    });

    test('should calculate correct totals', () {
      cartProvider.addItem(testProduct1, quantity: 2); // $20.00
      cartProvider.addItem(testProduct2, quantity: 1); // $25.00

      expect(cartProvider.subtotal, equals(45.00));
      expect(cartProvider.tax, equals(2.25)); // 5% of $45.00 = $2.25
      expect(cartProvider.total, equals(47.25)); // $47.25
    });

    test('should format prices correctly', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.addItem(testProduct2, quantity: 1);

      expect(cartProvider.formattedSubtotal, equals('\$45.00'));
      expect(cartProvider.formattedTax, equals('\$2.25'));
      expect(cartProvider.formattedTotal, equals('\$47.25'));
    });

    test('should update quantity correctly', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.updateQuantity(testProduct1.id, 5);

      expect(cartProvider.getQuantity(testProduct1.id), equals(5));
      expect(cartProvider.itemCount, equals(5));
    });

    test('should remove item when quantity is set to 0', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.updateQuantity(testProduct1.id, 0);

      expect(cartProvider.isInCart(testProduct1.id), isFalse);
      expect(cartProvider.items, isEmpty);
    });

    test('should increment quantity correctly', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.incrementQuantity(testProduct1.id);

      expect(cartProvider.getQuantity(testProduct1.id), equals(3));
    });

    test('should decrement quantity correctly', () {
      cartProvider.addItem(testProduct1, quantity: 3);
      cartProvider.decrementQuantity(testProduct1.id);

      expect(cartProvider.getQuantity(testProduct1.id), equals(2));
    });

    test('should remove item when decrementing to 0', () {
      cartProvider.addItem(testProduct1, quantity: 1);
      cartProvider.decrementQuantity(testProduct1.id);

      expect(cartProvider.isInCart(testProduct1.id), isFalse);
      expect(cartProvider.items, isEmpty);
    });

    test('should remove item correctly', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.addItem(testProduct2, quantity: 1);

      cartProvider.removeItem(testProduct1.id);

      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.isInCart(testProduct1.id), isFalse);
      expect(cartProvider.isInCart(testProduct2.id), isTrue);
    });

    test('should clear cart correctly', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.addItem(testProduct2, quantity: 1);

      cartProvider.clear();

      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.subtotal, equals(0.0));
    });

    test('should convert to order items correctly', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.addItem(testProduct2, quantity: 1);

      final orderItems = cartProvider.toOrderItems();

      expect(orderItems.length, equals(2));
      expect(orderItems[0]['productId'], equals(testProduct1.id));
      expect(orderItems[0]['quantity'], equals(2));
      expect(orderItems[1]['productId'], equals(testProduct2.id));
      expect(orderItems[1]['quantity'], equals(1));
    });

    test('should handle multiple different products', () {
      cartProvider.addItem(testProduct1, quantity: 2);
      cartProvider.addItem(testProduct2, quantity: 1);
      cartProvider.addItem(testProduct1, quantity: 1); // Should increment existing

      expect(cartProvider.items.length, equals(2));
      expect(cartProvider.getQuantity(testProduct1.id), equals(3));
      expect(cartProvider.getQuantity(testProduct2.id), equals(1));
      expect(cartProvider.itemCount, equals(4));
    });
  });
}
