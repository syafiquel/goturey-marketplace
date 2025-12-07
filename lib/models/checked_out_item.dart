import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goturey_marketplace/models/product.dart';

class PurchasedItem {
  final Product product;
  final int quantity;
  final String variantName;

  PurchasedItem({
    required this.product,
    required this.quantity,
    required this.variantName,
  });

  factory PurchasedItem.fromMap(Map<String, dynamic> map) {
    var productData = map['product'];
    if (productData is List) {
      productData = productData.isNotEmpty ? productData.first : {};
    }

    return PurchasedItem(
      product: Product.fromMap(productData as Map<String, dynamic>),
      quantity: map['quantity'] as int,
      variantName: map['variantName'] as String,
    );
  }
}

class CheckedOutItem {
  final String orderId;
  final String vendorId;
  final String customerId;
  final List<PurchasedItem> products; // Renamed from 'items'
  final DateTime date;
  final bool isDelivered;
  final bool isApproved;

  CheckedOutItem({
    required this.orderId,
    required this.vendorId,
    required this.customerId,
    required this.products, // Renamed from 'items'
    required this.date,
    required this.isDelivered,
    required this.isApproved,
  });

  CheckedOutItem.fromJson(QueryDocumentSnapshot doc)
      : this(
          orderId: doc['orderId'],
          vendorId: doc['vendorId'],
          customerId: doc['customerId'],
          products: (doc['products'] as List) // Renamed from 'items'
              .map((item) => PurchasedItem.fromMap(item as Map<String, dynamic>))
              .toList(),
          date: doc['date'].toDate(),
          isDelivered: doc['isDelivered'],
          isApproved: doc['isApproved'],
        );
}
