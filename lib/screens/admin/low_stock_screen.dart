import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<Product> _lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLowStockProducts();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadLowStockProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    _lowStockProducts = await productProvider.getLowStockProducts();
    setState(() {});
  }

  void _onRefresh() async {
    await _loadLowStockProducts();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock'),
      ),
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            if (productProvider.isLoading && _lowStockProducts.isEmpty) {
              return const ShimmerList();
            }

            if (productProvider.error != null && _lowStockProducts.isEmpty) {
              return ErrorDisplay(
                message: productProvider.error!,
                onRetry: _loadLowStockProducts,
              );
            }

            if (_lowStockProducts.isEmpty) {
              return const EmptyState(
                title: 'No Low Stock Items',
                message: 'All products have sufficient stock levels.',
                icon: Icons.check_circle_outline,
              );
            }

            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _lowStockProducts.length,
                itemBuilder: (context, index) {
                  final product = _lowStockProducts[index];
                  return _LowStockProductCard(product: product);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LowStockProductCard extends StatelessWidget {
  final Product product;

  const _LowStockProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.thumbnail != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(context),
                      ),
                    )
                  : _buildPlaceholderImage(context),
            ),
            const SizedBox(width: 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Stock Warning
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.isOutOfStock
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.isOutOfStock ? Icons.error : Icons.warning,
                          size: 16,
                          color: product.isOutOfStock
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.isOutOfStock
                              ? 'Out of Stock'
                              : 'Low Stock: ${product.stock}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: product.isOutOfStock
                                ? Theme.of(context).colorScheme.onErrorContainer
                                : Theme.of(context).colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Button
            IconButton(
              onPressed: () => _showRestockDialog(context, product),
              icon: const Icon(Icons.add_box),
              tooltip: 'Restock Product',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _showRestockDialog(BuildContext context, Product product) {
    final stockController = TextEditingController(text: product.stock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restock ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current stock: ${product.stock}'),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Stock Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // In a real app, you would call an API to update the stock
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restock functionality would be implemented here'),
                ),
              );
            },
            child: const Text('Update Stock'),
          ),
        ],
      ),
    );
  }
}
