import 'package:flutter/material.dart';
import '../../constants/color.dart';
import '../../resources/font_manager.dart';
import '../../resources/styles_manager.dart';

class BuildDashboardContainer extends StatelessWidget {
  BuildDashboardContainer({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.index = 0,
    this.isBtn = true,
    this.onPressed,
  }) : super(key: key);
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  int index;
  bool isBtn;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 50,
                      child: FittedBox(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: getMediumStyle(
                            fontSize: FontSize.s14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      value,
                      style: getBoldStyle(
                        fontSize: FontSize.s16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(icon, color: accentColor, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            isBtn
                ? ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: onPressed,
                    child: FittedBox(
                      child: Text(
                        'view more',
                        style: getRegularStyle(color: accentColor),
                      ),
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
