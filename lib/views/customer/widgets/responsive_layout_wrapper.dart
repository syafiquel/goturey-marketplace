import 'package:flutter/material.dart';
import 'package:goturey_marketplace/views/customer/main_screen.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';

class ResponsiveLayoutWrapper extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const ResponsiveLayoutWrapper({
    Key? key,
    required this.child,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  State<ResponsiveLayoutWrapper> createState() => _ResponsiveLayoutWrapperState();
}

class _ResponsiveLayoutWrapperState extends State<ResponsiveLayoutWrapper> {
  bool _isSideNavExpanded = true;

  void _toggleSideNav() {
    setState(() {
      _isSideNavExpanded = !_isSideNavExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    if (!isDesktop) {
      // On mobile, just return the child without wrapper
      return widget.child;
    }

    // On desktop, wrap with side navigation
    return Row(
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
              // Toggle Button
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
          child: widget.child,
        ),
      ],
    );
  }

  Widget _buildSideNavItem(int index, IconData icon, String label) {
    final isSelected = widget.currentIndex == index;
    
    return InkWell(
      onTap: () {
        // Navigate back to main screen with selected index
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => CustomerMainScreen(index: index),
          ),
          (route) => false,
        );
      },
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

