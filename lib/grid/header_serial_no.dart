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
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Soft, neutral background color
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Subtle shadow for depth
              offset: Offset(0, 2), // Shadow position
              blurRadius: 4.0, // Blur radius
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey[700],
          ),
        ),
      ),
    );
  }
}
