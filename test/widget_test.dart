import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bajrang/app/app.dart';

void main() {
  testWidgets('App launches successfully smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BajrangSocietyApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(BajrangSocietyApp), findsOneWidget);
  });
}
