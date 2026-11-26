import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bajrang/app/app.dart';
import 'package:bajrang/core/services/local_storage_service.dart';

void main() {
  testWidgets('App launches successfully smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.initialize();

    await tester.pumpWidget(
      const ProviderScope(
        child: RamSevaApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(RamSevaApp), findsOneWidget);
  });
}
