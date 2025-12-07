import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart'; // Import CloudinaryService
import 'package:uuid/uuid.dart'; // Import uuid package

class ProductData extends ChangeNotifier {
  bool _isProductAttributesSubmitted = false;
  bool _isProductShippingInfoSubmitted = false;
  bool _isProductGeneralInfoSubmitted = false;

  final Uuid _uuid = const Uuid(); // Initialize Uuid

  // updateProductAttributesState
  void updateProductAttributeState() {
    _isProductAttributesSubmitted = !_isProductAttributesSubmitted;
    notifyListeners();
  }

  // updateProductShippingInfoState
  void updateProductShippingInfoState() {
    _isProductShippingInfoSubmitted = !_isProductShippingInfoSubmitted;
    notifyListeners();
  }

  // updateProductGeneralInfoState
  void updateProductGeneralInfoState() {
    _isProductGeneralInfoSubmitted = !_isProductGeneralInfoSubmitted;
    notifyListeners();
  }

  bool isDoneSubmittingDetails() {
    bool status = false;
    if (_isProductAttributesSubmitted &&
        _isProductGeneralInfoSubmitted &&
        _isProductShippingInfoSubmitted &&
        productData['imgUrls'] != null) {
      status = true;
    }
    return status;
  }

  // get product attributes submit status
  get isProductAttributesSubmittedStatus => _isProductAttributesSubmitted;

  // get product general info submit status
  get isProductGeneralInfoSubmittedStatus => _isProductGeneralInfoSubmitted;

  // get product shipping info status
  get isProductShippingInfoSubmittedStatus => _isProductShippingInfoSubmitted;

  Map<String, dynamic> productData = {};

  void resetProductData() {
    productData = {};
    notifyListeners();
  }

  // Helper method to upload images and process variants
  Future<void> _processImagesAndVariants({
    required List<XFile> featureImages,
    required List<Map<String, dynamic>> variants,
  }) async {
    // Upload feature images
    List<Map<String, dynamic>> uploadedFeatureImagesData = [];
    for (XFile imageFile in featureImages) {
      String? imageUrl = await CloudinaryService.uploadImage(imageFile);
      if (imageUrl != null) {
        uploadedFeatureImagesData.add({'url': imageUrl, 'altText': ''}); // Store as map
      }
    }
    productData['featureImages'] = uploadedFeatureImagesData;

    // Process variants and upload variant images
    List<Map<String, dynamic>> processedVariants = [];
    for (Map<String, dynamic> variant in variants) {
      XFile? variantImageFile = variant['image'] as XFile?;
      String? variantImageUrl;
      if (variantImageFile != null) {
        variantImageUrl = await CloudinaryService.uploadImage(variantImageFile);
      }

      processedVariants.add({
        'name': variant['name'],
        'stock': variant['stock'],
        'type': variant['type'],
        'priceAdult': variant['priceAdult'],
        'priceChild': variant['priceChild'],
        'url': variantImageUrl != null ? [variantImageUrl] : [], // Store the uploaded URL as a list
      });
    }
    productData['variants'] = processedVariants;
  }

  // update product general data
  Future<void> updateProductGeneralData({
    String? productName,
    String? category,
    String? description,
    List<XFile>? featureImages, // Changed to List<XFile>
    List<Map<String, dynamic>>? variants, // Changed to List<Map<String, dynamic>>
    String? vendorId,
  }) async {
    // Generate a unique ID for the product
    final String productId = _uuid.v4();
    productData['productId'] = productId;

    productData['name'] = productName;
    productData['category'] = category;
    productData['description'] = description;
    productData['vendorId'] = vendorId;

    if (featureImages != null && variants != null) {
      await _processImagesAndVariants(
        featureImages: featureImages,
        variants: variants,
      );
    }

    notifyListeners();
  }

  // update product shipping info
  updateProductShippingInfo({bool? isCharging, double? billingAmount}) {
    productData['isCharging'] = isCharging;
    productData['billingAmount'] = billingAmount;
    notifyListeners();
  }

  // update product attributes info
  updateProductAttributesInfo(
      {String? brandName, List<String>? sizesAvailable}) {
    productData['brandName'] = brandName;
    productData['sizesAvailable'] = sizesAvailable;

    notifyListeners();
  }

  // update product images
  updateProductImg({List<String>? imgUrls}) {
    productData['imgUrls'] = imgUrls;
    notifyListeners();
  }

  // clear product images
  clearProductImg() {
    productData['imgUrls'] = null;
    notifyListeners();
  }

  // checking if product images is null
  bool isProductImagesNull() => productData['imgUrls'] == null ? true : false;
}
