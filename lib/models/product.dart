import 'package:cloud_firestore/cloud_firestore.dart';

class FeatureImage {
  final String url;
  final String altText;

  FeatureImage({required this.url, required this.altText});

  factory FeatureImage.fromJson(Map<String, dynamic> json) {
    return FeatureImage(
      url: json['url'] ?? '',
      altText: json['altText'] ?? '',
    );
  }
}

class ProductVariant {
  final String id;
  final String color;
  final String size;
  final int quantity;
  final double price;
  final List<String> imgUrls;

  ProductVariant({
    required this.id,
    required this.color,
    required this.size,
    required this.quantity,
    required this.price,
    required this.imgUrls,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imgUrls: (json['imgUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class Product {
  final String name;
  final String category;
  final String description;
  final List<FeatureImage> featureImages;
  final List<ProductVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isFav;
  final bool isPublished; // Added

  // Keep a reference to the original document ID
  final String? firestoreId;

  // Add a price getter
  double get price => variants.isNotEmpty ? variants.first.price : 0.0;

  Product(
      {required this.name,
      required this.category,
      required this.description,
      required this.featureImages,
      required this.variants,
      this.createdAt,
      this.updatedAt,
      this.firestoreId,
      this.isFav = false,
      this.isPublished = false}); // Added isPublished

  factory Product.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;

    // Helper function to parse date fields that could be a Timestamp or a String
    DateTime? _parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      }
      if (dateValue is String) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    return Product(
      firestoreId: doc.id, // Store the document ID
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      featureImages: (json['featureImages'] as List?)
              ?.map((i) => FeatureImage.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      variants: (json['variants'] as List?)
              ?.map((i) => ProductVariant.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      isFav: json['isFav'] ?? false,
      isPublished: json['isPublished'] ?? false, // Added isPublished parsing
    );
  }
}