import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DreamsRealizedCard extends StatelessWidget {
  final double? height;
  final List<Map<String, dynamic>> checkGoalsList;

  const DreamsRealizedCard({
    super.key,
    this.height,
    required this.checkGoalsList,
  });

  @override
  Widget build(BuildContext context) {
    // If check_goals_list is empty, show message
    if (checkGoalsList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(164, 199, 234, 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Check your Goals in Goals in Progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Satoshi',
              height: 1.2,
            ),
          ),
        ),
      );
    }

    // Show list of checked goals
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(164, 199, 234, 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List of checked goals
          ...checkGoalsList.map((goal) {
            // Extract goal text - adjust based on actual API structure
            final goalText = goal['item'] ?? goal['goal'] ?? goal['name'] ?? '';
            if (goalText.isEmpty) return const SizedBox.shrink();
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3B6EAA),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goalText,
                      style: TextStyle(
                        color: const Color(0xFF3B6EAA),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Satoshi',
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
} 