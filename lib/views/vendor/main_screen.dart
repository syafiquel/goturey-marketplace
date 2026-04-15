import 'package:flutter/material.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart'; // Reusing MainBottomNav
import 'package:goturey_marketplace/views/vendor/profile/profile.dart';
import 'package:goturey_marketplace/views/vendor/dashboard.dart';
import 'package:goturey_marketplace/views/vendor/products/view_all.dart';
import '../../constants/color.dart';
import 'orders/orders.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({
    super.key, 
    required this.index,
    this.storeName,
  });
  final int index;
  final String? storeName;

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  var _pageIndex = 0;

  List<Widget> get _pages => [
    VendorDashboard(storeName: widget.storeName),
    const OrdersScreen(),
    const ProductScreen(),
    const ProfileScreen()
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
        userType: UserType.vendor,
        onTap: setNewPage,
      ),
      body: _pages[_pageIndex],
    );
  }

}
