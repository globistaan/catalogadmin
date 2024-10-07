import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String title;

  const HeaderWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500, // Medium weight for elegance
            fontSize: 14, // Smaller font size for a refined look
            color: Colors.blueGrey[800], // Darker text color for contrast
            letterSpacing: 1.0, // Slightly increased letter spacing
          ),
          overflow: TextOverflow.ellipsis, // Handle overflow elegantly
          maxLines: 2, // Allow up to two lines for long text
        ),
      ),
    );
  }
}
