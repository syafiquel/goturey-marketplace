import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goturey_marketplace/providers/cart.dart';
import 'package:goturey_marketplace/views/customer/main_screen.dart';
import 'package:goturey_marketplace/views/widgets/are_you_sure_dialog.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';
import 'package:goturey_marketplace/views/widgets/main_app_bar.dart';
import '../../../constants/color.dart';
import '../../../constants/enums/status.dart';
import '../../../controllers/route_manager.dart';
import '../../../providers/order.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../components/single_cart_item.dart';
import '../../widgets/msg_snackbar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<CartProvider>(context, listen: false).loadCartFromPrefs(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var cartData = Provider.of<CartProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    // Remove cart items
    void removeAllCartItems() {
      cartData.clearCart();
    }

    // Remove all cart items dialog
    void removeAllCartItemsDialog() {
      areYouSureDialog(
        title: 'Remove all cart items',
        content: 'Are you sure you want to remove all cart items?',
        context: context,
        action: removeAllCartItems,
      );
    }

    // Order now
    void orderNow() {
      if (cartData.getCartTotalAmount() > 0) {
        Provider.of<OrderProvider>(context, listen: false).addOrder(
          cartData.getCartTotalAmount(),
          cartData.getCartItems.values.toList(),
        );
        Provider.of<CartProvider>(context, listen: false).clearCart();
        Navigator.of(context).pushNamed(RouteManager.ordersScreen);
      } else {
        displaySnackBar(
          status: Status.error,
          message: 'Cart is empty!',
          context: context,
        );
      }
    }

    return Scaffold(
      // Using the consistent app bar design pattern
      appBar: MainAppBar(
        title: 'Shopping Cart',
        actions: [
          if (!cartData.isItemEmpty()) ...[
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed(
                RouteManager.ordersScreen,
              ),
              icon: const Icon(
                Icons.shopping_cart_checkout,
                color: Color(0xFF0095a0),
              ),
            ),
            IconButton(
              onPressed: () => removeAllCartItemsDialog(),
              icon: const Icon(
                Icons.delete_forever,
                color: Color(0xFFef2b7c),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: const Color(0xFFF8F5FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F0FF), Color(0xFFF8F5FF)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1000 : double.infinity,
            ),
            child: cartData.isItemEmpty()
                ? _buildEmptyCart()
                : _buildCartContent(cartData),
          ),
        ),
      ),
      bottomSheet: cartData.isItemEmpty() ? null : _buildCheckoutSection(cartData, orderNow, isDesktop),
    );
  }

  // Empty cart state with consistent styling
  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(
                    AssetManager.empty,
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add some amazing wildlife experiences to get started',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFef2b7c),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CustomerMainScreen(index: 0),
                        ),
                      ),
                      child: const Text(
                        'Continue Shopping',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cart content with consistent card styling
  Widget _buildCartContent(CartProvider cartData) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 120.0), // Space for checkout section
        itemCount: cartData.getCartQuantity,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          var item = cartData.getCartItems.values.toList()[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleCartItem(item: item, cartData: cartData),
            ),
          );
        },
      ),
    );
  }

  // Redesigned checkout section following design consistency
  Widget _buildCheckoutSection(CartProvider cartData, VoidCallback orderNow, bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1000 : double.infinity,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8.0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Total price section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Price',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RM ${cartData.getCartTotalAmount().toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFFef2b7c),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      // Cart quantity badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0095a0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF0095a0).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              size: 16,
                              color: Color(0xFF0095a0),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${cartData.getCartQuantity} items',
                              style: const TextStyle(
                                color: Color(0xFF0095a0),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Order now button with consistent styling
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFef2b7c),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      onPressed: orderNow,
                      child: const Text(
                        'Order Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
