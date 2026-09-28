import 'package:flutter_test/flutter_test.dart';
import 'package:attendx/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendXApp());
    expect(find.text('AttendX'), findsWidgets);
  });
}
