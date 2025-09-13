import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_widget.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null && productProvider.products.isEmpty) {
            return ErrorDisplay(
              message: productProvider.error!,
              onRetry: () => productProvider.loadProducts(),
            );
          }

          if (productProvider.products.isEmpty) {
            return const EmptyState(
              title: 'No Products',
              message: 'There are no products available at the moment.',
              icon: Icons.inventory_2_outlined,
            );
          }

          // Placeholder for now
          return const Center(child: Text("Products loaded"));
        },
      ),
    );
  }
}
