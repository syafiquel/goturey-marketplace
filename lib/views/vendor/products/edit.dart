import 'package:flutter/material.dart';
import '../../../models/product.dart';

class VendorEditProduct extends StatelessWidget {
  const VendorEditProduct({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  Widget build(BuildContext context) {
    // TODO: This screen is temporarily disabled due to data model changes.
    // Refactor this to use the new Product model with variants.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'This feature is temporarily under construction due to a data model update.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
