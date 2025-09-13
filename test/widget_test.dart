import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ecommerce_flutter/main.dart';
import 'package:mini_ecommerce_flutter/models/product.dart';
import 'package:mini_ecommerce_flutter/providers/auth_provider.dart';
import 'package:mini_ecommerce_flutter/providers/cart_provider.dart';
import 'package:mini_ecommerce_flutter/providers/order_provider.dart';
import 'package:mini_ecommerce_flutter/providers/product_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App initializes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pump();

      expect(find.text('Initializing app...'), findsOneWidget);
    });

    testWidgets('Cart badge shows correct count', (WidgetTester tester) async {
      // Create a test product
      final testProduct = Product(
        id: '1',
        name: 'Test Product',
        price: 1000,
        stock: 5,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => OrderProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Column(
                    children: [
                      Text('Items: ${cartProvider.itemCount}'),
                      ElevatedButton(
                        onPressed: () => cartProvider.addItem(testProduct),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Items: 0'), findsOneWidget);

      await tester.tap(find.text('Add to Cart'));
      await tester.pump();

      expect(find.text('Items: 1'), findsOneWidget);
    });

    testWidgets('Product card displays correctly', (WidgetTester tester) async {
      final testProduct = Product(
        id: '1',
        name: 'Test Product',
        price: 1999,
        stock: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: ListTile(
                title: Text(testProduct.name),
                subtitle: Text(testProduct.formattedPrice),
                trailing: Text('Stock: ${testProduct.stock}'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('\$19.99'), findsOneWidget);
      expect(find.text('Stock: 3'), findsOneWidget);
    });

    testWidgets('Out of stock product shows correct badge', (WidgetTester tester) async {
      final outOfStockProduct = Product(
        id: '1',
        name: 'Out of Stock Product',
        price: 1000,
        stock: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Product'),
                if (outOfStockProduct.isOutOfStock)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Chip(
                      label: Text('Out of Stock'),
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Out of Stock'), findsOneWidget);
    });

    testWidgets('Low stock product shows warning', (WidgetTester tester) async {
      final lowStockProduct = Product(
        id: '1',
        name: 'Low Stock Product',
        price: 1000,
        stock: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(lowStockProduct.name),
                if (lowStockProduct.isLowStock)
                  const Chip(
                    label: Text('Low Stock'),
                    backgroundColor: Colors.orange,
                  ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Low Stock'), findsOneWidget);
    });
  });
}
