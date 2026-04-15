import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:goturey_marketplace/views/customer/cart/cart.dart';
import 'package:goturey_marketplace/views/customer/relational_screens/product_details.dart';
import 'package:goturey_marketplace/views/widgets/msg_snackbar.dart';

import '../../../constants/color.dart';
import '../../../constants/enums/status.dart';
import '../../../constants/firebase_refs/collections.dart';
import '../../../models/product.dart';
import '../../../resources/assets_manager.dart';
import '../../components/single_product_grid.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../../widgets/loading_widget.dart';

class WishListProducts extends StatefulWidget {
  const WishListProducts({super.key});

  @override
  State<WishListProducts> createState() => _WishListProductsState();
}

class _WishListProductsState extends State<WishListProducts> {
  bool isLoading = true;
  bool isEmpty = false;
  List<String> prodIds = [];

  Future<void> fetchWishListProdIds() async {
    await FirebaseFirestore.instance
        .collection('products')
        .where('isFav', isEqualTo: true)
        .get()
        .then((QuerySnapshot data) {
      for (var doc in data.docs) {
        setState(() {
          prodIds.add(doc['prodId']);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchWishListProdIds();
  }

  // get context
  get cxt => context;

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> searchProductsStream = FirebaseFirestore.instance
        .collection('products')
        //.where('isApproved', isEqualTo: true)
        .where('isFav', isEqualTo: true)
        .snapshots();

    // remove wishlist items
    void removeAllWishListItems() async {
      Navigator.pop(cxt);

      for (var id in prodIds) {
        await FirebaseCollections.productsCollection.doc(id).update(
          {'isFav': false},
        );
      }

      setState(() {
        prodIds.clear();
      });

      // show message
      displaySnackBar(
        status: Status.success,
        message: 'Removed all wish list',
        context: cxt,
      );
    }

    // remove all wishlist items dialog
    void removeAllWishListItemsDialog() {
      areYouSureDialog(
        title: 'Remove all wishlist items',
        content: 'Are you sure you want to remove all wishlist items',
        context: context,
        action: removeAllWishListItems,
      );
    }

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F0FF),
        elevation: 0,
        title: const Text('WishList'),
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.chevron_left,
                color: primaryColor,
                size: 35,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFef2b7c)),
          ),
          if (prodIds.isEmpty) ...[
            const SizedBox.shrink(),
          ] else ...[
            GestureDetector(
              onTap: () => removeAllWishListItemsDialog(),
              child: const Icon(
                Icons.delete_forever,
                color: Color(0xFFef2b7c),
                size: 30,
              ),
            ),
            const SizedBox(width: 18),
          ]
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
        child: StreamBuilder<QuerySnapshot>(
          stream: searchProductsStream,
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
            } else {
              isLoading = false;
            }

            if (snapshot.data!.docs.isEmpty) {
              isEmpty = true;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        AssetManager.love,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ops! Wish list is empty',
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
    );
  }
}
