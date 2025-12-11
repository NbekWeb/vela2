import 'package:flutter/material.dart';
import 'goals_list.dart';

class GoalsProgressCard extends StatelessWidget {
  final double? height;
  final VoidCallback onEdit;

  const GoalsProgressCard({
    super.key,
    this.height,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(164, 199, 234, 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const GoalsList(),
    );
  }
} 