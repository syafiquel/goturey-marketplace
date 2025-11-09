import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:goturey_marketplace/constants/firebase_refs/collections.dart';
import 'package:goturey_marketplace/models/checked_out_item.dart';
import '../../../../constants/color.dart';
import '../../../../resources/assets_manager.dart';
import '../../../../resources/font_manager.dart';
import '../../../../resources/styles_manager.dart';
import '../../../components/single_vendor_checkout_list_tile.dart';
import '../../../widgets/are_you_sure_dialog.dart';
import '../../../widgets/loading_widget.dart';

class UnDeliveredOrders extends StatefulWidget {
  const UnDeliveredOrders({super.key});

  @override
  State<UnDeliveredOrders> createState() => _UnDeliveredOrdersState();
}

class _UnDeliveredOrdersState extends State<UnDeliveredOrders> {
  var userId = FirebaseAuth.instance.currentUser!.uid;

  // toggle delivery dialog
  void toggleDeliveryDialog(CheckedOutItem checkedOutItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          checkedOutItem.isDelivered ? 'Cancel Delivery' : 'Deliver Product',
          style: getMediumStyle(
            color: Colors.black,
            fontSize: FontSize.s16,
          ),
        ),
        content: Text(
          'Are you sure you want to ${checkedOutItem.isDelivered ? 'cancel delivery of' : 'deliver'} ${checkedOutItem.prodName}',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => toggleDelivery(
                checkedOutItem.orderId, checkedOutItem.isDelivered),
            child: const Text('Yes'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  // toggleDelivery
  Future<void> toggleDelivery(String orderId, bool isDelivered) async {
    await FirebaseCollections.ordersCollection.doc(orderId).update({
      'isDelivered': !isDelivered,
    }).whenComplete(
      () {

        // increment vendor balance
        FirebaseCollections.ordersCollection
            .doc(orderId)
            .get()
            .then((DocumentSnapshot doc) {
          double totalAmount = 0.0;

          // update totalAmount
          totalAmount += doc['prodPrice'] * doc['prodQuantity'];

          // updating vendor's balance
          FirebaseCollections.vendorsCollection
              .doc(userId)
              .get()
              .then((DocumentSnapshot data) {
            FirebaseCollections.vendorsCollection.doc(userId).update({
              'balanceAvailable': data['balanceAvailable'] + totalAmount,
            });
          });
        });

        // pop out
        Navigator.of(context).pop();
      },
    );
  }

  // delete product dialog
  void deleteProductDialog(CheckedOutItem checkOutItem) {
    areYouSureDialog(
      title: 'Delete Product',
      content: 'Are you sure you want to delete ${checkOutItem.prodName}',
      context: context,
      action: deleteProduct,
      isIdInvolved: true,
      id: checkOutItem.prodId,
    );
  }

  // delete product
  Future<void> deleteProduct(String prodId) async {
    await FirebaseCollections.ordersCollection.doc(prodId).delete();
  }

  // deliver all items dialog
  void deliverAllProductsDialog() {
    areYouSureDialog(
      title: 'Deliver all product',
      content: 'Are you sure you want to deliver all items?',
      context: context,
      action: deliverAll,
    );
  }

  // deliver all items
  Future<void> deliverAll() async {
    await FirebaseCollections.ordersCollection
        .where('isDelivered', isEqualTo: false)
        .where('isApproved', isEqualTo: true)
        .get()
        .then(
      (QuerySnapshot data) {
        double totalAmount = 0.0;

        for (var doc in data.docs) {
          // update totalAmount
          totalAmount += doc['prodPrice'] * doc['prodQuantity'];

          FirebaseCollections.ordersCollection.doc(doc['orderId']).update({
            'isDelivered': true,
          });
        }

        // updating vendor's balance
        FirebaseCollections.vendorsCollection
            .doc(userId)
            .get()
            .then((DocumentSnapshot data) {
          FirebaseCollections.vendorsCollection.doc(userId).update({
            'balanceAvailable': data['balanceAvailable'] + totalAmount,
          });
        });
      },
    ).whenComplete(
      () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> ordersStream = FirebaseCollections.ordersCollection
        .where('vendorId', isEqualTo: userId)
        .where('isDelivered', isEqualTo: false)
        .where('isApproved', isEqualTo: true)
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AssetManager.warningImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('An error occurred!'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingWidget(size: 30),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AssetManager.addImage,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Undelivered Order list is empty. Approve orders so they can appear here',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final item = snapshot.data!.docs[index];

              CheckedOutItem checkedOutItem = CheckedOutItem.fromJson(item);

              return Slidable(
                key: const ValueKey(0),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      padding: const EdgeInsets.only(right: 3),
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (context) =>
                          deleteProductDialog(checkedOutItem),
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (context) =>
                          toggleDeliveryDialog(checkedOutItem),
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      icon: checkedOutItem.isDelivered
                          ? Icons.cancel
                          : Icons.check_circle,
                      label: checkedOutItem.isDelivered ? 'Cancel' : 'Deliver',
                    ),
                  ],
                ),
                child:
                    SingleVendorCheckOutListTile(checkoutItem: checkedOutItem),
              );
            },
          );
        },
      ),
      bottomSheet: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AssetManager.warningImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('An error occurred!'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingWidget(size: 30),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const SizedBox.shrink();
          }

          int checkedOutList = 0;
          double totalAmount = 0.0;

          checkedOutList = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            totalAmount += doc['prodPrice'] * doc['prodQuantity'];
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8.0,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Price',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.orange.shade600,
                                    fontWeight: FontWeight.w700,
                                  ),
                            )
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              Text(
                                '${checkedOutList} ${checkedOutList > 1 ? "items" : "item"}',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () => deliverAllProductsDialog(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delivery_dining, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Deliver All',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
