// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vela/main.dart';
import 'package:vela/core/stores/auth_store.dart';
import 'package:vela/core/stores/meditation_store.dart';
import 'package:vela/core/stores/like_store.dart';
import 'package:vela/core/stores/check_in_store.dart';
import 'package:vela/core/services/app_lifecycle_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final authStore = AuthStore();
    final meditationStore = MeditationStore();
    final likeStore = LikeStore();
    final checkInStore = CheckInStore();
    final appLifecycleService = AppLifecycleService();
    await tester.pumpWidget(MyApp(
      authStore: authStore, 
      meditationStore: meditationStore,
      likeStore: likeStore,
      checkInStore: checkInStore,
      appLifecycleService: appLifecycleService,
      initialRoute: '/loading',
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
