import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goturey_marketplace/constants/enums/status.dart';
import 'package:goturey_marketplace/constants/firebase_refs/collections.dart';
import 'package:goturey_marketplace/models/cart.dart';
import 'package:goturey_marketplace/models/product.dart';
import 'package:goturey_marketplace/providers/cart.dart';
import 'package:goturey_marketplace/views/auth/customer/customer_auth.dart';
import 'package:goturey_marketplace/views/customer/cart/cart.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';
import 'package:goturey_marketplace/views/customer/widgets/parking_booking_screen.dart';
import 'package:goturey_marketplace/views/customer/widgets/responsive_layout_wrapper.dart';
import 'package:goturey_marketplace/views/widgets/main_app_bar.dart';
import 'package:goturey_marketplace/views/widgets/msg_snackbar.dart';
import 'package:intl/intl.dart';
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
  DateTime? _selectedBookingDate;
  BookingOption _selectedBookingOption =
      const BookingOption(label: '1 Hour', hours: 1);

  @override
  void initState() {
    super.initState();
    isFav = widget.product.isFav;
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text('Please sign in or register to add items to your cart.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomerAuthScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFef2b7c),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign In / Register'),
            ),
          ],
        );
      },
    );
  }

  bool _isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  void _checkAuthAndExecute(VoidCallback action) {
    if (_isAuthenticated()) {
      action();
    } else {
      _showAuthDialog();
    }
  }

  bool get _isParking => widget.product.category.toLowerCase() == 'parking';

  double _bookingMultiplier({required bool adult}) {
    if (!_isParking) return 1.0;
    final hours = _selectedBookingOption.hours.toDouble();
    return _selectedBookingOption.usePerEntry ? 1.0 : hours;
  }

  double _unitPrice({required bool adult}) {
    if (!_isParking) {
      return adult ? widget.variant.price_adult : widget.variant.price_child;
    }

    final base = adult ? widget.variant.price_adult : widget.variant.price_child;
    if (_selectedBookingOption.usePerEntry && widget.variant.perEntry > 0) {
      return widget.variant.perEntry;
    }
    return base * _bookingMultiplier(adult: adult);
  }

  double _calculateTotal(int adultQty, int childQty) {
    return adultQty * _unitPrice(adult: true) + childQty * _unitPrice(adult: false);
  }

  String get _bookingDateLabel {
    if (_selectedBookingDate == null) {
      return 'No date selected';
    }
    return DateFormat('EEE, dd MMM yyyy').format(_selectedBookingDate!);
  }

  void _handleParkingBooking() async {
    final result = await Navigator.of(context).push<ParkingBookingResult>(
      MaterialPageRoute(
        builder: (_) => ParkingBookingScreen(
          initialDate: _selectedBookingDate,
          initialOption: _selectedBookingOption,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedBookingDate = result.date;
        _selectedBookingOption = result.option;
      });
    }
  }

  void _checkBookingAndExecute(VoidCallback action) {
    if (_isParking && _selectedBookingDate == null) {
      displaySnackBar(
        status: Status.error,
        message: 'Please choose a booking date first.',
        context: context,
      );
      return;
    }
    _checkAuthAndExecute(action);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final cart = Provider.of<CartProvider>(context);

    final adultProdId =
        '${widget.product.firestoreId}-${widget.variant.name}-adult';
    final childProdId =
        '${widget.product.firestoreId}-${widget.variant.name}-child';

    final adultQty = cart.getProductQuantityOnCart(adultProdId);
    final childQty = cart.getProductQuantityOnCart(childProdId);
    final totalAmount = _calculateTotal(adultQty, childQty);

    return ResponsiveLayoutWrapper(
      currentIndex: 0,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5FF),
        appBar: MainAppBar(
          title: 'Product Details',
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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1000 : double.infinity,
            ),
            child: Column(
              children: [
                // 🖼 Image Banner
                ClipRRect(
                  borderRadius: isDesktop 
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        )
                      : BorderRadius.zero,
                  child: Stack(
                    children: [
                      Image.network(
                        widget.variant.url.isNotEmpty ? widget.variant.url.first : 'assets/images/placeholder-img.jpg',
                        height: isDesktop ? screenHeight * 0.35 : screenHeight * 0.4,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/placeholder-img.jpg',
                            height: isDesktop ? screenHeight * 0.35 : screenHeight * 0.4,
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
                        ),
                      ),
                    ],
                  ),
                ),

                // 🧾 Info + Cart Controls
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32.0 : 16.0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${widget.variant.name}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              // Adult Price and Quantity Selector
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Adult',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey.shade600,
                                          )),
                                      const SizedBox(height: 4),
                                      Text('RM ${widget.variant.price_adult.toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: const Color(0xFF0095a0),
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF0095a0).withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFF0095a0).withOpacity(0.05),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _checkAuthAndExecute(() {
                                              cart.decreaseQuantity(adultProdId);
                                            });
                                          },
                                          icon: const Icon(Icons.remove, color: Color(0xFF0095a0)),
                                        ),
                                        Text('$adultQty',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: const Color(0xFF0095a0),
                                              fontWeight: FontWeight.bold,
                                            )),
                                        IconButton(
                                          onPressed: () {
                                            _checkBookingAndExecute(() {
                                              if (cart.isItemOnCart(adultProdId)) {
                                                cart.increaseQuantity(adultProdId);
                                              } else {
                                                final cartItem = Cart(
                                                  cartId: adultProdId,
                                                  prodId: adultProdId,
                                                  prodName: '${widget.variant.name} (Adult)',
                                                  price: _unitPrice(adult: true),
                                                  prodImg: widget.variant.url.isNotEmpty ? widget.variant.url.first : 'assets/images/placeholder-img.jpg',
                                                  quantity: 1,
                                                  vendorId: '',
                                                  prodSize: _isParking ? _selectedBookingOption.label : '',
                                                  date: _isParking ? (_selectedBookingDate ?? DateTime.now()) : DateTime.now(),
                                                );
                                                cart.addToCart(cartItem);
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.add, color: Color(0xFF0095a0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Child Price and Quantity Selector
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Child',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey.shade600,
                                          )),
                                      const SizedBox(height: 4),
                                      Text('RM ${widget.variant.price_child.toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: const Color(0xFFef2b7c),
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFef2b7c).withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFFef2b7c).withOpacity(0.05),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _checkAuthAndExecute(() {
                                              cart.decreaseQuantity(childProdId);
                                            });
                                          },
                                          icon: const Icon(Icons.remove, color: Color(0xFFef2b7c)),
                                        ),
                                        Text('$childQty',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: const Color(0xFFef2b7c),
                                              fontWeight: FontWeight.bold,
                                            )),
                                        IconButton(
                                          onPressed: () {
                                            _checkBookingAndExecute(() {
                                              if (cart.isItemOnCart(childProdId)) {
                                                cart.increaseQuantity(childProdId);
                                              } else {
                                                final cartItem = Cart(
                                                  cartId: childProdId,
                                                  prodId: childProdId,
                                                  prodName: '${widget.variant.name} (Child)',
                                                  price: _unitPrice(adult: false),
                                                  prodImg: widget.variant.url.isNotEmpty ? widget.variant.url.first : 'assets/images/placeholder-img.jpg',
                                                  quantity: 1,
                                                  vendorId: '',
                                                  prodSize: _isParking ? _selectedBookingOption.label : '',
                                                  date: _isParking ? (_selectedBookingDate ?? DateTime.now()) : DateTime.now(),
                                                );
                                                cart.addToCart(cartItem);
                                              }
                                            });
                                          },
                                          icon: const Icon(Icons.add, color: Color(0xFFef2b7c)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              if (_isParking) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 18, color: Color(0xFF0095a0)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Booking Date: $_bookingDateLabel',
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Duration: ${_selectedBookingOption.label}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Total Amount: RM ${totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Color(0xFFef2b7c),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // 🛒 Add to Cart Button
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isParking && _selectedBookingDate == null
                                          ? _handleParkingBooking
                                          : () {
                                              _checkBookingAndExecute(() {
                                                displaySnackBar(
                                                  status: Status.success,
                                                  message: 'Cart updated!',
                                                  context: context,
                                                );
                                              });
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFef2b7c),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        _isParking && _selectedBookingDate == null
                                            ? 'Choose Date'
                                            : 'Add to Cart',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: IconButton(
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
                                        color: const Color(0xFFef2b7c),
                                        size: 28,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
