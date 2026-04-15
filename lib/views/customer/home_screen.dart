import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:goturey_marketplace/models/product.dart';
import 'package:goturey_marketplace/views/customer/relational_screens/product_details.dart';
import 'package:goturey_marketplace/views/customer/store/store_details.dart';
import 'package:goturey_marketplace/views/customer/categories/product_by_category.dart';
import 'package:provider/provider.dart';
import '../../constants/firebase_refs/collections.dart';
import '../../helpers/icon_mapper.dart';
import '../../models/category.dart';
import '../../models/vendor.dart';
import '../../providers/category.dart';
import '../../resources/values_manager.dart';
import '../components/single_product_grid.dart';
import '../widgets/loading_widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key, this.userName}) : super(key: key);
  
  final String? userName;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController searchText = TextEditingController();
  List<String> bannerUrls = [];
  final PageController _bannerPageController = PageController();
  Timer? _bannerTimer;
  int _currentBannerPage = 0;

  final List<Color> catColors = [
    const Color(0xFFef2b7c),
    const Color(0xFF0095a0),
    const Color(0xFFef2b7c),
    const Color(0xFF0095a0),
    const Color(0xFFef2b7c),
    const Color(0xFF0095a0),
    const Color(0xFFef2b7c),
  ];

  @override
  void initState() {
    super.initState();
    _fetchBannerUrls();
    searchText.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchText.dispose();
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _setupBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentBannerPage < bannerUrls.length - 1) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }
      if (_bannerPageController.hasClients) {
        _bannerPageController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> _fetchBannerUrls() async {
    final urls = await getAllImageUrls();
    if (mounted) {
      setState(() {
        bannerUrls = urls;
        if (bannerUrls.isNotEmpty) {
          _setupBannerTimer();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CategoryData categoryProvider = Provider.of<CategoryData>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final maxContentWidth = isDesktop ? double.infinity : 800.0;

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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              centerTitle: true,
              backgroundColor: const Color(0xFFF6F0FF),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(top: 60),
                title: Image.asset(
                  'assets/icons/goturey@4x.png',
                  height: 800,
                  fit: BoxFit.contain,
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
            
            // Search Bar
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? double.infinity : 800,
                    ),
                    child: TextField(
                      controller: searchText,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Categories Section (Pill Shaped - Above Banner)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  height: 40,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseCollections.categoriesCollection.orderBy('order').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Unable to load categories',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No categories yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final categoryDoc = docs[index];
                          final category = Category.fromJson(categoryDoc);
                          final color = catColors[index % catColors.length];

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProductByCategoryScreen(
                                      category: category,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: color,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    category.isActive
                                        ? Icon(
                                            iconFromName(category.icon),
                                            color: color,
                                            size: 24,
                                          )
                                        : Container(
                                            height: 24,
                                            width: 24,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipOval(
                                              child: Image.network(
                                                'https://placehold.co/360x360?text=Coming+Soon',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                    const SizedBox(width: 8),
                                    Text(
                                      category.title,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Hero Banners with Text Overlays
            if (bannerUrls.isNotEmpty)
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: SizedBox(
                      height: 312,
                      child: PageView.builder(
                        controller: _bannerPageController,
                        itemCount: bannerUrls.length > 2 ? 2 : bannerUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final titles = ['Explore Langkawi', 'Ferry Adventures'];
                          final subtitles = ['Your journey begins here', 'Seamless travel'];
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    bannerUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.black.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 24,
                                    bottom: 24,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titles[index % titles.length],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          subtitles[index % subtitles.length],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            
            // Official Stores Section
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Official Stores',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: screenWidth > 600 ? 160 : 130,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseCollections.vendorsCollection
                        .where('isApproved', isEqualTo: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading stores',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: LoadingWidget(size: 20),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No stores available',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      final vendors = snapshot.data!.docs;
                      final colors = [const Color(0xFFef2b7c), const Color(0xFF0095a0)];
                      final emojis = ['🏪', '🍫', '👕', '🎁', '🥘', '🐚', '🎨', '💎', '🌺', '🏝️'];

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: vendors.length,
                        itemBuilder: (context, index) {
                          final vendorData = vendors[index].data() as Map<String, dynamic>;
                          final storeName = vendorData['storeName'] ?? 'Store';
                          final color = colors[index % colors.length];
                          final emoji = emojis[index % emojis.length];
                          
                          // Create Vendor object for navigation
                          final vendor = Vendor(
                            storeId: vendorData['storeId'] ?? '',
                            storeName: storeName,
                            email: vendorData['email'] ?? '',
                            phone: vendorData['phone'] ?? '',
                            taxNumber: vendorData['taxNumber'] ?? '',
                            storeNumber: vendorData['storeNumber'] ?? '',
                            country: vendorData['country'] ?? '',
                            state: vendorData['state'] ?? '',
                            city: vendorData['city'] ?? '',
                            storeImgUrl: vendorData['storeImgUrl'] ?? '',
                            address: vendorData['address'] ?? '',
                            authType: vendorData['authType'] ?? '',
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StoreDetailsScreen(
                                    vendor: vendor,
                                  ),
                                ),
                              );
                            },
                            child: _buildStoreCard(emoji, storeName, color, screenWidth),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Featured Collections Section
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Featured Collections',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFeaturedCard(
                          'Flash Sale',
                          '50% Off',
                          'Limited Time Offer',
                          const Color(0xFFef2b7c),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeaturedCard(
                          'New Arrivals',
                          'Fresh',
                          'Summer Collection',
                          const Color(0xFF0095a0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // All Products Section
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'All Products',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            ProductGridStream(
              searchText: searchText.text,
              categoryProvider: categoryProvider,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStoreCard(String emoji, String title, Color color, double screenWidth) {
    final isDesktop = screenWidth > 600;
    final cardWidth = isDesktop ? 120.0 : 90.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: isDesktop ? 40 : 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isDesktop ? 13 : 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeaturedCard(String title, String badge, String subtitle, Color color) {
    return Container(
      height: 173,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<String>> getAllImageUrls() async {
    final CollectionReference productsRef =
        FirebaseFirestore.instance.collection('products');
    final QuerySnapshot snapshot = await productsRef.get();

    final List<String> urls = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> featureImages = data['featureImages'] ?? [];

      for (var image in featureImages) {
        if (image is Map<String, dynamic> && image['url'] != null) {
          urls.add(image['url']);
        }
      }
    }

    urls.shuffle();
    return urls;
  }

}

// Extracted widget for the product grid stream
class ProductGridStream extends StatelessWidget {
  const ProductGridStream({
    Key? key,
    required this.searchText,
    required this.categoryProvider,
  }) : super(key: key);

  final String searchText;
  final CategoryData categoryProvider;

  Stream<QuerySnapshot> fetchProducts() {
    CollectionReference productCollection =
        FirebaseFirestore.instance.collection('products');
    Query query = productCollection;

    if (searchText.isNotEmpty) {
      query = query
          .orderBy('name')
          .where('name', isGreaterThanOrEqualTo: searchText.trim())
          .where('name', isLessThan: '${searchText.trim()}z');
    }

    if (categoryProvider.currentCategory.isNotEmpty) {
      query =
          query.where('category', isEqualTo: categoryProvider.currentCategory);
    } else if (searchText.isEmpty) {
      query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fetchProducts(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot
      ) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                'An error occurred!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: LoadingWidget(size: 30),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
                child: Text(
                  'No products found.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          );
        }

        final products = snapshot.data!.docs;
        final productCount = products.length;
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 900;
        
        // Responsive grid columns - more columns on desktop for smaller cards
        int crossAxisCount;
        if (screenWidth > 1400) {
          crossAxisCount = 6; // Very large screens
        } else if (isDesktop) {
          crossAxisCount = 5; // Desktop screens
        } else if (screenWidth > 600) {
          crossAxisCount = 3; // Tablet screens
        } else {
          crossAxisCount = 2; // Mobile screens
        }
        
        final itemsPerPage = crossAxisCount * 2; // 2 rows
        final pageCount = (productCount / itemsPerPage).ceil();
        
        // Calculate responsive dimensions with max card width
        final availableWidth = isDesktop 
            ? screenWidth * 0.85  // 85% for content area (after 15% side nav)
            : screenWidth;
        final horizontalPadding = 40.0;
        final spacing = 10.0 * (crossAxisCount - 1);
        final itemWidth = (availableWidth - horizontalPadding - spacing) / crossAxisCount;
        
        // Constrain max card width on desktop for better appearance
        final maxCardWidth = isDesktop ? 200.0 : double.infinity;
        final effectiveItemWidth = isDesktop ? itemWidth.clamp(0, maxCardWidth) : itemWidth;
        final itemHeight = effectiveItemWidth / 0.75;
        final pageViewHeight = itemHeight * 2 + spacing + 20;

        return SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: pageViewHeight,
              child: PageView.builder(
                itemCount: pageCount,
                itemBuilder: (context, pageIndex) {
                  final startIndex = pageIndex * itemsPerPage;
                  final endIndex = (startIndex + itemsPerPage > productCount) ? productCount : startIndex + itemsPerPage;
                  final pageProducts = products.sublist(startIndex, endIndex);

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: pageProducts.length,
                    itemBuilder: (context, i) {
                      final item = pageProducts[i];
                      Product product = Product.fromJson(item);
                      Size size = MediaQuery.of(context).size;

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
          );
      },
    );
  }
}