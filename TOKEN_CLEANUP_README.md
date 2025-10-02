# Token Cleanup on App Uninstall

Bu hujjat ilovani uninstall qilganda access token va boshqa ma'lumotlarni to'g'ri tozalash haqida ma'lumot beradi.

## Muammo

Ilovani uninstall qilganda access token va boshqa ma'lumotlar saqlanib qolayotgan edi. Bu xavfsizlik muammosi yaratadi.

## Yechim

### 1. App Lifecycle Service

`lib/core/services/app_lifecycle_service.dart` - Ilova lifecycle ni kuzatish va uninstall detection uchun:

- App background/foreground holatlarini kuzatish
- App reinstall detection
- Token cleanup on app uninstall
- Version change detection

### 2. AuthStore yangilanishi

`lib/core/stores/auth_store.dart` ga yangi metodlar qo'shildi:

- `clearAllData()` - Barcha ma'lumotlarni tozalash
- Token cleanup on app uninstall
- Social auth session cleanup

### 3. Native Platform Support

#### Android
- `android/app/src/main/AndroidManifest.xml` - UninstallReceiver qo'shildi
- `android/app/src/main/java/com/example/vela/UninstallReceiver.java` - Uninstall detection

#### iOS
- `ios/Runner/AppDelegate.swift` - App reinstall detection
- Keychain cleanup
- UserDefaults cleanup

### 4. Test Functionality

`lib/core/services/token_cleanup_test.dart` - Test uchun:

- Token cleanup test
- App reinstall detection test
- Settings page da test button

## Qanday ishlaydi

### 1. App Lifecycle Monitoring
- App background ga o'tganda timer ishga tushadi
- 5 daqiqa kutadi, agar app qaytmasa uninstall deb hisoblaydi
- 24 soatdan ko'p vaqt o'tganda tokenlarni tozalaydi

### 2. App Reinstall Detection
- App birinchi marta ishga tushganda install time ni saqlaydi
- 7 kundan ko'p vaqt o'tganda fresh install deb hisoblaydi
- Fresh install da barcha tokenlarni tozalaydi

### 3. Native Platform Detection

#### Android
- `PACKAGE_REMOVED` intent ni kuzatadi
- App uninstall qilinganda flag o'rnatadi
- Keyingi install da flag ni tekshiradi

#### iOS
- App launch time ni kuzatadi
- 7 kundan ko'p vaqt o'tganda reinstall deb hisoblaydi
- Keychain va UserDefaults ni tozalaydi

## Test qilish

### 1. Settings page orqali
1. Settings > Test Token Cleanup
2. "Run Test" tugmasini bosing
3. Console da natijalarni ko'ring

### 2. Manual test
```dart
// Test token cleanup
await TokenCleanupTest.testTokenCleanup();

// Test app reinstall detection
await TokenCleanupTest.testAppReinstallDetection();

// Barcha testlarni ishga tushirish
await TokenCleanupTest.runAllTests();
```

## Xavfsizlik

### Token Storage
- `FlutterSecureStorage` - Encrypted storage
- Keychain (iOS) va Keystore (Android) orqali
- App uninstall qilinganda avtomatik tozalash

### Data Cleanup
- Access token
- Refresh token
- Social auth sessions
- User preferences
- Neuroplasticity data

## Platform Support

### Android
- ✅ Uninstall detection
- ✅ Token cleanup
- ✅ SharedPreferences cleanup
- ✅ Secure storage cleanup

### iOS
- ✅ App reinstall detection
- ✅ Keychain cleanup
- ✅ UserDefaults cleanup
- ✅ Secure storage cleanup

### Web
- ⚠️ Limited support (browser storage)
- ✅ Local storage cleanup
- ✅ Session storage cleanup

## Troubleshooting

### Token hali ham saqlanib qolsa
1. App ni to'liq uninstall qiling
2. Device ni restart qiling
3. App ni qayta install qiling
4. Settings > Test Token Cleanup orqali test qiling

### Test natijasi muvaffaqiyatsiz
1. Console da xatolarni tekshiring
2. App permissions ni tekshiring
3. Platform-specific settings ni tekshiring

## Kod misollari

### Token cleanup
```dart
// AuthStore dan
await authStore.clearAllData();

// AppLifecycleService dan
await appLifecycleService.forceClearAllData();
```

### Test
```dart
// Test qilish
await TokenCleanupTest.runAllTests();
```

## Xulosa

Bu yechim ilovani uninstall qilganda barcha access token va ma'lumotlarni to'g'ri tozalashni ta'minlaydi. Platform-specific detection va Flutter lifecycle management orqali ishonchli xavfsizlik ta'minlanadi.
