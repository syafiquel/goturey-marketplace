import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:goturey_marketplace/models/vendor.dart';
import 'package:goturey_marketplace/views/customer/store/store_details.dart';

import '../../../constants/firebase_refs/collections.dart';
import '../../../resources/assets_manager.dart';
import '../../components/single_store_grid.dart';
import '../../widgets/loading_widget.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  Stream<QuerySnapshot> vendorStream = FirebaseCollections.vendorsCollection
      .where('isApproved', isEqualTo: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F0FF), Color(0xFFF8F5FF)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar with consistent styling
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFFF6F0FF),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Stores',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF6F0FF), Color(0xFFF8F5FF)],
                    ),
                  ),
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
              ),
            ),
            // Content
            StreamBuilder<QuerySnapshot>(
              stream: vendorStream,
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
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
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: LoadingWidget(size: 30),
                    ),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
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
                            'Store list is empty',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data!.docs[index];

                      Vendor vendor = Vendor(
                        storeId: item['storeId'],
                        storeName: item['storeName'],
                        email: item['email'],
                        phone: item['phone'],
                        taxNumber: item['taxNumber'],
                        storeNumber: item['storeNumber'],
                        country: item['country'],
                        state: item['state'],
                        city: item['city'],
                        storeImgUrl: item['storeImgUrl'],
                        address: item['address'],
                        authType: item['authType'],
                      );

                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StoreDetailsScreen(
                              vendor: vendor,
                            ),
                          ),
                        ),
                        child: SingleStoreGridItem(
                          vendor: vendor,
                          size: size,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
