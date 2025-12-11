import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HappinessCard extends StatelessWidget {
  final VoidCallback onEdit;
  final String? content;

  const HappinessCard({
    super.key,
    required this.onEdit,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(164, 199, 234, 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content - auto height
          Text(
            content ??
                'What makes you happy?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Satoshi',
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
