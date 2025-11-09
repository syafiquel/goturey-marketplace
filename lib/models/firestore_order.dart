
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreOrder {
  final String id;
  final String orderId;
  final String customerId;
  final String customerEmail;
  final String customerName;
  final List<dynamic> products;
  final double totalAmount;
  final String currency;
  final Timestamp orderDate;
  final String paymentReference;
  final String paymentStatus;
  final bool isDelivered;
  final bool isApproved;
  final String? chipInPurchaseId;

  FirestoreOrder({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerEmail,
    required this.customerName,
    required this.products,
    required this.totalAmount,
    required this.currency,
    required this.orderDate,
    required this.paymentReference,
    required this.paymentStatus,
    required this.isDelivered,
    required this.isApproved,
    this.chipInPurchaseId,
  });

  factory FirestoreOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FirestoreOrder(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerName: data['customerName'] ?? '',
      products: data['products'] ?? [],
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      currency: data['currency'] ?? '',
      orderDate: data['orderDate'] ?? Timestamp.now(),
      paymentReference: data['paymentReference'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      isDelivered: data['isDelivered'] ?? false,
      isApproved: data['isApproved'] ?? false,
      chipInPurchaseId: data['chipInPurchaseId'],
    );
  }
}
