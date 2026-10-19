import 'package:flutter_test/flutter_test.dart';

import 'package:attendx/features/onboarding/onboarding_screen.dart';
import 'package:attendx/features/splash/splash_screen.dart';
import 'package:attendx/main.dart';

void main() {
  testWidgets('Splash is the first screen on app open, then routes to onboarding',
      (tester) async {
    await tester.pumpWidget(const AttendXApp());
    await tester.pump();

    // The splash must be visible as soon as the app opens.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('AttendX'), findsOneWidget);
    expect(find.text('ERP Attendance System'), findsOneWidget);

    // Still on the splash well before the timer fires.
    final half = Duration(milliseconds: SplashScreen.displayDuration.inMilliseconds ~/ 2);
    await tester.pump(half);
    expect(find.byType(SplashScreen), findsOneWidget);

    // Reach the full display duration: splash hands over to onboarding.
    await tester.pump(SplashScreen.displayDuration - half + const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
