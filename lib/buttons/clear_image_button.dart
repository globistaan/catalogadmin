import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../model/grid_item.dart';

class ClearImageButton extends StatelessWidget {
  final void Function(GridItem item) clearImage;
  final GridItem item;  // Add a GridItem field to hold the item to clear the image from
  final logger = Logger();

  ClearImageButton({
    super.key,
    required this.clearImage,
    required this.item,  // Make sure to pass item to the widget
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -4,
      right: -4,
      child: InkWell(
        onTap: () {
          logger.d('Clearing image for item: ${item.itemId}');  // Log the action
          clearImage(item);  // Call the clearImage function
        },
        child: const Icon(
          Icons.close,
          color: Colors.red,
          size: 20,
        ),
      ),
    );
  }
}
