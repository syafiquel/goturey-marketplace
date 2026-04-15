import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../helpers/icon_mapper.dart';
import '../../models/category.dart';
import '../../resources/values_manager.dart';

class SingleCategorySection extends StatelessWidget {
  const SingleCategorySection({
    Key? key,
    required this.item,
    required this.index,
    required this.setCurrentCategory,
    required this.currentCategoryIndex,
  }) : super(key: key);
  final Category item;
  final int index;
  final Function setCurrentCategory;
  final int currentCategoryIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 13,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setCurrentCategory(index, item.title),
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: currentCategoryIndex == index ? accentColor : boxBg,
                borderRadius: BorderRadius.circular(AppSize.s12),
                border: Border.all(
                  color: currentCategoryIndex == index
                      ? accentColor
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  iconFromName(item.icon),
                  color: currentCategoryIndex == index
                      ? Colors.white
                      : iconColor,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSize.s4), // Reduced spacing
          Expanded(
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // Allow text to wrap to a second line if needed
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
