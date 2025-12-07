import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goturey_marketplace/constants/enums/status.dart';
import 'package:goturey_marketplace/constants/firebase_refs/collections.dart';
import 'package:goturey_marketplace/models/cart.dart';
import 'package:goturey_marketplace/models/product.dart';
import 'package:goturey_marketplace/providers/cart.dart';
import 'package:goturey_marketplace/views/customer/cart/cart.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';
import 'package:goturey_marketplace/views/widgets/main_app_bar.dart';
import 'package:goturey_marketplace/views/widgets/msg_snackbar.dart';
import 'package:provider/provider.dart';

class VariantDetailScreen extends StatefulWidget {
  const VariantDetailScreen(
      {super.key, required this.product, required this.variant});

  final Product product;
  final ProductVariant variant;

  @override
  State<VariantDetailScreen> createState() => _VariantDetailScreenState();
}

class _VariantDetailScreenState extends State<VariantDetailScreen> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.product.isFav;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cart = Provider.of<CartProvider>(context);

    final adultProdId =
        '${widget.product.firestoreId}-${widget.variant.name}-adult';
    final childProdId =
        '${widget.product.firestoreId}-${widget.variant.name}-child';

    final adultQty = cart.getProductQuantityOnCart(adultProdId);
    final childQty = cart.getProductQuantityOnCart(childProdId);

    return Scaffold(
      appBar: MainAppBar(
        title: 'Product',
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
          const MainBottomNav(currentIndex: 0, isProductDetailsPage: true, userType: UserType.customer),
      body: Column(
        children: [
          // 🖼 Image Banner
          Stack(
            children: [
              Image.network(
                widget.variant.url.isNotEmpty ? widget.variant.url.first : 'assets/images/placeholder-img.jpg',
                height: screenHeight * 0.5,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/placeholder-img.jpg',
                    height: screenHeight * 0.5,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
              Positioned(
                left: 16,
                bottom: 16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.eco, color: Colors.white, size: 32),
                                      Text(
                                        '${widget.variant.name}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),              ),
            ],
          ),

          // 🧾 Info + Cart Controls
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.variant.name}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Adult Price and Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Adult: RM ${widget.variant.price_adult.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                cart.decreaseQuantity(adultProdId);
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$adultQty',
                                style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              onPressed: () {
                                if (cart.isItemOnCart(adultProdId)) {
                                  cart.increaseQuantity(adultProdId);
                                } else {
                                  final cartItem = Cart(
                                    cartId: adultProdId,
                                    prodId: adultProdId,
                                    prodName: '${widget.variant.name} (Adult)',
                                    price: widget.variant.price_adult,
                                    prodImg: widget.variant.url.isNotEmpty ? widget.variant.url.first : 'assets/images/placeholder-img.jpg',
                                    quantity: 1,
                                    vendorId: '',
                                    prodSize: '',
                                    date: DateTime.now(),
                                  );
                                  cart.addToCart(cartItem);
                                }
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Child Price and Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Child: RM ${widget.variant.price_child.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                cart.decreaseQuantity(childProdId);
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$childQty',
                                style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              onPressed: () {
                                if (cart.isItemOnCart(childProdId)) {
                                  cart.increaseQuantity(childProdId);
                                } else {
                                  final cartItem = Cart(
                                    cartId: childProdId,
                                    prodId: childProdId,
                                    prodName: '${widget.variant.name} (Child)',
                                    price: widget.variant.price_child,
                                    prodImg: widget.variant.url.isNotEmpty ? widget.variant.url.first : 'assets/images/placeholder-img.jpg',
                                    quantity: 1,
                                    vendorId: '',
                                    prodSize: '',
                                    date: DateTime.now(),
                                  );
                                  cart.addToCart(cartItem);
                                }
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 🛒 Add to Cart Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            displaySnackBar(
                              status: Status.success,
                              message: 'Cart updated!',
                              context: context,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Add to Cart',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            isFav = !isFav;
                          });
                          await FirebaseCollections.productsCollection
                              .doc(widget.product.firestoreId)
                              .update({'isFav': isFav});
                        },
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
