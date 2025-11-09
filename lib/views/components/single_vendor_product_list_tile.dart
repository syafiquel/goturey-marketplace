import 'package:flutter/material.dart';

import '../../models/product.dart';

class SingleVendorProductListTile extends StatelessWidget {
  const SingleVendorProductListTile({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    // TODO: This widget is temporarily disabled due to data model changes.
    // Refactor to use the new Product model with variants.
    return const Card(
      child: ListTile(
        title: Text('This component is under construction.'),
      ),
    );
  }
}
