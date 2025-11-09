import 'package:flutter/material.dart';
import 'package:goturey_marketplace/views/components/generic_bottom_nav.dart';
import 'categories/categories.dart';
import 'profile/profile.dart';
import 'search/search.dart';
import 'store/store.dart';
import 'cart/cart.dart';
import 'home_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key, required this.index});
  final int index;

  @override
  State<CustomerMainScreen> createState() => _CustomerMainStateScreen();
}

class _CustomerMainStateScreen extends State<CustomerMainScreen> {
  var _pageIndex = 0;
  final List<Widget> _pages = const [
    CustomerHomeScreen(),
    CategoriesScreen(),
    StoreScreen(),
    SearchScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void setNewPage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  void initState() {
    if (widget.index != 0) {
      setNewPage(widget.index);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            bottomNavigationBar: GenericBottomNav(
              currentIndex: _pageIndex,
              onTap: (index) {
                if (index == _pageIndex) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => CustomerMainScreen(index: index)),
                );
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Store',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),      body: _pages[_pageIndex],
    );
  }
}
