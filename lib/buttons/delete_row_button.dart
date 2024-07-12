import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class RemoveRowButton extends StatelessWidget {
  final int index;
  final VoidCallback onPressed;
  final logger = Logger();

  RemoveRowButton({super.key,
    required this.index,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          logger.d('Removing row at index: $index');
          onPressed();
        },
      ),
    );
  }
}
