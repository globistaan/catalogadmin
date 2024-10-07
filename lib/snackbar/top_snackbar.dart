import 'package:flutter/material.dart';

class TopSnackBar extends StatelessWidget {
  final String message;
  final OverlayEntry overlayEntry;

  const TopSnackBar({
    Key? key,
    required this.message,
    required this.overlayEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + kToolbarHeight,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  // Instead of popping the navigation stack, remove the snackbar overlay
                  overlayEntry.remove();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry; // Declare the OverlayEntry first

    overlayEntry = OverlayEntry(
      builder: (context) => TopSnackBar(
        message: message,
        overlayEntry: overlayEntry, // Pass the OverlayEntry to the Snackbar
      ),
    );

    overlay?.insert(overlayEntry);

    // Automatically dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
