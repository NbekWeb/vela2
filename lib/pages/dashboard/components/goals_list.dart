import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/stores/auth_store.dart';

class GoalsList extends StatefulWidget {
  const GoalsList({super.key});

  @override
  State<GoalsList> createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList> {
  // Track temporarily checked items (before API response)
  Set<int> _pendingCheckedIds = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStore>(
      builder: (context, authStore, child) {
        final user = authStore.user;
        
        // Get checked item IDs from check_goals_list
        Set<int> checkedItemIds = {};
        if (user?.checkGoalsList != null && user!.checkGoalsList.isNotEmpty) {
          checkedItemIds = user.checkGoalsList
              .where((item) => item['id'] != null)
              .map((item) => item['id'] as int)
              .toSet();
        }
        
        // Get ALL items from goals_generate_list and filter out checked ones (show only unchecked)
        // But include pending checked items in the list (they will be shown as checked)
        List<Map<String, dynamic>> goalItems = [];
        if (user?.goalsGenerateList != null && user!.goalsGenerateList.isNotEmpty) {
          // Extract items from all goals_generate_list entries
          for (var goalGroup in user.goalsGenerateList) {
            if (goalGroup['items'] != null && goalGroup['items'] is List) {
              final items = goalGroup['items'] as List;
              for (var item in items) {
                if (item is Map<String, dynamic> && 
                    item['item'] != null && 
                    item['id'] != null) {
                  final itemId = item['id'] as int;
                  // Add if NOT in check_goals_list (unchecked items)
                  // OR if it's pending (will be shown as checked but still in list)
                  if (!checkedItemIds.contains(itemId) || _pendingCheckedIds.contains(itemId)) {
                    goalItems.add({
                      'id': itemId,
                      'item': item['item'].toString(),
                    });
                  }
                }
              }
            }
          }
        }
        
        // If all goals are checked (no unchecked items), show message
        if (goalItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'All your goals are accomplished',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Satoshi',
                ),
              ),
            ),
          );
        }

        return Column(
          children: goalItems.map((goalItem) {
            final itemId = goalItem['id'] as int;
            final goalText = goalItem['item'].toString();
            final isChecked = _pendingCheckedIds.contains(itemId);

            return GestureDetector(
              onTap: () {
                _onGoalItemToggled(itemId, checkedItemIds, authStore);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Custom circle with selection indicator
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isChecked
                            ? const Color(0xFF3B6EAA)
                            : Colors.transparent,
                        border: isChecked
                            ? null
                            : Border.all(color: const Color(0xFF3B6EAA), width: 1),
                      ),
                      child: isChecked
                          ? const Icon(
                              Icons.check,
                              color: Color(0xFFFFFFFF),
                              size: 12,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
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
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _onGoalItemToggled(int itemId, Set<int> currentCheckedIds, AuthStore authStore) async {
    // Add to pending checked items immediately for UI update
    setState(() {
      _pendingCheckedIds.add(itemId);
    });
    
    // Add this item to checked list
    final newCheckedIds = Set<int>.from(currentCheckedIds)..add(itemId);
    
    try {
      developer.log('📤 Sending to API: ${newCheckedIds.toList()}');
      
      // Send to API
      await authStore.checkGoals(goalsItemIds: newCheckedIds.toList());
      
      // Refresh user data after successful API call
      await authStore.getUserDetails();
      
      // Remove from pending after API response (item will be removed from list)
      setState(() {
        _pendingCheckedIds.remove(itemId);
      });
    } catch (e) {
      // Remove from pending on error
      setState(() {
        _pendingCheckedIds.remove(itemId);
      });
      
      Fluttertoast.showToast(
        msg: 'Failed to update goals. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
