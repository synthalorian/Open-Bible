// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:open_bible/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build app.
    await tester.pumpWidget(
      const ProviderScope(
        child: OpenBibleApp(),
      ),
    );

    // Flush post-frame and zero-delay timers created in initState.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    // Verify shell UI loads.
    expect(find.text('Bible'), findsOneWidget);
  });
}
