import 'package:flutter/material.dart';

class GenericBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const GenericBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: Colors.blueAccent, // Default selected color
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: onTap,
      items: items,
    );
  }
}
