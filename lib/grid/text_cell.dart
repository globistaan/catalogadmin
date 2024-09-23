import 'package:flutter/material.dart';

class TextCell extends StatelessWidget {
  final String text;
  const TextCell({super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      child: Container(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
