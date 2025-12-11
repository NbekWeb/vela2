import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/meditation_store.dart';
import 'navigation_service.dart';
import '../../pages/generator/direct_ritual_page.dart';
import '../../shared/widgets/personalized_meditation_modal.dart';

/// Service for handling meditation-related actions
class MeditationActionService {
  /// Reset meditation and navigate to DirectRitualPage
  static Future<void> resetMeditation(BuildContext context) async {
    final meditationStore = context.read<MeditationStore>();
    final meditationId = meditationStore.meditationProfile?.id?.toString();
    
    print('🔄 Reset meditation - ID: $meditationId');
    print('🔄 Meditation profile: ${meditationStore.meditationProfile?.toJson()}');
    
    // Delete meditation from server if ID exists
    if (meditationId != null && meditationId.isNotEmpty) {
      print('🗑️ Deleting meditation with ID: $meditationId');
      await meditationStore.deleteMeditation(meditationId);
    } else {
      print('⚠️ No meditation ID found, just clearing local data');
      // If no ID, just clear local data
      meditationStore.completeReset();
    }
    
    // Navigate to DirectRitualPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DirectRitualPage(),
      ),
    );
  }

  /// Show personalized meditation info modal
  static void showPersonalizedMeditationInfo(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const PersonalizedMeditationModal();
      },
    );
  }

  /// Save meditation to vault and navigate
  static Future<void> saveToVault(BuildContext context) async {
    await NavigationService.navigateAfterMeditation(context);
  }
}
