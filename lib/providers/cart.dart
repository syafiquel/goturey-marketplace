import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:goturey_marketplace/constants/enums/quantity_operation.dart';
import 'package:goturey_marketplace/helpers/shared_prefs.dart' as shared_prefs;

import '../models/cart.dart';

class CartProvider extends ChangeNotifier {
  Map<String, Cart> _cartItems = {};

  CartProvider() {
    loadCartFromPrefs();
  }

  Map<String, Cart> get getCartItems => {..._cartItems};

  // get cart item length
  get getCartQuantity => _cartItems.isEmpty ? 0 : getCartItems.length;

  // is cart empty
  bool isItemEmpty() => _cartItems.isEmpty ? true : false;

  // get cart total amount
  double getCartTotalAmount() {
    double totalAmount = 0.0;

    _cartItems.forEach((key, value) {
      totalAmount += value.price * value.quantity;
    });

    return totalAmount;
  }

  // get product quantity on cart
  int getProductQuantityOnCart(String prodId) {
    int quantity = 0;
    if (_cartItems.containsKey(prodId)) {
      quantity = _cartItems[prodId]!.quantity;
    }

    return quantity;
  }

  // increase quantity
  void increaseQuantity(String prodId) {
    if (_cartItems.containsKey(prodId)) {
      _cartItems[prodId]!.increaseQuantity();
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  // decrease quantity
  void decreaseQuantity(String prodId) {
    if (_cartItems.containsKey(prodId)) {
      if (_cartItems[prodId]!.quantity > 1) {
        _cartItems[prodId]!.decreaseQuantity();
      } else {
        _cartItems.remove(prodId);
      }
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  // increment or decrement product in cart | alternative method - (NOT CURRENTLY USED)
  void toggleQuantity(QuantityOperation operation, String cartId) {
    // another way you can implement this is by making use of the model and creating a method for increment and decrement

    switch (operation) {
      case QuantityOperation.increment:
        _cartItems.update(
          cartId,
          (existingCartItem) => Cart(
            cartId: existingCartItem.cartId,
            prodName: existingCartItem.prodName,
            prodImg: existingCartItem.prodImg,
            prodId: existingCartItem.prodId,
            vendorId: existingCartItem.vendorId,
            quantity: existingCartItem.quantity + 1,
            prodSize: existingCartItem.prodSize,
            price: existingCartItem.price,
            date: existingCartItem.date,
          ),
        );
        break;

      case QuantityOperation.decrement:
        _cartItems.update(
          cartId,
          (existingCartItem) => Cart(
            cartId: existingCartItem.cartId,
            prodId: existingCartItem.prodId,
            prodName: existingCartItem.prodName,
            prodImg: existingCartItem.prodImg,
            vendorId: existingCartItem.vendorId,
            quantity: existingCartItem.quantity - 1,
            prodSize: existingCartItem.prodSize,
            price: existingCartItem.price,
            date: existingCartItem.date,
          ),
        );
        break;
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  // checking if item is on cart
  bool isItemOnCart(String prodId) => _cartItems.containsKey(prodId);

  void addToCart(Cart cartItem) {
    if (isItemOnCart(cartItem.prodId)) {
      increaseQuantity(cartItem.prodId);
    } else {
      _cartItems.putIfAbsent(cartItem.prodId, () => cartItem);
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  // removing item from cart
  void removeFromCart(String prodId) {
    _cartItems.remove(prodId);
    _saveCartToPrefs();
    notifyListeners();
  }

  // clear cart
  void clearCart() {
    _cartItems.clear();
    _saveCartToPrefs();
    notifyListeners();
  }

  void _saveCartToPrefs() {
    final cartJson = json.encode(
      _cartItems.map((key, value) => MapEntry(key, value.toJson())),
    );
    shared_prefs.saveCart(cartJson);
  }

  void loadCartFromPrefs() async {
    final cartJson = await shared_prefs.loadCart();
    if (cartJson != null) {
      final Map<String, dynamic> decodedCart = json.decode(cartJson);
      _cartItems = decodedCart.map(
        (key, value) => MapEntry(
          key,
          Cart.fromJson(value),
        ),
      );
      notifyListeners();
    }
  }
}
