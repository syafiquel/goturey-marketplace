import 'package:flutter/material.dart';
import '../../constants/enums/yes_no.dart';
import '../../constants/enums/status.dart';
import '../../models/cart.dart';
import '../../providers/cart.dart';
import '../widgets/k_cached_image.dart';
import '../widgets/msg_snackbar.dart';
import '../widgets/text_action.dart';

class SingleCartItem extends StatelessWidget {
  const SingleCartItem({
    Key? key,
    required this.item,
    required this.cartData,
  }) : super(key: key);

  final Cart item;
  final CartProvider cartData;

  @override
  Widget build(BuildContext context) {
    // snack bar warning msg
    void showWarningMsg({required String message}) {
      displaySnackBar(
        status: Status.error,
        message: message,
        context: context,
      );
    }

    // The cart item no longer fetches full product details, so quantity check is removed.
    // A more robust solution would involve checking against a provider that holds stock info.
    void incrementQuantity() {
      cartData.increaseQuantity(item.prodId);
    }

    void decrementQuantity() {
      if (item.quantity > 1) {
        cartData.decreaseQuantity(item.prodId);
      } else {
        showWarningMsg(message: 'Ops! Item quantity can\'t go any lower');
      }
    }

    return Dismissible(
      key: ValueKey(item.cartId), // Use cartId for the key
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          elevation: 3,
          title: Text(
            'Are you sure?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Do you want to remove ${item.prodName} from cart?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            textAction('Yes', YesNo.yes, context),
            textAction('No', YesNo.no, context),
          ],
        ),
      ),
      onDismissed: (direction) => cartData.removeFromCart(item.prodId),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: KCachedImage(
              image: item.prodImg,
              isCircleAvatar: true,
              radius: 25,
            ),
            title: Text(item.prodName, style: Theme.of(context).textTheme.titleSmall),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RM ${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: decrementQuantity,
                      child: const CircleAvatar(
                        radius: 15,
                        child: Icon(Icons.remove, size: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('${item.quantity}', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    GestureDetector(
                      onTap: incrementQuantity,
                      child: const CircleAvatar(
                        radius: 15,
                        child: Icon(Icons.add, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
