import 'package:flutter_test/flutter_test.dart';
import 'package:rsme_mobile/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RSMEApp());
    expect(find.text('RSME'), findsOneWidget);
  });
}
