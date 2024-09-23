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
        child: Text(
          title,
          textAlign: TextAlign.center,
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
