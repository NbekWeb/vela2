import 'package:flutter/material.dart';
import '../../../shared/models/meditation_profile_data.dart';
import '../../../core/stores/meditation_store.dart';
import '../step_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgeStep extends StatefulWidget {
  final MeditationProfileData profileData;
  final Function(MeditationProfileData) onProfileDataChanged;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final int currentStep;
  final int totalSteps;
  final int stepperIndex;
  final int stepperCount;

  const AgeStep({
    required this.profileData,
    required this.onProfileDataChanged,
    required this.onNext,
    this.onBack,
    required this.currentStep,
    required this.totalSteps,
    required this.stepperIndex,
    required this.stepperCount,
    super.key,
  });

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  int? selectedIndex;
  final List<String> ages = ['18-24', '25-34', '35-44', '45-54', '55+'];

  @override
  void initState() {
    super.initState();
    // Initialize selectedIndex based on existing profile data
    if (widget.profileData.ageRange != null) {
      selectedIndex = ages.indexOf(widget.profileData.ageRange!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Padding va pill orasidagi bo'shliqlarni hisobga oling
    final horizontalPadding = 32.0; // StepScaffold yoki umumiy padding
    final pillSpacing = 15.0;
    final pillsPerRow = 3;
    final pillWidth =
        (screenWidth - horizontalPadding - (pillSpacing * (pillsPerRow - 1))) /
        pillsPerRow;

    return StepScaffold(
      title: '',
      onBack: widget.onBack,
      onNext: widget.onNext,
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      nextEnabled: selectedIndex != null,
      stepperIndex: widget.stepperIndex,
      stepperCount: widget.stepperCount,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'How old are you?',
                  style: TextStyle(
                    fontFamily: 'Canela',
                    fontSize: 32.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    // First row: 3 pills
                    Row(
                      children: [
                        Expanded(
                          child: _AgePill(
                            label: ages[0],
                            selected: selectedIndex == 0,
                            onTap: () {
                              setState(() => selectedIndex = 0);
                              final updatedProfile = widget.profileData
                                  .copyWith(ageRange: ages[0]);
                              widget.onProfileDataChanged(updatedProfile);
                              final meditationStore =
                                  Provider.of<MeditationStore>(
                                    context,
                                    listen: false,
                                  );
                              meditationStore.setMeditationProfile(
                                updatedProfile,
                              );
                            },
                            width: 0,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _AgePill(
                            label: ages[1],
                            selected: selectedIndex == 1,
                            onTap: () {
                              setState(() => selectedIndex = 1);
                              final updatedProfile = widget.profileData
                                  .copyWith(ageRange: ages[1]);
                              widget.onProfileDataChanged(updatedProfile);
                              final meditationStore =
                                  Provider.of<MeditationStore>(
                                    context,
                                    listen: false,
                                  );
                              meditationStore.setMeditationProfile(
                                updatedProfile,
                              );
                            },
                            width: 0,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _AgePill(
                            label: ages[2],
                            selected: selectedIndex == 2,
                            onTap: () {
                              setState(() => selectedIndex = 2);
                              final updatedProfile = widget.profileData
                                  .copyWith(ageRange: ages[2]);
                              widget.onProfileDataChanged(updatedProfile);
                              final meditationStore =
                                  Provider.of<MeditationStore>(
                                    context,
                                    listen: false,
                                  );
                              meditationStore.setMeditationProfile(
                                updatedProfile,
                              );
                            },
                            width: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Second row: 2 pills centered
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AgePill(
                            label: ages[3],
                            selected: selectedIndex == 3,
                            onTap: () {
                              setState(() => selectedIndex = 3);
                              final updatedProfile = widget.profileData
                                  .copyWith(ageRange: ages[3]);
                              widget.onProfileDataChanged(updatedProfile);
                              final meditationStore =
                                  Provider.of<MeditationStore>(
                                    context,
                                    listen: false,
                                  );
                              meditationStore.setMeditationProfile(
                                updatedProfile,
                              );
                            },
                            width: 100,
                          ),
                          const SizedBox(width: 15),
                          _AgePill(
                            label: ages[4],
                            selected: selectedIndex == 4,
                            onTap: () {
                              setState(() => selectedIndex = 4);
                              final updatedProfile = widget.profileData
                                  .copyWith(ageRange: ages[4]);
                              widget.onProfileDataChanged(updatedProfile);
                              final meditationStore =
                                  Provider.of<MeditationStore>(
                                    context,
                                    listen: false,
                                  );
                              meditationStore.setMeditationProfile(
                                updatedProfile,
                              );
                            },
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  const _AgePill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        constraints: const BoxConstraints(minWidth: 90),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF3B6EAA)
              : const Color.fromRGBO(21, 43, 86, 0.1),
          border: Border.all(
            color: selected
                ? const Color(0xFF3B6EAA)
                : const Color.fromRGBO(21, 43, 86, 0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(70),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: selected ? Colors.white : const Color(0xFFC9DFF4),
            ),
          ),
        ),
      ),
    );
  }
}
