import 'package:flutter/material.dart';

enum UserType { customer, vendor }

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isProductDetailsPage;
  final UserType userType;
  final Function(int)? onTap;

  const MainBottomNav({
    Key? key,
    this.currentIndex = 0,
    this.isProductDetailsPage = false,
    this.userType = UserType.customer,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> customerItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.category),
        label: 'Categories',
      ),
      BottomNavigationBarItem(
        icon: Transform.scale(
          scale: 1.5, // Enlarge the icon
          child: const Icon(Icons.store),
        ),
        label: 'Store',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Cart',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    List<BottomNavigationBarItem> vendorItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.explore),
        label: 'Explore',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Cart',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Account',
      ),
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: userType == UserType.customer ? customerItems : vendorItems,
      type: BottomNavigationBarType.fixed, // Ensures all items are visible
      onTap: onTap,
    );
  }
}
