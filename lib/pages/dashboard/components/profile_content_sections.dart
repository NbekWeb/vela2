import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'life_vision_card.dart';
import 'goals_progress_card.dart';
import 'dreams_realized_card.dart';
import 'happiness_card.dart';
import '../../../shared/widgets/profile_edit_modal.dart';
import '../../../shared/widgets/svg_icon.dart';
import '../../../core/stores/auth_store.dart';

class ProfileContentSections extends StatefulWidget {
  const ProfileContentSections({super.key});

  @override
  State<ProfileContentSections> createState() => _ProfileContentSectionsState();
}

class _ProfileContentSectionsState extends State<ProfileContentSections> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStore>(
      builder: (context, authStore, child) {
        final user = authStore.user;
        final dream =
            user?.dream ??
            'I\'m living in a cozy home filled with art, waking up feeling calm, working on projects that light me up...';
        final happiness =
            user?.happiness ??
            'I feel most authentic when I embrace my true self. I am focused on pursuing my passions.';
        final goals =
            user?.goals ??
            'Start a morning routine, feel less anxious, travel more.';

        return Column(
          children: [
            // Life Vision - alohida qator
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title outside the card
                Row(
                  children: [
                    Text(
                      'Life Vision',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showLifeVisionModal(dream),
                      child: const SvgIcon(
                        assetName: 'assets/icons/edit.svg',
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Life Vision Card - auto height
                LifeVisionCard(
                  onEdit: () => _showLifeVisionModal(dream),
                  content: dream,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Goals in Progress - alohida qator
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title outside the card
                Builder(
                  builder: (context) {
                    // Calculate unchecked goals count
                    Set<int> checkedItemIds = {};
                    if (user?.checkGoalsList != null && user!.checkGoalsList.isNotEmpty) {
                      checkedItemIds = user.checkGoalsList
                          .where((item) => item['id'] != null)
                          .map((item) => item['id'] as int)
                          .toSet();
                    }
                    
                    int uncheckedCount = 0;
                    if (user?.goalsGenerateList != null && user!.goalsGenerateList.isNotEmpty) {
                      for (var goalGroup in user.goalsGenerateList) {
                        if (goalGroup['items'] != null && goalGroup['items'] is List) {
                          final items = goalGroup['items'] as List;
                          for (var item in items) {
                            if (item is Map<String, dynamic> && 
                                item['id'] != null) {
                              final itemId = item['id'] as int;
                              if (!checkedItemIds.contains(itemId)) {
                                uncheckedCount++;
                              }
                            }
                          }
                        }
                      }
                    }
                    
                    return Row(
                      children: [
                        Text(
                          'Goals in Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Satoshi',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (uncheckedCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '($uncheckedCount)',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Satoshi',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(width: 4),
                          Text(
                            '',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontFamily: 'Satoshi',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showGoalsInProgressModal(goals),
                          child: const SvgIcon(
                            assetName: 'assets/icons/edit.svg',
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Goals Progress Card - auto height
                GoalsProgressCard(
                  onEdit: () => _showGoalsInProgressModal(goals),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dreams Realized
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title outside the card - with checked icon
                Row(
                  children: [
                    Text(
                      'Dreams Realized',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Checked icon
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(164, 199, 234, 0.5),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Dreams Realized Card - show check_goals_list
                DreamsRealizedCard(
                  height: 120,
                  checkGoalsList: user?.checkGoalsList ?? const [],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Happiness - alohida qator
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title outside the card
                Row(
                  children: [
                    Text(
                      'Happiness',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showHappinessModal(happiness),
                      child: const SvgIcon(
                        assetName: 'assets/icons/edit.svg',
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Happiness Card - auto height
                HappinessCard(
                  onEdit: () => _showHappinessModal(happiness),
                  content: happiness,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showLifeVisionModal(String initialValue) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ProfileEditModal(
            title: 'Life Vision',
            prompt: 'Be sure to include Sensory Details: What does it look and feel like? What are you doing? Who are you with? What do you see, hear, smell?',
            hintText:
                'I\'m living in a cozy home filled with art, waking up feeling calm, working on projects that light me up...',
            initialValue: initialValue,
            onSave: (String newDream) async {
              final authStore = Provider.of<AuthStore>(context, listen: false);
              final user = authStore.user;

              if (user != null) {
                await authStore.updateUserDetail(
                  gender: user.gender ?? '',
                  ageRange: user.ageRange ?? '',
                  dream: newDream, // dream field'iga saqlanadi
                  goals: user.goals ?? '',
                  happiness: user.happiness ?? '',
                  onSuccess: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showGoalsInProgressModal(String initialValue) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ProfileEditModal(
            title: 'Goals in Progress',
            prompt:
                'Are there specific goals you want to accomplish, experiences you want to have, or habits you want to form or change?',
            hintText:
                'Start a morning routine, feel less anxious, travel more.',
            initialValue: initialValue,
            onSave: (String newGoals) async {
              final authStore = Provider.of<AuthStore>(context, listen: false);
              final user = authStore.user;

              if (user != null) {
                await authStore.updateUserDetail(
                  gender: user.gender ?? '',
                  ageRange: user.ageRange ?? '',
                  dream: user.dream ?? '',
                  goals: newGoals, // goals field'iga saqlanadi
                  happiness: user.happiness ?? '',
                  onSuccess: () async {
                    // Refresh user data after update
                    await authStore.getUserDetails();
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showHappinessModal(String initialValue) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ProfileEditModal(
            title: 'Happiness',
            prompt: 'What makes you happy? Describe the things, activities, and people that bring you joy and fulfillment.',
            hintText:
                'Being near the ocean, creating things I love, traveling with my boys, riding horses...',
            initialValue: initialValue,
            onSave: (String newHappiness) async {
              final authStore = Provider.of<AuthStore>(context, listen: false);
              final user = authStore.user;

              if (user != null) {
                await authStore.updateUserDetail(
                  gender: user.gender ?? '',
                  ageRange: user.ageRange ?? '',
                  dream: user.dream ?? '',
                  goals: user.goals ?? '',
                  happiness: newHappiness, // happiness field'iga saqlanadi
                  onSuccess: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

}
