import 'package:flutter/material.dart';

class ImageUploadTab extends StatelessWidget {
  const ImageUploadTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: This screen is temporarily disabled due to data model changes.
    // Refactor this to use the new Product model with variants.
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'This feature is temporarily under construction due to a data model update.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
