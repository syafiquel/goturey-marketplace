import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:goturey_marketplace/constants/firebase_refs/collections.dart';
import 'package:goturey_marketplace/views/vendor/products/edit.dart';
import '../../../../models/product.dart';
import '../../../../resources/assets_manager.dart';
import '../../../../resources/font_manager.dart';
import '../../../../resources/styles_manager.dart';
import '../../../components/single_product_grid.dart'; // Import SingleProductGridItem
import '../../../widgets/are_you_sure_dialog.dart';
import '../../../widgets/loading_widget.dart';
import '../single_product.dart';

class PublishedProducts extends StatefulWidget {
  const PublishedProducts({super.key});

  @override
  State<PublishedProducts> createState() => _PublishedProductsState();
}

class _PublishedProductsState extends State<PublishedProducts> {
  var userId = FirebaseAuth.instance.currentUser!.uid;

  // delete product dialog
  void deleteProductDialog(Product product) {
    areYouSureDialog(
      title: 'Delete Product',
      content: 'Are you sure you want to delete ${product.name}',
      context: context,
      action: () => deleteProduct(product.firestoreId!),
    );
  }

  // delete product
  Future<void> deleteProduct(String prodId) async {
    await FirebaseCollections.productsCollection.doc(prodId).delete();
    Navigator.of(context).pop(); // Close dialog
  }

  // toggle publish product dialog
  void togglePublishProductDialog(Product product) {
    areYouSureDialog(
      title: product.isPublished ? 'Unpublish Product' : 'Publish Product',
      content: 'Are you sure you want to ${product.isPublished ? 'unpublish' : 'publish'} ${product.name}',
      context: context,
      action: () => togglePublishProduct(product.firestoreId!, product.isPublished),
    );
  }

  // toggle publish product
  Future<void> togglePublishProduct(String prodId, bool isPublished) async {
    await FirebaseCollections.productsCollection.doc(prodId).update({
      'isPublished': !isPublished,
    });
    Navigator.of(context).pop(); // Close dialog
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> productsStream = FirebaseCollections.productsCollection
        .where('vendorId', isEqualTo: userId)
        .where('isPublished', isEqualTo: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: productsStream,
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
                const Text('No published products found.'),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final item = snapshot.data!.docs[index];
            Product product = Product.fromJson(item);
            Size size = MediaQuery.of(context).size;

            return Slidable(
              key: ValueKey(product.firestoreId),
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    padding: const EdgeInsets.only(right: 3),
                    borderRadius: BorderRadius.circular(10),
                    onPressed: (context) => deleteProductDialog(product),
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
                    onPressed: (context) => togglePublishProductDialog(product),
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    icon: product.isPublished
                        ? Icons.visibility_off
                        : Icons.visibility,
                    label: product.isPublished ? 'Unpublish' : 'Publish',
                  ),
                  SlidableAction(
                    borderRadius: BorderRadius.circular(10),
                    onPressed: (context) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VendorEditProduct(product: product),
                      ),
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VendorProductDetailsScreen(product: product),
                  ),
                ),
                child: SingleProductGridItem(
                  product: product,
                  size: size,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
