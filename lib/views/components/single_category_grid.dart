import 'package:flutter/material.dart';

import '../../helpers/icon_mapper.dart';
import '../../models/category.dart';
import '../../resources/font_manager.dart';
import '../../resources/styles_manager.dart';

class SingleCategoryGridItem extends StatelessWidget {
  const SingleCategoryGridItem({
    super.key,
    required this.category,
    required this.size,
  });

  final Category category;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: isDesktop ? 80 : 70,
            width: isDesktop ? 80 : 70,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: category.isActive
                ? Icon(
                    iconFromName(category.icon),
                    size: isDesktop ? 38 : 34,
                    color: const Color(0xFFef2b7c),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://placehold.co/360x360?text=Coming+Soon',
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            category.title,
            textAlign: TextAlign.center,
            style: getMediumStyle(
              color: Colors.black,
              fontSize: isDesktop ? FontSize.s16 : FontSize.s14,
            ),
          ),
        ],
      ),
    );
  }
}
