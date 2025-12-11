import 'package:flutter/material.dart';

/// Card showing meditation completion status
class CompletionCard extends StatelessWidget {
  final double progressSeconds;
  final String Function(double) formatTime;

  const CompletionCard({
    super.key,
    required this.progressSeconds,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Text(
            "Meditation complete!",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text("Duration: ${formatTime(progressSeconds)}"),
        ],
      ),
    );
  }
}
