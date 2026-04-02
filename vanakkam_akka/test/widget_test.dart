import 'package:flutter_test/flutter_test.dart';
import 'package:arogya/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ArogyaApp());
    await tester.pumpAndSettle();

    // Verify the app name is displayed
    expect(find.text('வணக்கம் அக்கா'), findsWidgets);
  });
}
