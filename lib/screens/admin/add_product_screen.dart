import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _thumbnailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final price = double.tryParse(_priceController.text);
    final stock = int.tryParse(_stockController.text);

    if (price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid price and stock values'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await productProvider.createProduct(
      name: _nameController.text.trim(),
      price: price,
      stock: stock,
      imageUrl: _thumbnailController.text.trim().isEmpty ? null : _thumbnailController.text.trim(),
    );

    if (success && mounted) {
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.error ?? 'Failed to add product'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    _thumbnailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Add New Product',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Enter product name',
                  ),
                  validator: ValidationBuilder()
                      .required('Product name is required')
                      .maxLength(AppConstants.maxProductNameLength, 'Name too long')
                      .build(),
                ),
                const SizedBox(height: 16),

                // Price
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price (\$)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    hintText: '0.00',
                  ),
                  validator: ValidationBuilder().required('Price is required').add((value) {
                    if (value == null) return 'Price is required';
                    final price = double.tryParse(value);
                    if (price == null || price < AppConstants.minProductPrice) {
                      return 'Price must be at least \$${AppConstants.minProductPrice}';
                    }
                    return null;
                  }).build(),
                ),
                const SizedBox(height: 16),

                // Stock
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    prefixIcon: Icon(Icons.inventory),
                    border: OutlineInputBorder(),
                    hintText: '0',
                  ),
                  validator: ValidationBuilder().required('Stock quantity is required').add((value) {
                    if (value == null) return 'Stock quantity is required';
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Stock must be a non-negative number';
                    }
                    if (stock > AppConstants.maxProductStock) {
                      return 'Stock cannot exceed ${AppConstants.maxProductStock}';
                    }
                    return null;
                  }).build(),
                ),
                const SizedBox(height: 16),

                // Thumbnail URL (Optional)
                TextFormField(
                  controller: _thumbnailController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (Optional)',
                    prefixIcon: Icon(Icons.image),
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/image.jpg',
                  ),
                  validator: ValidationBuilder().add((value) {
                    if (value != null && value.isNotEmpty) {
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasScheme) {
                        return 'Please enter a valid URL';
                      }
                    }
                    return null;
                  }).build(),
                ),
                const SizedBox(height: 32),

                // Add Product Button
                Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    if (productProvider.isLoading) {
                      return const LoadingWidget(message: 'Adding product...');
                    }

                    return ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add Product'),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Clear Form Button
                OutlinedButton(
                  onPressed: _clearForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Clear Form'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
