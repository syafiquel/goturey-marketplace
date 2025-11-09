import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goturey_marketplace/providers/order.dart';
import 'package:intl/intl.dart';

import '../../constants/enums/yes_no.dart';
import '../../models/order.dart';
import '../widgets/k_cached_image.dart';
import '../widgets/text_action.dart';

class SingleOrderItem extends StatefulWidget {
  const SingleOrderItem({
    super.key,
    required this.id,
    required this.totalAmount,
    required this.date,
    required this.orders,
  });

  final String id;
  final double totalAmount;
  final DateTime date;
  final OrderItem orders;

  @override
  State<SingleOrderItem> createState() => _SingleOrderItemState();
}

class _SingleOrderItemState extends State<SingleOrderItem> {
  var _isExpanded = false;

  // Helper method to format date consistently
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mma').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            'Confirm Deletion',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this order from your history?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            textAction('Yes', YesNo.yes, context),
            textAction('No', YesNo.no, context),
          ],
        ),
      ),
      onDismissed: (direction) =>
          Provider.of<OrderProvider>(context, listen: false)
              .removeOrder(widget.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12.0),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: Container(
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
              leading: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              title: Text(
                'RM ${widget.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              subtitle: Text(
                _formatDate(widget.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
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
              Container(
                height: min(
                  widget.orders.products.length * 70.0,
                  180.0,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: widget.orders.products.length,
                  itemBuilder: (context, index) {
                    final product = widget.orders.products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          KCachedImage(
                            image: product.prodImg,
                            isCircleAvatar: true,
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.prodName,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Quantity: ${product.quantity}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'RM ${product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
