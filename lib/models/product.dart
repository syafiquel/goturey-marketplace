import 'package:cloud_firestore/cloud_firestore.dart';

class FeatureImage {
  final String url;
  final String altText;

  FeatureImage({required this.url, required this.altText});

  factory FeatureImage.fromJson(dynamic json) {
    if (json is String) {
      return FeatureImage(url: json, altText: '');
    }
    return FeatureImage(
      url: json['url'] ?? '',
      altText: json['altText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'altText': altText,
    };
  }
}

class ProductVariant {
  final String type;
  final int stock;
  final String name;
  final double price_adult;
  final double price_child;
  final List<String> url;
  final double perEntry;

  ProductVariant({
    required this.type,
    required this.stock,
    required this.name,
    required this.price_adult,
    required this.price_child,
    required this.url,
    required this.perEntry,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    List<String> imageUrls = [];
    if (json.containsKey('url') && json['url'] is List) {
      imageUrls = (json['url'] as List).map((e) => e.toString()).toList();
    } else if (json.containsKey('variantImage') && json['variantImage'] is String) {
      imageUrls = [json['variantImage'] as String];
    }

    return ProductVariant(
      type: json['type'] ?? '',
      stock: json['stock'] ?? 0,
      name: json['name'] ?? '',
      price_adult: (json['priceAdult'] as num?)?.toDouble() ?? 0.0,
      price_child: (json['priceChild'] as num?)?.toDouble() ?? 0.0,
      perEntry: (json['perEntry'] as num?)?.toDouble() ?? 0.0,
      url: imageUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'stock': stock,
      'name': name,
      'price_adult': price_adult,
      'price_child': price_child,
      'perEntry': perEntry,
      'url': url,
    };
  }
}

class Product {
  final String? productId; // New field
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
  double get price => variants.isNotEmpty ? variants.first.price_adult : 0.0;

  Product(
      {this.productId, // New field
      required this.name,
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
      productId: json['productId'], // Populate new field
      firestoreId: doc.id, // Store the document ID
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      featureImages: (json['featureImages'] as List?)
              ?.map((i) => FeatureImage.fromJson(i))
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

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'category': category,
      'description': description,
      'featureImages': featureImages.map((e) => e.toJson()).toList(),
      'variants': variants.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFav': isFav,
      'isPublished': isPublished,
    };
  }

  factory Product.fromMap(Map<String, dynamic> json, {String? firestoreId}) {
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
      productId: json['productId'], // Populate new field
      firestoreId: firestoreId, // Store the document ID
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      featureImages: (json['featureImages'] as List?)
              ?.map((i) => FeatureImage.fromJson(i))
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