import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendx/features/student/student_dashboard.dart';

/// Regression test for the blank student dashboard.
///
/// The bottom nav used a plain `Center()` inside each `Expanded` cell, so it
/// expanded to the full height offered by the Scaffold: the bar covered the
/// whole screen (hiding the app bar and the page background) and the body was
/// squeezed to zero height, leaving only the nav pills visible in the middle
/// of the screen.
void main() {
  testWidgets('student dashboard renders its content and the nav at the bottom',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: StudentDashboard()));
    await tester.pump(const Duration(milliseconds: 1200));

    expect(tester.takeException(), isNull);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final navRect = tester.getRect(
      find.byWidget(scaffold.bottomNavigationBar!),
    );
    final bodyRect = tester.getRect(find.byType(SingleChildScrollView).first);
    final appBarRect = tester.getRect(find.byType(AppBar));

    debugPrint('appBar=$appBarRect body=$bodyRect nav=$navRect');

    // The nav bar must hug its content instead of filling the screen.
    expect(navRect.height, lessThan(100), reason: 'bottom nav is too tall');
    expect(navRect.bottom, greaterThan(2300), reason: 'bottom nav not at bottom');

    // The page body must own the remaining space between the app bar and the
    // nav bar (the scroll view itself shrink-wraps its content).
    final bodySpace = navRect.top - appBarRect.bottom;
    expect(bodySpace, greaterThan(2000), reason: 'body has no height');
    expect(appBarRect.bottom, equals(bodyRect.top));

    // Actual content is laid out on screen, not clipped away.
    final hello = find.textContaining('Hello,');
    expect(hello, findsOneWidget);
    final helloRect = tester.getRect(hello);
    expect(helloRect.top, greaterThan(appBarRect.bottom));
    expect(helloRect.top, lessThan(navRect.top));
  });
}
