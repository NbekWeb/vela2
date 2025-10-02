import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_lifecycle_service.dart';

class TokenCleanupTest {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Test token cleanup functionality
  static Future<void> testTokenCleanup() async {
    developer.log('🧪 Starting token cleanup test...');
    
    try {
      // 1. Save test tokens
      await _secureStorage.write(key: 'access_token', value: 'test_access_token');
      await _secureStorage.write(key: 'refresh_token', value: 'test_refresh_token');
      await _secureStorage.write(key: 'neuroplasticity_active', value: 'true');
      
      // Save test preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('test_preference', 'test_value');
      await prefs.setBool('user_logged_in', true);
      
      developer.log('✅ Test data saved successfully');
      
      // 2. Verify tokens exist
      final accessToken = await _secureStorage.read(key: 'access_token');
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      final neuroplasticity = await _secureStorage.read(key: 'neuroplasticity_active');
      final testPref = prefs.getString('test_preference');
      final userLoggedIn = prefs.getBool('user_logged_in');
      
      if (accessToken != null && refreshToken != null && neuroplasticity != null && 
          testPref != null && userLoggedIn == true) {
        developer.log('✅ Test data verified - all tokens and preferences exist');
      } else {
        developer.log('❌ Test data verification failed');
        return;
      }
      
      // 3. Test app lifecycle service cleanup
      final appLifecycleService = AppLifecycleService();
      await appLifecycleService.forceClearAllData();
      
      developer.log('✅ Force clear all data executed');
      
      // 4. Verify tokens are cleared
      final clearedAccessToken = await _secureStorage.read(key: 'access_token');
      final clearedRefreshToken = await _secureStorage.read(key: 'refresh_token');
      final clearedNeuroplasticity = await _secureStorage.read(key: 'neuroplasticity_active');
      final clearedTestPref = prefs.getString('test_preference');
      final clearedUserLoggedIn = prefs.getBool('user_logged_in');
      
      if (clearedAccessToken == null && clearedRefreshToken == null && 
          clearedNeuroplasticity == null && clearedTestPref == null && 
          clearedUserLoggedIn == null) {
        developer.log('✅ Token cleanup test PASSED - all data cleared successfully');
      } else {
        developer.log('❌ Token cleanup test FAILED - some data still exists');
        developer.log('Access token: $clearedAccessToken');
        developer.log('Refresh token: $clearedRefreshToken');
        developer.log('Neuroplasticity: $clearedNeuroplasticity');
        developer.log('Test preference: $clearedTestPref');
        developer.log('User logged in: $clearedUserLoggedIn');
      }
      
    } catch (e) {
      developer.log('❌ Token cleanup test ERROR: $e');
    }
  }
  
  // Test app reinstall detection
  static Future<void> testAppReinstallDetection() async {
    developer.log('🧪 Starting app reinstall detection test...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Simulate old install time (more than 7 days ago)
      final oldInstallTime = DateTime.now().subtract(const Duration(days: 8));
      await prefs.setString('app_install_time', oldInstallTime.toIso8601String());
      
      developer.log('✅ Old install time set (8 days ago)');
      
      // Initialize app lifecycle service (should detect reinstall)
      final appLifecycleService = AppLifecycleService();
      await appLifecycleService.initialize();
      
      developer.log('✅ App lifecycle service initialized');
      
      // Check if tokens were cleared due to reinstall detection
      final accessToken = await _secureStorage.read(key: 'access_token');
      
      if (accessToken == null) {
        developer.log('✅ App reinstall detection test PASSED - tokens cleared on reinstall');
      } else {
        developer.log('❌ App reinstall detection test FAILED - tokens not cleared');
      }
      
    } catch (e) {
      developer.log('❌ App reinstall detection test ERROR: $e');
    }
  }
  
  // Run all tests
  static Future<void> runAllTests() async {
    developer.log('🚀 Running all token cleanup tests...');
    
    await testTokenCleanup();
    await Future.delayed(const Duration(seconds: 1));
    await testAppReinstallDetection();
    
    developer.log('🏁 All tests completed');
  }
}
