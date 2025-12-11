import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling navigation logic
class NavigationService {
  /// Navigate to vault or dashboard based on first-time flag
  static Future<void> navigateAfterMeditation(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirst = prefs.getBool('first') ?? false;
      
      if (isFirst) {
        // First time - go to vault and remove first flag
        await prefs.remove('first');
        _navigateToVault(context);
      } else {
        // Not first time - go to dashboard
        _navigateToDashboard(context);
      }
    } catch (e) {
      // Error handling - default to dashboard with cleared stack
      _navigateToDashboard(context);
    }
  }

  /// Navigate to vault with cleared navigation stack
  static void _navigateToVault(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/vault',
      (route) {
        // Keep only vault and dashboard routes, remove auth pages
        return route.settings.name == '/vault' || 
               route.settings.name == '/dashboard' ||
               route.settings.name == '/my-meditations' ||
               route.settings.name == '/archive' ||
               route.settings.name == '/generator';
      }
    );
  }

  /// Navigate to dashboard with cleared navigation stack
  static void _navigateToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/dashboard',
      (route) {
        // Keep only dashboard and its sub-routes, remove auth pages
        return route.settings.name == '/dashboard' || 
               route.settings.name == '/my-meditations' ||
               route.settings.name == '/archive' ||
               route.settings.name == '/vault' ||
               route.settings.name == '/generator';
      }
    );
  }

  /// Navigate to dashboard (public method)
  static void navigateToDashboard(BuildContext context) {
    _navigateToDashboard(context);
  }

  /// Navigate to DirectRitualPage
  static void navigateToDirectRitual(BuildContext context) {
    // This will be handled by the page itself since it needs DirectRitualPage widget
    // We can return a callback or use a different approach
  }
}
