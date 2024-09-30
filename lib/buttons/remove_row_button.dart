import 'package:flutter/material.dart';

class RemoveRowButton extends StatelessWidget {
  final int index;
  final VoidCallback onPressed;

  const RemoveRowButton({required this.index, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: onPressed,
      tooltip: 'Remove row $index',
    );
  }
}
