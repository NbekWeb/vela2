import Flutter
import UIKit
import AVFoundation
import Firebase
import Security

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase first with error handling
    do {
      FirebaseApp.configure()
      print("✅ Firebase configured successfully")
    } catch {
      print("❌ Firebase configuration failed: \(error)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure audio session for iOS
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to configure audio session: \(error)")
    }
    
    // Check for app reinstall and clear tokens if needed
    checkForAppReinstall()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Check if app was reinstalled and clear tokens
  private func checkForAppReinstall() {
    let userDefaults = Foundation.UserDefaults.standard
    let lastLaunchKey = "last_app_launch"
    let currentLaunch = Date().timeIntervalSince1970
    
    if let lastLaunch = userDefaults.object(forKey: lastLaunchKey) as? TimeInterval {
      let timeDifference = currentLaunch - lastLaunch
      // If more than 7 days have passed, consider it a fresh install
      if timeDifference > 7 * 24 * 60 * 60 {
        print("📱 App appears to be reinstalled, clearing tokens...")
        clearAllUserData()
      }
    }
    
    // Update last launch time
    userDefaults.set(currentLaunch, forKey: lastLaunchKey)
  }
  
  // Clear all user data on reinstall
  private func clearAllUserData() {
    // Clear UserDefaults
    let userDefaults = Foundation.UserDefaults.standard
    let keys = userDefaults.dictionaryRepresentation().keys
    for key in keys {
      if key.hasPrefix("flutter.") || key.contains("token") || key.contains("auth") {
        userDefaults.removeObject(forKey: key)
      }
    }
    
    // Clear Keychain (secure storage)
    let keychainQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: "com.example.vela"
    ]
    SecItemDelete(keychainQuery as CFDictionary)
    
    print("✅ All user data cleared on reinstall")
  }
}
