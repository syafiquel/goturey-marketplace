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
  const VendorDashboard({Key? key, this.storeName}) : super(key: key);
  
  final String? storeName;

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
  String? _storeName;

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
    if (store!.exists) {
      final storeData = store!.data() as Map<String, dynamic>;
      _storeName = storeData['storeName'] ?? widget.storeName ?? 'Store';
    }
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
    _storeName = widget.storeName;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final crossAxisCount = isDesktop ? 3 : 2;
    
    List<AppData> data = [
      AppData(
        title: 'All Orders',
        number: orders,
        color: const Color(0xFF0095a0),
        icon: Icons.shopping_cart_checkout,
        index: 1,
      ),
      AppData(
        title: 'Available Funds',
        number: availableFunds,
        color: const Color(0xFFef2b7c),
        icon: Icons.monetization_on,
        index: 3,
      ),
      AppData(
        title: 'Products',
        number: products,
        color: const Color(0xFF0095a0),
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
                  title: Text(
                    _isStoreLoading 
                        ? 'Loading...' 
                        : 'Hello, ${_storeName ?? 'Store'}! 👋',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Dashboard Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isDesktop ? 1.3 : 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = data[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                VendorMainScreen(index: item.index, storeName: _storeName),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: Colors.white.withOpacity(0.7)),
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: item.color.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          color: item.color,
                                          size: isDesktop ? 32 : 28,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item.title,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.index == 3
                                            ? '\$${item.number.toStringAsFixed(2)}'
                                            : item.number.toString(),
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: item.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: data.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Store Analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: VendorDataGraph(data: data),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
