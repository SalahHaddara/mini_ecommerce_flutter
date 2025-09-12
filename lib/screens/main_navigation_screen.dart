import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'admin/add_product_screen.dart';
import 'admin/admin_orders_screen.dart';
import 'admin/low_stock_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'orders_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isAdmin = authProvider.isAdmin;

        if (isAdmin) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: const [
                AddProductScreen(),
                AdminOrdersScreen(),
                LowStockScreen(),
                ProfileScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Add Product',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'All Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warning),
                  label: 'Low Stock',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
