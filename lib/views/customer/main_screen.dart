import 'package:flutter/material.dart';
import 'package:goturey_marketplace/views/auth/customer/customer_auth.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';
import 'categories/categories.dart';
import 'me_screen.dart'; // Import MeScreen
import 'search/search.dart';
import 'store/store.dart';
import 'cart/cart.dart';
import 'home_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({
    super.key, 
    required this.index,
    this.userName,
  });
  final int index;
  final String? userName;

  @override
  State<CustomerMainScreen> createState() => _CustomerMainStateScreen();
}

class _CustomerMainStateScreen extends State<CustomerMainScreen> {
  var _pageIndex = 0;
  bool _isSideNavExpanded = true;
  
  List<Widget> get _pages => [
    CustomerHomeScreen(userName: widget.userName),
    const CategoriesScreen(),
    const StoreScreen(),
    const CartScreen(),
    const MeScreen(),
  ];

  void setNewPage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  void _toggleSideNav() {
    setState(() {
      _isSideNavExpanded = !_isSideNavExpanded;
    });
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text('Please sign in or register to access this feature.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomerAuthScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFef2b7c),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign In / Register'),
            ),
          ],
        );
      },
    );
  }

  void _handleNavigation(int index) {
    // Check if user is trying to access Cart (3) or Profile (4) without authentication
    if (widget.userName == null && (index == 3 || index == 4)) {
      _showAuthDialog();
    } else {
      setNewPage(index);
    }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    if (isDesktop) {
      // Desktop Layout with Side Navigation
      return Scaffold(
        body: Row(
          children: [
            // Side Navigation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isSideNavExpanded ? screenWidth * 0.15 : 80,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Toggle Button - Moved to the right
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          _isSideNavExpanded ? Icons.menu_open : Icons.menu,
                          color: const Color(0xFFef2b7c),
                        ),
                        onPressed: _toggleSideNav,
                      ),
                    ),
                  ),
                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildSideNavItem(0, Icons.home, 'Home'),
                        _buildSideNavItem(1, Icons.category, 'Categories'),
                        _buildSideNavItem(2, Icons.store, 'Store'),
                        _buildSideNavItem(3, Icons.shopping_cart, 'Cart'),
                        _buildSideNavItem(4, Icons.person, 'Profile'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: _pages[_pageIndex],
            ),
          ],
        ),
      );
    } else {
      // Mobile Layout with Bottom Navigation
      return Scaffold(
        bottomNavigationBar: MainBottomNav(
          currentIndex: _pageIndex,
          userType: UserType.customer,
          onTap: (index) {
            _handleNavigation(index);
          },
        ),
        body: _pages[_pageIndex],
      );
    }
  }

  Widget _buildSideNavItem(int index, IconData icon, String label) {
    final isSelected = _pageIndex == index;
    
    return InkWell(
      onTap: () => _handleNavigation(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFef2b7c).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFFef2b7c), width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFef2b7c) : Colors.grey,
              size: 24,
            ),
            if (_isSideNavExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFef2b7c) : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
