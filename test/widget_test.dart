// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:qasetha/main.dart';
import 'package:qasetha/services/theme_service.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    final themeService = ThemeService();
    await tester.pumpWidget(QasethaApp(themeService: themeService));
    expect(find.byType(QasethaApp), findsOneWidget);
  });
}
