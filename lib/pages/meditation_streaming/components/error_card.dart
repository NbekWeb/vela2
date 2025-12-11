import 'package:flutter/material.dart';

/// Card showing error message
class ErrorCard extends StatelessWidget {
  final String error;

  const ErrorCard({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Error",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(error),
          const SizedBox(height: 4),
          const Text(
            "Make sure CORS / network access are properly configured on the server.",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
