import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_fund/main.dart';

void main() {
  testWidgets('App renders clean', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DreamFundApp()));
    expect(find.byType(DreamFundApp), findsOneWidget);
  });
}
