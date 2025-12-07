import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../widgets/k_cached_image.dart';

class SingleProductGridItem extends StatelessWidget {
  const SingleProductGridItem({
    super.key,
    required this.product,
    required this.size,
  });

  final Product product;
  final Size size;

  @override
  Widget build(BuildContext context) {
    // Determine the image URL. Use the first variant image, or the first feature image, or a placeholder.
    String imageUrl = '';
    if (product.variants.isNotEmpty && product.variants.first.url.isNotEmpty) {
      imageUrl = product.variants.first.url.first;
    } else if (product.featureImages.isNotEmpty) {
      imageUrl = product.featureImages.first.url;
    }

    // Determine the price. Use the first variant's price if available.
    String priceString = '';
    if (product.variants.isNotEmpty) {
      priceString = '\${product.variants.first.price_adult.toStringAsFixed(2)}';
    }

    return Stack(
      children: [
        // Use a placeholder if no image is available
        imageUrl.isNotEmpty
            ? KCachedImage(
                image: imageUrl,
                height: 205,
                width: double.infinity,
              )
            : Container(
                height: 205,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
        Positioned(
          bottom: 3,
          left: 3,
          right: 3,
          child: Container(
            padding: const EdgeInsets.all(8.0), // Add padding
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.topCenter,
                stops: const [0, 1],
                colors: [
                  Theme.of(context).cardColor,
                  Theme.of(context).cardColor.withOpacity(0.03),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        product.name, // Use new field: name
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    // The cart functionality is disabled here as it requires variant selection.
                    // This should be handled in the product details screen.
                    // if (priceString.isNotEmpty)
                    //   Text(
                    //     priceString,
                    //     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //   ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
