import 'package:flutter/material.dart';

class EditableTextCell extends StatefulWidget {
  final String? text;
  final Function(String) onChanged;

  const EditableTextCell({
    Key? key,
    required this.text,
    required this.onChanged,
  }) : super(key: key);

  @override
  _EditableTextCellState createState() => _EditableTextCellState();
}

class _EditableTextCellState extends State<EditableTextCell> {
  late double _height; // Initial height for one line
  double _dragHeight = 0.0; // Additional height based on dragging
  late TextEditingController _controller;
  bool _isDragging = false; // Track dragging state

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _height = _calculateHeight(widget.text ?? "") + 42; // Ensure padding is included
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller = TextEditingController(text: widget.text);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown, // Cursor for vertical dragging
      child: GestureDetector(
        onVerticalDragStart: (_) {
          setState(() {
            _isDragging = true; // Start dragging
          });
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _dragHeight += details.delta.dy;

            // Update height based on drag
            _height = (_height + _dragHeight).clamp(60.0, double.infinity);
          });
        },
        onVerticalDragEnd: (details) {
          setState(() {
            // Reset drag height after the drag ends
            _dragHeight = 0.0;
            _isDragging = false; // Stop dragging
          });
        },
        child: CustomPaint(
          painter: _isDragging ? DottedBorderPainter() : null,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(maxHeight: _height), // Limit height to the calculated value
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              onChanged: (value) {
                widget.onChanged(value);
                // Dynamically adjust height based on text content
                final textHeight = _calculateHeight(value);
                setState(() {
                  _height = textHeight.clamp(60.0, double.infinity); // Adjust height based on content
                });
              },
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
              maxLines: null, // Allow for multiple lines
              minLines: 1, // Show only one line initially
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateHeight(String text) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
    );
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 1, // Calculate height for a single line
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 300); // Set max width as needed
    return textPainter.height + 12; // Return height for one line with some padding
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue // Color of the dotted border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double dashWidth = 4.0;
    double dashSpace = 4.0;

    // Draw top border
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    // Draw left border
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    // Draw bottom border
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX - dashWidth, size.height), paint);
      startX -= dashWidth + dashSpace;
    }

    // Draw right border
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY - dashWidth), paint);
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
