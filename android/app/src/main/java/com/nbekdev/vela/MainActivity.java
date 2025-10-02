package com.nbekdev.vela;

import io.flutter.embedding.android.FlutterActivity;
import android.content.SharedPreferences;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";
    private static final String PREFS_NAME = "vela_prefs";
    private static final String LAST_LAUNCH_KEY = "last_app_launch";
    
    @Override
    protected void onResume() {
        super.onResume();
        checkForAppReinstall();
    }
    
    // Check if app was reinstalled and clear tokens if needed
    private void checkForAppReinstall() {
        try {
            SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
            long currentLaunch = System.currentTimeMillis();
            long lastLaunch = prefs.getLong(LAST_LAUNCH_KEY, 0);
            
            if (lastLaunch > 0) {
                long timeDifference = currentLaunch - lastLaunch;
                // If more than 7 days have passed, consider it a fresh install
                if (timeDifference > 7 * 24 * 60 * 60 * 1000) {
                    Log.d(TAG, "📱 App appears to be reinstalled, clearing tokens...");
                    clearAllUserData();
                }
            }
            
            // Update last launch time
            prefs.edit().putLong(LAST_LAUNCH_KEY, currentLaunch).apply();
        } catch (Exception e) {
            Log.e(TAG, "❌ Error checking app reinstall: " + e.getMessage());
        }
    }
    
    // Clear all user data on reinstall
    private void clearAllUserData() {
        try {
            // Clear SharedPreferences
            SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
            prefs.edit().clear().apply();
            
            // Clear Flutter secure storage
            SharedPreferences flutterPrefs = getSharedPreferences("FlutterSecureStorage", MODE_PRIVATE);
            flutterPrefs.edit().clear().apply();
            
            // Clear Flutter shared preferences
            SharedPreferences flutterSharedPrefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
            flutterSharedPrefs.edit().clear().apply();
            
            Log.d(TAG, "✅ All user data cleared on reinstall");
        } catch (Exception e) {
            Log.e(TAG, "❌ Error clearing user data: " + e.getMessage());
        }
    }
}
