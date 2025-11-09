import 'package:shared_preferences/shared_preferences.dart';

import '../constants/enums/account_type.dart';

// save cart
Future<void> saveCart(String cartJson) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('cart', cartJson);
}

// load cart
Future<String?> loadCart() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('cart');
}
