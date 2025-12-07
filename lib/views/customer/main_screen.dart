import 'package:flutter/material.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';
import 'categories/categories.dart';
import 'me_screen.dart'; // Import MeScreen
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
    CartScreen(),
    MeScreen(),
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
            bottomNavigationBar: MainBottomNav(
              currentIndex: _pageIndex,
              userType: UserType.customer,
              onTap: (index) {
                setNewPage(index);
              },
            ),      body: _pages[_pageIndex],
    );
  }
}
