// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:open_bible/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OpenBibleApp(),
      ),
    );

    // Advance a few frames; in tests, some plugin-backed init can remain pending.
    await tester.pump(const Duration(milliseconds: 100));

    // Verify app root renders without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
