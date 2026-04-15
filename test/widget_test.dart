import 'package:flutter_test/flutter_test.dart';
import 'package:recycle_market/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const RecycleMarketApp());
    expect(find.text('RecycleLink'), findsOneWidget);
  });
}
