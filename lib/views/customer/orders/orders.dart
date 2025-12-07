import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooler_alerts/cooler_alerts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:goturey_marketplace/constants/firebase_refs/collections.dart';
import 'package:goturey_marketplace/views/widgets/kcool_alert.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';
import 'package:goturey_marketplace/views/widgets/main_app_bar.dart';
import '../../../constants/enums/status.dart';
import '../../../providers/order.dart';
import '../../../resources/assets_manager.dart';
import '../../components/single_order_item.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../main_screen.dart';
import '../../../models/buyer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Buyer buyer = Buyer.initial();
  bool profileIncomplete = false;
  bool isAddressEmpty = false;
  bool isPhoneNumberEmpty = false;
  String? apiPublicKey;
  String? apiEncryptKey;
  FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isTestMode = true;
  Uuid uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
    fetchAPIKeys();
  }

  // fetch Api keys
  Future<void> fetchAPIKeys() async {
    apiPublicKey = await storage.read(key: 'flutterwave_public_key');
    apiEncryptKey = await storage.read(key: 'flutterwave_encrypt_key');
  }

  // fetch customer details
  Future<void> fetchCustomerDetails() async {
    await FirebaseCollections.customersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot data) {
      if (mounted) {
        setState(() {
          buyer = Buyer.fromJson(data);
          profileIncomplete = (data['phone']?.toString().isEmpty ?? true) ||
              (data['address']?.toString().isEmpty ?? true);
          isPhoneNumberEmpty = data['phone']?.toString().isEmpty ?? true;
          isAddressEmpty = data['address']?.toString().isEmpty ?? true;
        });
      }
    });
  }

  // Generate unique 10-character payment reference
  String generatePaymentReference() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // pop out
  void popOut() {
    Navigator.of(context).pop();
  }

  // show loading
  Future<void> showLoading(String message, Status status) async {
    kCoolAlert(
      message: message,
      context: context,
      alert: status == Status.error ? CoolAlertType.error : CoolAlertType.success,
      action: (_) => popOut(),
    );
  }

  // Create pre-authorized order in Firebase (before payment)
  Future<String> createPreAuthorizedOrder(String paymentReference) async {
    final orderData = Provider.of<OrderProvider>(context, listen: false);
    
    // Prepare all products from cart
    final allProducts = orderData.orders.expand((order) => order.products).map((item) {
      return {
        'vendorId': item.vendorId,
        'prodId': item.prodId,
        'prodName': item.prodName,
        'prodPrice': item.price,
        'prodQuantity': item.quantity,
      };
    }).toList();

    // Generate unique order ID
    var orderId = uuid.v4();

    // Create pre-authorized order document
    final docRef = await FirebaseCollections.ordersCollection.add({
      'orderId': orderId,
      'customerId': buyer.customerId,
      'customerEmail': buyer.email,
      'customerName': buyer.fullname,
      'customerPhone': buyer.phone,
      'products': allProducts,
      'totalAmount': orderData.getTotal,
      'currency': 'MYR',
      'orderDate': Timestamp.now(),
      'paymentReference': paymentReference,
      'paymentStatus': 'pending', // Pre-authorized state
      'isDelivered': false,
      'isApproved': false, // Will be set to true after payment confirmation
      'vendorId': allProducts.isNotEmpty ? allProducts[0]['vendorId'] : null,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      
    });

    return docRef.id;
  }

   // navigate to profile
    void navigateToProfile() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CustomerMainScreen(index: 5),
        ),
      );
    }

  // Handle Chip In Payment
  Future<void> handleChipInPayment() async {
    final orderData = Provider.of<OrderProvider>(context, listen: false);

    // Check if cart is empty
    if (orderData.orders.isEmpty) {
      showLoading('Your cart is empty. Please add items before checkout.', Status.error);
      return;
    }

    // Check profile completeness
    // if (profileIncomplete) {
    //   kCoolAlert(
    //     message: isAddressEmpty && isPhoneNumberEmpty
    //         ? 'Your profile is incomplete! Please update your address and phone number.'
    //         : isPhoneNumberEmpty
    //             ? 'Your profile is incomplete! Please update your phone number.'
    //             : 'Your profile is incomplete! Please update your address.',
    //     context: context,
    //     alert: CoolAlertType.error,
    //     action: (_) => navigateToProfile(),
    //     confirmBtnText: 'Update Profile',
    //   );
    //   return;
    // }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text('Creating order...', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );

    try {
      // 1. Generate unique payment reference
      final paymentReference = generatePaymentReference();
      
      // 2. Create pre-authorized order in Firebase
      final orderId = await createPreAuthorizedOrder(paymentReference);

      // 3. Prepare products payload for SenangPay
      final List<String> productDetailsList = orderData.orders
          .expand((order) => order.products)
          .map((item) => '${item.prodName} x ${item.quantity}')
          .toList();
      final String productDetail = productDetailsList.join(', ');

      // 4. Call PHP backend to create Chip In purchase
      final backendUrl = Uri.parse('https://api.goturey.com/senangpay_payment.php');
      
      final response = await http.post(
        backendUrl,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'amount=${(orderData.getTotal).toInt()}&email=${buyer.email}&name=${buyer.fullname}&phone=${buyer.phone}&detail=${Uri.encodeComponent(productDetail)}&order_id=${orderId}',
      );

      Navigator.of(context).pop(); // Close loading indicator

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final paymentUrl = responseData['payment_url'] as String?;

        if (paymentUrl == null) {
          showLoading('Failed to get payment URL. Please try again.', Status.error);
          return;
        }

        // 5. Launch payment flow
        if (kIsWeb) {
          // For web platform: Open payment URL in new tab
          final Uri paymentUri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(paymentUri)) {
            await launchUrl(
              paymentUri,
              mode: LaunchMode.externalApplication,
            );
            
            // Show completion dialog with order tracking
            _showPaymentCompletionDialog(orderId, paymentReference);
          } else {
            showLoading('Could not open payment page. Please try again.', Status.error);
          }
        } else {
          // For mobile platforms: Use WebView or external browser
          final Uri paymentUri = Uri.parse(paymentUrl);
          await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
          _showPaymentCompletionDialog(orderId, paymentReference);
        }

      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to create payment.';
        showLoading('Error: $errorMessage', Status.error);
      }

    } catch (e) {
      Navigator.of(context).pop(); // Ensure loading indicator is closed
      showLoading('Network error occurred. Please check your connection and try again.', Status.error);
      print('Payment error: $e');
    }
  }

  // Show payment completion dialog with order tracking
  void _showPaymentCompletionDialog(String orderId, String paymentReference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Payment Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please complete your payment in the opened tab, then return here to confirm.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: $orderId', 
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                  // const SizedBox(height: 4),
                  // Text('Reference: $paymentReference',
                  //   style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showLoading('Payment was cancelled. Your order is saved and can be completed later.', Status.error);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show success message
              showLoading(
                "Thank you! Your order has been processed. You will receive a confirmation email shortly.", 
                Status.success
              );
              
              // Clear the cart
              Provider.of<OrderProvider>(context, listen: false).clearOrder();
              
              // Navigate to main screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CustomerMainScreen(index: 0),
                ),
              );
            },
            child: const Text('Payment Completed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);

    // remove all order items dialog
    void removeAllOrderItemsDialog() {
      areYouSureDialog(
        title: 'Clear All Orders',
        content: 'Are you sure you want to remove all items from your cart?',
        context: context,
        action: () {
          orderData.clearOrder();
          Navigator.of(context).pop();
        },
      );
    }

    // order now button
    Future<void> orderNow() async {
      await handleChipInPayment();
    }

    return Scaffold(
      appBar: MainAppBar(
        title: 'Your Orders',
        actions: [
          if (orderData.orders.isNotEmpty)
            IconButton(
              onPressed: removeAllOrderItemsDialog,
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
            ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: orderData.orders.isEmpty
          ? _buildEmptyOrders()
          : _buildOrdersList(orderData),
      bottomNavigationBar: const MainBottomNav(
        currentIndex: 3,
        isProductDetailsPage: false,
        userType: UserType.customer,
      ),
      bottomSheet: orderData.orders.isNotEmpty
          ? _buildCheckoutSection(orderData, orderNow)
          : null,
    );
  }

  // Widget for displaying the list of orders
  Widget _buildOrdersList(OrderProvider orderData) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 120.0),
      itemCount: orderData.orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orderData.orders[index];
        return SingleOrderItem(
          id: order.id,
          totalAmount: order.totalAmount,
          date: order.orderDate,
          orders: order,
        );
      },
    );
  }

  // Widget for the empty orders state
  Widget _buildEmptyOrders() {
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
                  Image.asset(AssetManager.empty, height: 120),
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
                    'Add some amazing items to get started with your order.',
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
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CustomerMainScreen(index: 0),
                        ),
                      ),
                      child: const Text('Start Shopping'),
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

  // Widget for the checkout section
  Widget _buildCheckoutSection(OrderProvider orderData, VoidCallback orderNow) {
    return Container(
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
                        'RM ${orderData.getTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.blueAccent),
                        const SizedBox(width: 6),
                        Text(
                          '${orderData.orders.length} ${orderData.orders.length > 1 ? "items" : "item"}',
                          style: const TextStyle(
                            color: Colors.blueAccent,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 2,
                  ),
                  onPressed: orderNow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Proceed to Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
