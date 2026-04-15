import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:goturey_marketplace/views/customer/main_screen.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';
import 'package:goturey_marketplace/views/customer/widgets/responsive_layout_wrapper.dart';
import 'package:goturey_marketplace/constants/color.dart';
import 'package:goturey_marketplace/resources/styles_manager.dart';
import 'package:goturey_marketplace/views/customer/relational_screens/product_details.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../helpers/icon_mapper.dart';
import '../../../resources/assets_manager.dart';
import '../../components/single_product_grid.dart';
import '../../widgets/loading_widget.dart';

class ProductByCategoryScreen extends StatefulWidget {
  const ProductByCategoryScreen({super.key, required this.category});

  final Category category;

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> productStream = FirebaseFirestore.instance
        .collection('products')
        //.orderBy('uploadDate', descending: true)
        //.where('isApproved', isEqualTo: true)
        .where('category', isEqualTo: widget.category.title)
        .snapshots();

    Size size = MediaQuery.sizeOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    
    // Responsive column count
    int crossAxisCount;
    if (screenWidth > 1400) {
      crossAxisCount = 6;
    } else if (isDesktop) {
      crossAxisCount = 5;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return ResponsiveLayoutWrapper(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5FF),
        appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F0FF),
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.chevron_left,
                color: Color(0xFFef2b7c),
                size: 35,
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: widget.category.isActive
                      ? Icon(
                          iconFromName(widget.category.icon),
                          color: const Color(0xFFef2b7c),
                          size: 28,
                        )
                      : ClipOval(
                          child: Image.network(
                            'https://placehold.co/360x360?text=Coming+Soon',
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.category.title,
                  style: getMediumStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F0FF), Color(0xFFF8F5FF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: productStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          AssetManager.warningImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'An error occurred!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: LoadingWidget(size: 30),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          AssetManager.addImage,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Product list is empty',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return MasonryGridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                padding: const EdgeInsets.only(
                  top: 16,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data!.docs[index];

                  Product product = Product.fromJson(item);

                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: product,
                        ),
                      ),
                    ),
                    child: SingleProductGridItem(
                      product: product,
                      size: size,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      ),
    );
  }
}
