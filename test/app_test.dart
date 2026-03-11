import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/app.dart';

void main() {
  group('CADesk', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CAApp()));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('uses Material 3', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CAApp()));
      await tester.pumpAndSettle();
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, isTrue);
    });

    testWidgets('has dark theme configured', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CAApp()));
      await tester.pumpAndSettle();
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('debug banner is disabled', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CAApp()));
      await tester.pumpAndSettle();
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });
}
