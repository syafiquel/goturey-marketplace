import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goturey_marketplace/models/checked_out_item.dart';
import 'package:goturey_marketplace/resources/styles_manager.dart';

import '../../constants/color.dart';
import '../../constants/firebase_refs/collections.dart';
import '../../models/buyer.dart';
import '../../resources/assets_manager.dart';
import '../../resources/font_manager.dart';
import '../widgets/item_row.dart';
import 'package:intl/intl.dart' as intl;

import '../widgets/k_cached_image.dart';

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

  // fetch customer details
  Future<void> fetchCustomerDetails() async {
    await FirebaseCollections.customersCollection
        .doc(widget.checkoutItem.customerId)
        .get()
        .then((DocumentSnapshot data) {
      setState(() {
        buyer = Buyer.fromJson(data);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            leading: CachedNetworkImage(
              imageUrl: widget.checkoutItem.prodImg,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 30,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => const CircleAvatar(
                backgroundImage: AssetImage(
                  AssetManager.placeholderImg,
                ),
              ),
              errorWidget: (context, url, error) => const CircleAvatar(
                backgroundImage: AssetImage(
                  AssetManager.placeholderImg,
                ),
              ),
            ),
            title: Text(widget.checkoutItem.prodName),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${widget.checkoutItem.prodPrice}'),
                Text('Quantity: ${widget.checkoutItem.prodQuantity}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() {
                _isExpanded = !_isExpanded;
              }),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ItemRow(
                    value: widget.checkoutItem.prodPrice.toStringAsFixed(2),
                    title: 'Product Price: ',
                  ),
                  ItemRow(
                    value: widget.checkoutItem.isDelivered ? 'Yes' : 'No',
                    title: 'Delivered: ',
                  ),
                  ItemRow(
                    value: widget.checkoutItem.prodSize,
                    title: 'Selected Size: ',
                  ),
                  ItemRow(
                    value: widget.checkoutItem.prodQuantity.toString(),
                    title: 'Product Quantity: ',
                  ),
                  ItemRow(
                    value:
                        intl.DateFormat.yMMMEd().format(widget.checkoutItem.date),
                    title: 'Order Date: ',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Customer Details:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ItemRow(
                    value: buyer.fullname,
                    title: 'Name: ',
                  ),
                  ItemRow(
                    value: buyer.email,
                    title: 'Email: ',
                  ),
                  ItemRow(
                    value: buyer.address,
                    title: 'Address: ',
                  ),
                  ItemRow(
                    value: buyer.phone,
                    title: 'Phone: ',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
