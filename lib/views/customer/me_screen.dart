
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
    return Scaffold(
      appBar: const MainAppBar(title: 'My Profile'),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction History'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Wishlist'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WishListProducts(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              // Add change password functionality here
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
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
    );
  }
}
