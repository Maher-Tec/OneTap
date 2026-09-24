import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onetap/main.dart';

void main() {
  testWidgets('OneTapApp renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OneTapApp(),
      ),
    );

    expect(find.byType(OneTapApp), findsOneWidget);
  });
}
