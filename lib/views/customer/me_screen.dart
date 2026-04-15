
import 'package:flutter/material.dart';
import 'package:goturey_marketplace/controllers/auth_controller.dart';
import 'package:goturey_marketplace/views/auth/customer/customer_auth.dart';
import 'package:goturey_marketplace/views/customer/relational_screens/wishlist_products.dart';
import 'package:goturey_marketplace/views/customer/transactions/transaction_history_screen.dart';
import 'package:goturey_marketplace/views/widgets/are_you_sure_dialog.dart';
import 'package:goturey_marketplace/views/widgets/main_app_bar.dart';
import 'package:goturey_marketplace/views/customer/widgets/main_bottom_nav.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
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
            // App Bar with consistent styling
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFFF6F0FF),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'My Profile',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
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
            // Content
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 800 : double.infinity,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildProfileCard(
                          context,
                          icon: Icons.history,
                          title: 'Transaction History',
                          subtitle: 'View your order history',
                          color: const Color(0xFF0095a0),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TransactionHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildProfileCard(
                          context,
                          icon: Icons.favorite,
                          title: 'Wishlist',
                          subtitle: 'Your saved products',
                          color: const Color(0xFFef2b7c),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const WishListProducts(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildProfileCard(
                          context,
                          icon: Icons.lock,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          color: const Color(0xFF0095a0),
                          onTap: () {
                            // Add change password functionality here
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildProfileCard(
                          context,
                          icon: Icons.logout,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
                          color: const Color(0xFFef2b7c),
                          onTap: () {
                            areYouSureDialog(
                              title: 'Logout',
                              content: 'Are you sure you want to logout?',
                              context: context,
                              action: () async {
                                await AuthController().signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const CustomerAuthScreen()),
                                  (route) => false,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
