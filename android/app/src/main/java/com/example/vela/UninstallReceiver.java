package com.example.vela;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.content.pm.PackageManager;

public class UninstallReceiver extends BroadcastReceiver {
    private static final String TAG = "UninstallReceiver";
    private static final String PREFS_NAME = "vela_prefs";
    private static final String UNINSTALL_FLAG = "app_uninstalled";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction() != null && intent.getAction().equals(Intent.ACTION_PACKAGE_REMOVED)) {
            String packageName = intent.getDataString();
            String appPackageName = context.getPackageName();
            
            Log.d(TAG, "Package removed: " + packageName);
            Log.d(TAG, "App package: " + appPackageName);
            
            // Check if our app is being uninstalled
            if (packageName != null && packageName.contains(appPackageName)) {
                Log.d(TAG, "Vela app is being uninstalled, clearing data...");
                
                // Clear all app data
                clearAllAppData(context);
                
                // Set uninstall flag in SharedPreferences
                SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
                SharedPreferences.Editor editor = prefs.edit();
                editor.putBoolean(UNINSTALL_FLAG, true);
                editor.putLong("uninstall_timestamp", System.currentTimeMillis());
                editor.apply();
                
                Log.d(TAG, "Uninstall flag set successfully");
            }
        }
    }
    
    // Clear all app data on uninstall
    private void clearAllAppData(Context context) {
        try {
            // Clear SharedPreferences
            SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
            prefs.edit().clear().apply();
            
            // Clear Flutter secure storage (if accessible)
            SharedPreferences flutterPrefs = context.getSharedPreferences("FlutterSecureStorage", Context.MODE_PRIVATE);
            flutterPrefs.edit().clear().apply();
            
            // Clear all other SharedPreferences
            String[] prefNames = {"FlutterSharedPreferences", "flutter."};
            for (String prefName : prefNames) {
                SharedPreferences flutterSharedPrefs = context.getSharedPreferences(prefName, Context.MODE_PRIVATE);
                flutterSharedPrefs.edit().clear().apply();
            }
            
            Log.d(TAG, "✅ All app data cleared on uninstall");
        } catch (Exception e) {
            Log.e(TAG, "❌ Error clearing app data: " + e.getMessage());
        }
    }
}
