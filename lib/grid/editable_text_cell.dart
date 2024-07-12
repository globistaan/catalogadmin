import 'package:flutter/material.dart';

class EditableTextCell extends StatelessWidget {
  final String? text;
  final Function(String) onChanged;

  const EditableTextCell({super.key,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: TextEditingController(text: text),
        textAlign: TextAlign.center,
        onChanged: onChanged,
        style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
        maxLines: null,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
