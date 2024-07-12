import 'package:flutter/material.dart';

class HeaderSrNoWidget extends StatelessWidget {
  final String title;

  const HeaderSrNoWidget({super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        width: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[400]!, width: 2),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blueGrey[700],
          ),
        ),
      ),
    );
  }
}
