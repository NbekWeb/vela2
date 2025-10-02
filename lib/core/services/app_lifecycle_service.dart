import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  static const String _lastAppVersionKey = 'last_app_version';
  static const String _appInstallTimeKey = 'app_install_time';
  static const String _appFirstLaunchKey = 'app_first_launch';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Timer? _backgroundTimer;
  DateTime? _backgroundTime;

  // Initialize the service
  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    await _checkAppInstallation();
    await _trackAppVersion();
  }

  // Check if app was recently installed or reinstalled
  Future<void> _checkAppInstallation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(_appFirstLaunchKey) ?? true;
      final installTime = prefs.getString(_appInstallTimeKey);
      
      if (isFirstLaunch || installTime == null) {
        // First launch or no install time recorded
        await prefs.setBool(_appFirstLaunchKey, false);
        await prefs.setString(_appInstallTimeKey, DateTime.now().toIso8601String());
        
        // Clear any existing tokens on fresh install
        await _clearTokensOnFreshInstall();
      } else {
        // Check if app was uninstalled and reinstalled
        final lastInstallTime = DateTime.parse(installTime);
        final timeDifference = DateTime.now().difference(lastInstallTime);
        
        // If more than 7 days have passed, consider it a fresh install
        if (timeDifference.inDays > 7) {
          await _clearTokensOnFreshInstall();
          await prefs.setString(_appInstallTimeKey, DateTime.now().toIso8601String());
        }
      }
    } catch (e) {
      developer.log('❌ Error checking app installation: $e');
    }
  }

  // Track app version changes
  Future<void> _trackAppVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final lastVersion = prefs.getString(_lastAppVersionKey);
      
      if (lastVersion != currentVersion) {
        // Version changed, clear tokens to ensure fresh authentication
        await _clearTokensOnVersionChange();
        await prefs.setString(_lastAppVersionKey, currentVersion);
        developer.log('📱 App version changed from $lastVersion to $currentVersion');
      }
    } catch (e) {
      developer.log('❌ Error tracking app version: $e');
    }
  }

  // Clear tokens on fresh install
  Future<void> _clearTokensOnFreshInstall() async {
    try {
      await _secureStorage.deleteAll();
      developer.log('✅ Tokens cleared on fresh install');
    } catch (e) {
      developer.log('❌ Error clearing tokens on fresh install: $e');
    }
  }

  // Clear tokens on version change
  Future<void> _clearTokensOnVersionChange() async {
    try {
      await _secureStorage.deleteAll();
      developer.log('✅ Tokens cleared on version change');
    } catch (e) {
      developer.log('❌ Error clearing tokens on version change: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        _handleAppForegrounded();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  void _handleAppBackgrounded() {
    _backgroundTime = DateTime.now();
    developer.log('📱 App backgrounded at: $_backgroundTime');
    
    // Start timer to detect if app is uninstalled
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer(const Duration(minutes: 5), () {
      _checkForUninstall();
    });
  }

  void _handleAppForegrounded() {
    _backgroundTimer?.cancel();
    _backgroundTime = null;
    developer.log('📱 App foregrounded');
  }

  void _handleAppDetached() {
    developer.log('📱 App detached - potential uninstall');
    _clearTokensOnUninstall();
  }

  void _handleAppHidden() {
    developer.log('📱 App hidden');
  }

  // Check if app was uninstalled and reinstalled
  Future<void> _checkForUninstall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActiveTime = prefs.getString('last_active_time');
      
      if (lastActiveTime != null) {
        final timeDifference = DateTime.now().difference(DateTime.parse(lastActiveTime));
        
        // If app was inactive for more than 24 hours, clear tokens
        if (timeDifference.inHours > 24) {
          await _clearTokensOnUninstall();
        }
      }
    } catch (e) {
      developer.log('❌ Error checking for uninstall: $e');
    }
  }

  // Clear tokens when app is uninstalled
  Future<void> _clearTokensOnUninstall() async {
    try {
      await _secureStorage.deleteAll();
      developer.log('✅ Tokens cleared on app uninstall');
    } catch (e) {
      developer.log('❌ Error clearing tokens on uninstall: $e');
    }
  }

  // Update last active time
  Future<void> updateLastActiveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_active_time', DateTime.now().toIso8601String());
    } catch (e) {
      developer.log('❌ Error updating last active time: $e');
    }
  }

  // Force clear all data (for testing or manual cleanup)
  Future<void> forceClearAllData() async {
    try {
      await _secureStorage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      developer.log('✅ All app data force cleared');
    } catch (e) {
      developer.log('❌ Error force clearing data: $e');
    }
  }

  // Dispose resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundTimer?.cancel();
  }
}
