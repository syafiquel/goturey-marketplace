import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goturey_marketplace/constants/firebase_refs/collections.dart';
import 'package:goturey_marketplace/resources/styles_manager.dart';
import 'package:goturey_marketplace/views/widgets/are_you_sure_dialog.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/color.dart';
import '../../../controllers/route_manager.dart';
import '../../../helpers/word_reverse.dart';
import '../../../models/vendor.dart';
import '../../../resources/font_manager.dart';
import '../../widgets/k_cached_image.dart';
import '../../widgets/k_tile.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userId = FirebaseAuth.instance.currentUser!.uid;
  Vendor vendor = Vendor.initial();
  var auth = FirebaseAuth.instance;

  var orders = 0;
  var availableFunds = 0.0;
  var products = 0;
  var earnings = 0.0;

  Future<void> fetchData() async {
    // init because of refresh indicator
    setState(() {
      orders = 0;
      availableFunds = 0.0;
      products = 0;
      earnings = 0.0;
    });

    // orders
    QuerySnapshot orderData = await FirebaseCollections.ordersCollection
        .where('vendorId', isEqualTo: userId)
        .get();

    double calculatedAvailableFunds = 0.0;
    for (var doc in orderData.docs) {
      if (!doc['isDelivered']) {
        calculatedAvailableFunds += doc['prodPrice'] * doc['prodQuantity'];
      }
    }

    setState(() {
      orders = orderData.docs.length;
      availableFunds = calculatedAvailableFunds;
    });


    // products
    QuerySnapshot productData = await FirebaseCollections.productsCollection
        .where('vendorId', isEqualTo: userId)
        .get();

    setState(() {
      products = productData.docs.length;
    });
  }

  // fetch vendor details
  Future<void> fetchVendor() async {
    DocumentSnapshot doc = await FirebaseCollections.vendorsCollection
        .doc(userId)
        .get();

    setState(() {
      vendor = Vendor.fromDoc(doc);
      earnings = Vendor.fromDoc(doc).balanceAvailable;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchVendor();
    fetchData();
  }

  // navigateToSettings
  void navigateToSettings() {
    // Todo implement this
  }

  // navigate to store analysis
  void navigateToStoreAnalysis() {
    Navigator.of(context).pushNamed(RouteManager.vendorDataAnalysis);
  }

  // edit profile
  void editProfile() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const VendorEditProfile(),
          ),
        )
        .then(
          (value) {
            fetchVendor();
            fetchData();
          },
        );
  }

  // cash out
  Future<void> cashOut() async {
    var id = const Uuid().v4();
    double totalAmount = 0.0;

    // Fetch orders
    QuerySnapshot orderData = await FirebaseCollections.ordersCollection
        .where('isDelivered', isEqualTo: false)
        .get();

    // Calculate total amount and update orders
    for (var doc in orderData.docs) {
      totalAmount += doc['prodPrice'] * doc['prodQuantity'];
      await FirebaseCollections.ordersCollection.doc(doc['orderId']).update({
        'isDelivered': true,
      });
    }

    // Update vendor's balance
    DocumentSnapshot vendorDoc = await FirebaseCollections.vendorsCollection
        .doc(userId)
        .get();
    double currentBalance = (vendorDoc.data() as Map<String, dynamic>)['balanceAvailable'] ?? 0.0;
    await FirebaseCollections.vendorsCollection.doc(userId).update({
      'balanceAvailable': currentBalance + totalAmount,
    });

    // Record cash out transaction
    await FirebaseCollections.cashOutCollection.doc(id).set({
      'id': id,
      'vendorId': userId,
      'amount': totalAmount,
      'status': false,
      'date': DateTime.now(),
    });

    // Refresh data and pop the dialog
    await Future.delayed(const Duration(seconds: 1)); // Added await
    fetchData(); // No need for await here, as it's just refreshing UI
    Navigator.of(context).pop(); // Changed cxt to context
  }

  // cash out dialog
  void cashOutDialog() {
    areYouSureDialog(
      title: 'Cash out your money',
      content: 'Are you sure you want to cash out your money?',
      context: context,
      action: cashOut,
    );
  }



  // logout dialog
  void logoutDialog() {
    areYouSureDialog(
      title: 'Logout Account',
      content: 'Are you sure you want to logout account',
      context: context,
      action: logout,
    );
  }

  // logout
  Future<void> logout() async {
    await auth.signOut();
    Navigator.of(context).pushNamed(RouteManager.customerAuthScreen);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 200, // Adjust as needed
            backgroundColor: accentColor,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  title: AnimatedOpacity(
                    opacity: constraints.biggest.height <= 120 ? 1 : 0,
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        KCachedImage(
                          image: vendor.storeImgUrl,
                          isCircleAvatar: true,
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          vendor.storeName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          boxBg,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        stops: [1, 1],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        KCachedImage(
                          image: vendor.storeImgUrl,
                          isCircleAvatar: true,
                          radius: 60,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          vendor.storeName,
                          style: getMediumStyle(
                            color: Colors.white,
                            fontSize: FontSize.s30,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              vendor.email,
                              style: getRegularStyle(
                                color: Colors.white,
                                fontSize: FontSize.s14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${vendor.city} ${vendor.state} ${reversedWord(vendor.country)}',
                              style: getRegularStyle(
                                color: Colors.white,
                                fontSize: FontSize.s13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat(
                          'Available Funds', '\$${availableFunds.toStringAsFixed(2)}', Icons.monetization_on),
                      _buildProfileStat(
                          'Orders', orders.toString(), Icons.shopping_cart_checkout),
                      _buildProfileStat(
                          'Products', products.toString(), Icons.shopping_bag),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        KListTile(
                          title: 'Edit Profile',
                          icon: Icons.edit_note,
                          onTapHandler: editProfile,
                          showSubtitle: false,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Divider(thickness: 1),
                        ),
                        KListTile(
                          title: 'App Settings',
                          icon: Icons.settings,
                          onTapHandler: navigateToSettings,
                          showSubtitle: false,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Divider(thickness: 1),
                        ),
                        KListTile(
                          title: 'Store Data Analysis',
                          icon: Icons.insert_chart,
                          onTapHandler: navigateToStoreAnalysis,
                          showSubtitle: false,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Divider(thickness: 1),
                        ),
                        KListTile(
                          title: 'Cash out Now',
                          icon: Icons.wallet,
                          onTapHandler: cashOutDialog,
                          showSubtitle: false,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Divider(thickness: 1),
                        ),
                        KListTile(
                          title: 'Logout',
                          icon: Icons.logout,
                          onTapHandler: logoutDialog,
                          showSubtitle: false,
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
    );
  }

  Widget _buildProfileStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: accentColor, size: 30),
        const SizedBox(height: 5),
        Text(
          title,
          style: getRegularStyle(color: Colors.black, fontSize: FontSize.s14),
        ),
        Text(
          value,
          style: getBoldStyle(color: Colors.black, fontSize: FontSize.s18),
        ),
      ],
    );
  }
}

