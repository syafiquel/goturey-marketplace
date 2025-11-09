import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goturey_marketplace/constants/firebase_refs/collections.dart';
import '../../constants/color.dart';
import '../../resources/styles_manager.dart';
import '../../resources/values_manager.dart';
import '../components/vendor_chart.dart';
import '../components/build_vendor_dash_container.dart';
import '../widgets/vendor_logout_ac.dart';
import '../../models/app_data.dart';
import 'main_screen.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({Key? key}) : super(key: key);

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  var vendorId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot? store;
  bool _isStoreLoading = true;
  var orders = 0;
  var availableFunds = 0.0;
  var products = 0;

  Future<void> fetchData() async {
    // init because of refresh indicator
    setState(() {
      orders = 0;
      availableFunds = 0.0;
      products = 0;
      _isStoreLoading = true;
    });

    // Fetch store details
    store = await FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();
    setState(() {
      _isStoreLoading = false;
    });

    // orders
    await FirebaseCollections.ordersCollection
        .where('vendorId', isEqualTo: vendorId)
        .get()
        .then(
          (QuerySnapshot data) => {
            setState(() {
              orders = data.docs.length;
            }),

            // checkouts
            for (var doc in data.docs)
              {
                if (!doc['isDelivered'])
                  {
                    setState(() {
                      availableFunds += doc['prodPrice'] * doc['prodQuantity'];
                    })
                  }
              }
          },
        );

    // products
    await FirebaseCollections.productsCollection
        .where('vendorId', isEqualTo: vendorId)
        .get()
        .then(
          (QuerySnapshot data) => {
            setState(() {
              products = data.docs.length;
            }),
          },
        );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    List<AppData> data = [
      AppData(
        title: 'All Orders',
        number: orders,
        color: dashBlue,
        icon: Icons.shopping_cart_checkout,
        index: 1,
      ),
      AppData(
        title: 'Available Funds',
        number: availableFunds,
        color: dashGrey,
        icon: Icons.monetization_on,
        index: 3,
      ),
      AppData(
        title: 'Products',
        number: products,
        color: dashRed,
        icon: Icons.shopping_bag,
        index: 2,
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F0FF), Color(0xFFF8F5FF)],
          ),
        ),
        child: RefreshIndicator(
          color: accentColor,
          onRefresh: () => fetchData(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 140,
                backgroundColor: const Color(0xFFF6F0FF),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.4,
                  titlePadding:
                      const EdgeInsetsDirectional.only(start: 20, bottom: 16, top: 16),
                  title: _isStoreLoading
                      ? const Text('Loading...',
                          style: TextStyle(fontWeight: FontWeight.w700))
                      : Text('Hello ${store!['storeName']} 👋',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                                            const SizedBox(height: AppSize.s10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 6.5,
                        child: ListView.builder(
                          itemCount: data.length,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            var item = data[index];

                            return BuildDashboardContainer(
                              title: item.title,
                              value: item.index == 3
                                  ? '\$${item.number}'
                                  : item.number.toString(),
                              color: item.color,
                              icon: item.icon,
                              index: item.index,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VendorMainScreen(index: item.index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your store analysis',
                        style: getMediumStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      VendorDataGraph(data: data)
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
