import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String title;
  final String icon;
  final int order;

  Category({
    required this.id,
    required this.title,
    required this.icon,
    required this.order,
  });

  factory Category.fromJson(QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    return Category(
      id: data['category'] ?? item.id,
      title: data['title'] ?? data['category'] ?? 'Category',
      icon: data['icon'] ?? 'category',
      order: data['order'] ?? 0,
      isActive: data['is_active'] ?? true,
    );
  }
}
