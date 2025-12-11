import 'package:flutter/material.dart';

/// Card showing streaming status and progress
class StreamingStatusCard extends StatelessWidget {
  final bool isLoading;
  final double progressSeconds;
  final String Function(double) formatTime;

  const StreamingStatusCard({
    super.key,
    required this.isLoading,
    required this.progressSeconds,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E7FF), Color(0xFFFFE6F1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
              const SizedBox(width: 8),
              Text(
                isLoading
                    ? "Connecting to server..."
                    : "Receiving meditation...",
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isLoading)
            Text(
              formatTime(progressSeconds),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              minHeight: 6,
              value: null,
            ),
          ),
        ],
      ),
    );
  }
}
