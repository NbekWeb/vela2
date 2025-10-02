import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../step_scaffold.dart';
import '../../../shared/widgets/ritual_info_modal.dart';
import '../../../shared/widgets/ritual_card.dart';
import '../../../shared/models/meditation_profile_data.dart';
import '../../../shared/models/ritual_data.dart';
import '../../../core/stores/meditation_store.dart';

class RitualStep extends StatefulWidget {
  final MeditationProfileData profileData;
  final Function(MeditationProfileData) onProfileDataChanged;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final int currentStep;
  final int totalSteps;
  final bool showStepper;
  final bool isDirectRitual;

  const RitualStep({
    required this.profileData,
    required this.onProfileDataChanged,
    this.onBack,
    this.onNext,
    required this.currentStep,
    required this.totalSteps,
    this.showStepper = true,
    this.isDirectRitual = false,
    super.key,
  });

  @override
  State<RitualStep> createState() => _RitualStepState();
}

class _RitualStepState extends State<RitualStep> {
  RitualData? selectedRitual;

  // Available rituals data
  static const List<RitualData> availableRituals =
      RitualDataProvider.availableRituals;

  @override
  void initState() {
    super.initState();
    // Set initial ritual if profile data already has one
    _initializeSelectedRitual();
  }

  void _initializeSelectedRitual() {
    // Check if profile data already has ritual information
    if (widget.profileData.planType != null) {
      // Try to find matching ritual based on planType
      final ritual = RitualDataProvider.getRitualById(
        widget.profileData.planType!,
      );
      if (ritual != null) {
        setState(() {
          selectedRitual = ritual;
        });
      }
    } else if (widget.profileData.ritualType != null &&
        widget.profileData.ritualType!.isNotEmpty) {
      // Fallback: Try to find matching ritual based on existing data
      for (final ritual in availableRituals) {
        if (ritual.defaultSettings['ritualType'] ==
            widget.profileData.ritualType) {
          setState(() {
            selectedRitual = ritual;
          });
          break;
        }
      }
    }
  }

  void _selectRitual(RitualData ritual) async {
    setState(() {
      selectedRitual = ritual;
    });

    // Apply default settings for the selected ritual
    // Ritual type ni List<String> dan String ga o'tkazish
    final ritualTypeList = ritual.defaultSettings['ritualType'] as List<String>;
    final ritualTypeString = ritualTypeList.isNotEmpty
        ? ritualTypeList.first
        : '';

    // Boshqa field'larni ham List<String> dan String ga o'tkazish
    final toneList = ritual.defaultSettings['tone'] as List<String>;
    final toneString = toneList.isNotEmpty ? toneList.first : '';

    final voiceList = ritual.defaultSettings['voice'] as List<String>;
    final voiceString = voiceList.isNotEmpty ? voiceList.first : '';

    final durationList = ritual.defaultSettings['duration'] as List<String>;
    final durationString = durationList.isNotEmpty ? durationList.first : '';

    final updatedProfileData = widget.profileData.copyWith(
      ritualType: [ritualTypeString], // String ni List<String> ga o'tkazish
      tone: [toneString],
      voice: [voiceString],
      duration: [durationString],
      planType: ritual.id, // plan_type ni ritual ID siga teng qilamiz
    );

    // Storage ga saqlash
    final meditationStore = Provider.of<MeditationStore>(
      context,
      listen: false,
    );

    // Save to meditation profile store
    meditationStore.setMeditationProfile(updatedProfileData);

    // Avval eski ma'lumotlarni tozalash
    await meditationStore.clearRitualSettings();

    // Yangi ma'lumotlarni saqlash
    await meditationStore.saveRitualSettings(
      ritualType: ritualTypeString,
      tone: toneString,
      duration: durationString,
      planType: ritual.id,
    );

    widget.onProfileDataChanged(updatedProfileData);

    // Show customization modal with updated profile data
    _showCustomizationModal(ritual, updatedProfileData);
  }

  void _showCustomizationModal(
    RitualData ritual,
    MeditationProfileData profileData,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomizeRitualModal(
            profileData: profileData,
            onProfileDataChanged: widget.onProfileDataChanged,
            planType: ritual.id.toString(),
            onClose: () => Navigator.of(context).pop(),
            isDirectRitual: widget.isDirectRitual,
          ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: 'Choose Your Ritual',
      onBack: widget.onBack,
      onNext: null,
      currentStep: widget.currentStep,
      totalSteps: widget.totalSteps,
      nextEnabled: selectedRitual != null,
      showStepper: widget.showStepper,
      showTitles: false,
      showInfo: true,
      child: RitualChooser(
        rituals: availableRituals,
        selectedRitual: selectedRitual,
        onRitualSelected: _selectRitual,
        profileData: widget.profileData,
        onProfileDataChanged: widget.onProfileDataChanged,
      ),
    );
  }
}

class RitualChooser extends StatelessWidget {
  final List<RitualData> rituals;
  final RitualData? selectedRitual;
  final Function(RitualData) onRitualSelected;
  final MeditationProfileData profileData;
  final Function(MeditationProfileData) onProfileDataChanged;

  const RitualChooser({
    required this.rituals,
    required this.selectedRitual,
    required this.onRitualSelected,
    required this.profileData,
    required this.onProfileDataChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Select the perfect meditation\nexperience for this moment',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFFF2EFEA),
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...rituals.map(
            (ritual) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RitualCard(
                ritual: ritual,
                isSelected: selectedRitual?.id == ritual.id,
                onTap: () => onRitualSelected(ritual),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
