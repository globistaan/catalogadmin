import 'package:flutter/material.dart';

class EditableTextCell extends StatelessWidget {
  final String text;
  final ValueChanged<String> onChanged;

  const EditableTextCell({required this.text, required this.onChanged, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: text),
      onChanged: onChanged,
      decoration: InputDecoration(border: OutlineInputBorder()),
    );
  }
}
