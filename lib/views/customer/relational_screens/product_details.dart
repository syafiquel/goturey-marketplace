import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:goturey_marketplace/models/product.dart';
import 'package:goturey_marketplace/views/customer/cart/cart.dart';
import 'package:goturey_marketplace/views/customer/relational_screens/variant_details.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';
import 'package:goturey_marketplace/views/widgets/main_app_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final Product product;
  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MainAppBar(
        title: widget.product.name,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      bottomNavigationBar:
          const MainBottomNav(currentIndex: 0, isProductDetailsPage: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: screenHeight / 3,
                viewportFraction: 1.0,
                autoPlay: true,
              ),
              items: widget.product.featureImages.map((image) {
                return Image.network(
                  image.url,
                  fit: BoxFit.cover,
                  width: screenWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder-img.jpg',
                      fit: BoxFit.cover,
                      width: screenWidth,
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ...widget.product.variants.map((variant) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VariantDetailScreen(product: widget.product, variant: variant),
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          variant.imgUrls.isNotEmpty ? variant.imgUrls.first : 'assets/images/placeholder-img.jpg',
                          width: screenWidth * 0.25,
                          height: screenWidth * 0.25,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/placeholder-img.jpg',
                              width: screenWidth * 0.25,
                              height: screenWidth * 0.25,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${variant.color} - ${variant.size}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
