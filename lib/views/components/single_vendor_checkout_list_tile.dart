import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goturey_marketplace/models/buyer.dart';
import 'package:goturey_marketplace/models/checked_out_item.dart';
import 'package:goturey_marketplace/models/product.dart';
import 'package:intl/intl.dart' as intl;

import '../../constants/firebase_refs/collections.dart';
import '../../resources/assets_manager.dart';
import '../widgets/item_row.dart';

class SingleVendorCheckOutListTile extends StatefulWidget {
  const SingleVendorCheckOutListTile({
    super.key,
    required this.checkoutItem,
  });

  final CheckedOutItem checkoutItem;

  @override
  State<SingleVendorCheckOutListTile> createState() =>
      _SingleVendorCheckOutListTileState();
}

class _SingleVendorCheckOutListTileState
    extends State<SingleVendorCheckOutListTile> {
  Buyer buyer = Buyer.initial();
  var _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomerDetails();
  }

  Future<void> _fetchCustomerDetails() async {
    if (widget.checkoutItem.customerId.isEmpty) return;
    try {
      final data = await FirebaseCollections.customersCollection
          .doc(widget.checkoutItem.customerId)
          .get();
      if (mounted) {
        setState(() {
          buyer = Buyer.fromJson(data);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in widget.checkoutItem.products) {
      ProductVariant? variant;
      try {
        variant = item.product.variants
            .firstWhere((v) => v.name == item.variantName);
      } catch (e) {
        variant =
            item.product.variants.isNotEmpty ? item.product.variants.first : null;
      }
      final price = variant?.price_adult ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: const Icon(Icons.receipt_long, size: 40, color: Colors.blueGrey),
            title: Text(
              'Order #${widget.checkoutItem.orderId.substring(0, 8)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                'By ${buyer.fullname}\nOn ${intl.DateFormat.yMMMd().format(widget.checkoutItem.date)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('${widget.checkoutItem.products.length} items'),
              ],
            ),
            onTap: () => setState(() {
              _isExpanded = !_isExpanded;
            }),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.checkoutItem.products.length,
                    itemBuilder: (context, index) {
                      final orderItem = widget.checkoutItem.products[index];
                      ProductVariant? variant;
                      try {
                        variant = orderItem.product.variants
                            .firstWhere((v) => v.name == orderItem.variantName);
                      } catch (e) {
                        variant = orderItem.product.variants.isNotEmpty
                            ? orderItem.product.variants.first
                            : null;
                      }

                      final price = variant?.price_adult ?? 0.0;
                      final imageUrl = variant?.url.isNotEmpty == true
                          ? variant!.url.first
                          : orderItem.product.featureImages.isNotEmpty
                              ? orderItem.product.featureImages.first.url
                              : '';

                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            AssetManager.placeholderImg,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            AssetManager.placeholderImg,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(orderItem.product.name),
                        subtitle: Text(
                            '${orderItem.variantName} (x${orderItem.quantity})'),
                        trailing:
                            Text('\$${(price * orderItem.quantity).toStringAsFixed(2)}'),
                      );
                    },
                  ),
                  const Divider(),
                  const Text(
                    'Customer Details:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ItemRow(value: buyer.fullname, title: 'Name: '),
                  ItemRow(value: buyer.email, title: 'Email: '),
                  ItemRow(value: buyer.address, title: 'Address: '),
                  ItemRow(value: buyer.phone, title: 'Phone: '),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
