import 'package:flutter_test/flutter_test.dart';
import 'package:klasik_lezzetler/main.dart';

void main() {
  testWidgets('Ozcook ana ekranı açılır', (WidgetTester tester) async {
    await tester.pumpWidget(const OzcookApp());
    await tester.pumpAndSettle();

    expect(find.byType(OzcookApp), findsOneWidget);
  });
}