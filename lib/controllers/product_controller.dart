import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/request_result.dart';
import '../models/success.dart';

class ProductController {
  final firebase = FirebaseFirestore.instance;

  Future<RequestResult> createProduct({required Product product}) async {
    // TODO: Refactor this method to support the new Product model with variants.
    // The current implementation is commented out to prevent compilation errors.
    /*
    try {
      firebase.collection('products').doc(product.firestoreId).set({
        // ... map fields from the new product model
      });

      return RequestResult.success(Success(msg: 'Upload successfully'));
    } on FirebaseException catch (e) {
      return RequestResult.error('Error with uploading');
    } catch (e) {
      return RequestResult.error('Error occurred!');
    }
    */
    print("createProduct is not implemented");
    return RequestResult.error('This feature is temporarily disabled.');
  }

  // edit product
  Future<RequestResult> editProduct({required Product product}) async {
    // TODO: Refactor this method to support the new Product model with variants.
    // The current implementation is commented out to prevent compilation errors.
    /*
    try {
      firebase.collection('products').doc(product.firestoreId).update({
        // ... map fields from the new product model
      });

      return RequestResult.success(Success(msg: 'Upload successfully'));
    } on FirebaseException catch (e) {
      return RequestResult.error('Error with uploading');
    } catch (e) {
      return RequestResult.error('Error occurred!');
    }
    */
    print("editProduct is not implemented");
    return RequestResult.error('This feature is temporarily disabled.');
  }
}
