import 'package:flutter/material.dart';
import 'package:goturey_marketplace/views/components/generic_bottom_nav.dart';
import 'package:goturey_marketplace/views/vendor/profile/profile.dart';
import 'package:goturey_marketplace/views/vendor/dashboard.dart';
import 'package:goturey_marketplace/views/vendor/products/view_all.dart';
import '../../constants/color.dart';
import 'orders/orders.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key, required this.index});
  final int index;

  // This is a test comment to force recompilation.


  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  var _pageIndex = 0;

  final List<Widget> _pages = const [
    VendorDashboard(),
    OrdersScreen(),
    ProductScreen(),
    ProfileScreen()
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
        onTap: setNewPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: _pages[_pageIndex],
    );
  }

}
