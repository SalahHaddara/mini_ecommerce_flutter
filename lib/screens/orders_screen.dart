import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadMyOrders();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    await Provider.of<OrderProvider>(context, listen: false).loadMyOrders();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.myOrders.isEmpty) {
            return const ShimmerList();
          }

          if (orderProvider.error != null && orderProvider.myOrders.isEmpty) {
            return ErrorDisplay(
              message: orderProvider.error!,
              onRetry: () => orderProvider.loadMyOrders(),
            );
          }

          if (orderProvider.myOrders.isEmpty) {
            return const EmptyState(
              title: 'No Orders Yet',
              message: 'You haven\'t placed any orders yet. Start shopping to see your orders here!',
              icon: Icons.receipt_long_outlined,
              action: null,
            );
          }

          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.myOrders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.myOrders[index];
                return _OrderCard(order: order);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context, order.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusTextColor(context, order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Order Date
              Text(
                'Ordered on ${order.formattedDate}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Order Items Summary
              Text(
                '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),

              // First few items
              if (order.items.isNotEmpty) ...[
                Text(
                  order.items.take(2).map((item) => item.productName).join(', '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (order.items.length > 2) ...[
                  const SizedBox(height: 4),
                  Text(
                    'and ${order.items.length - 2} more...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 12),

              // Order Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    order.formattedTotal,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Theme.of(context).colorScheme.tertiaryContainer;
      case 'confirmed':
        return Theme.of(context).colorScheme.primaryContainer;
      case 'shipped':
        return Theme.of(context).colorScheme.secondaryContainer;
      case 'delivered':
        return Colors.green.shade100;
      case 'cancelled':
        return Theme.of(context).colorScheme.errorContainer;
      default:
        return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  Color _getStatusTextColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case 'confirmed':
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case 'shipped':
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case 'delivered':
        return Colors.green.shade800;
      case 'cancelled':
        return Theme.of(context).colorScheme.onErrorContainer;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _OrderDetailsSheet(
          order: order,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final Order order;
  final ScrollController scrollController;

  const _OrderDetailsSheet({
    required this.order,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info
                  _buildInfoRow(context, 'Order ID', order.id),
                  _buildInfoRow(context, 'Date', order.formattedDate),
                  _buildInfoRow(context, 'Status', order.status.toUpperCase()),
                  _buildInfoRow(context, 'Total', order.formattedTotal),
                  const SizedBox(height: 24),

                  // Items
                  Text(
                    'Items (${order.items.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...order.items.map((item) => _OrderItemTile(item: item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${item.quantity} × ${item.formattedPrice}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Total
            Text(
              item.formattedTotalPrice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
