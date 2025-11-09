import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:goturey_marketplace/models/product.dart';
import 'package:goturey_marketplace/views/customer/relational_screens/product_details.dart';
import 'package:provider/provider.dart';
import '../../providers/category.dart';
import '../../resources/values_manager.dart';
import '../components/single_product_grid.dart';
import '../widgets/loading_widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController searchText = TextEditingController();
  List<String> bannerUrls = [];
  final PageController _bannerPageController = PageController();
  Timer? _bannerTimer;
  int _currentBannerPage = 0;

  final categories = ['Watersports', 'Ferry', 'Island Hopping', 'Packages', 'Snorkeling', 'Diving', 'Jetski', 'Banana Boat'];
  final catIcons = [
    Icons.pool,
    Icons.directions_boat,
    Icons.landscape,
    Icons.card_travel,
    Icons.scuba_diving,
    Icons.water,
    Icons.two_wheeler,
    Icons.surfing,
  ];
  final catColors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];
  final catTitles = ['Watersports', 'Ferry', 'Island Hopping', 'Packages', 'Snorkeling', 'Diving', 'Jetski', 'Banana Boat'];

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
    final int categoryPageCount = (categories.length / 4).ceil();

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
              expandedHeight: 140,
              backgroundColor: const Color(0xFFF6F0FF),
              elevation: 0,
              flexibleSpace: const FlexibleSpaceBar(
                expandedTitleScale: 1.4,
                titlePadding:
                    EdgeInsetsDirectional.only(start: 20, bottom: 16, top: 16),
                title: Text('Hello hello 👋',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
              ),
            ), // rounded app bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
            if (bannerUrls.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: PageView.builder(
                        controller: _bannerPageController,
                        itemCount: bannerUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(bannerUrls[index], fit: BoxFit.cover);
                        },
                        onPageChanged: (index) {
                          _currentBannerPage = index;
                        },
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Categories',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260, // Adjust height for 2x2 grid pages
                child: PageView.builder(
                  itemCount: categoryPageCount,
                  itemBuilder: (context, pageIndex) {
                    final startIndex = pageIndex * 4;
                    final endIndex = (startIndex + 4 > categories.length) ? categories.length : startIndex + 4;
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 4/3,
                      ),
                      itemCount: endIndex - startIndex,
                      itemBuilder: (context, i) {
                        final itemIndex = startIndex + i;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: Colors.white.withOpacity(0.55)),
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(catIcons[itemIndex], color: catColors[itemIndex]),
                                        const SizedBox(height: 12),
                                        Text(catTitles[itemIndex],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Products',
                    style: Theme.of(context).textTheme.titleMedium),
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
        AsyncSnapshot<QuerySnapshot> snapshot,
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
        final pageCount = (productCount / 4).ceil();
        final screenWidth = MediaQuery.of(context).size.width;
        // Assuming a 2x2 grid with some spacing, and an aspect ratio for items
        final itemHeight = (screenWidth / 2) / 0.75; // Using the aspect ratio from before
        final pageViewHeight = itemHeight * 2 + 10; // 2 rows + spacing

        return SliverToBoxAdapter(
          child: SizedBox(
            height: pageViewHeight,
            child: PageView.builder(
              itemCount: pageCount,
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 4;
                final endIndex = (startIndex + 4 > productCount) ? productCount : startIndex + 4;
                final pageProducts = products.sublist(startIndex, endIndex);

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
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
        );
      },
    );
  }
}