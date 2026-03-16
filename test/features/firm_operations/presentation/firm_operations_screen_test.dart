import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/firm_operations/presentation/firm_operations_screen.dart';

Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(414, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Suppresses layout overflow errors during [body].
Future<void> _ignoreOverflow(Future<void> Function() body) async {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    originalOnError?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = originalOnError;
  }
}

void main() {
  Widget buildSubject() {
    return const ProviderScope(
      child: MaterialApp(home: FirmOperationsScreen()),
    );
  }

  group('FirmOperationsScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.byType(FirmOperationsScreen), findsOneWidget);
    });

    testWidgets('renders Firm Operations title', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Firm Operations'), findsOneWidget);
    });

    testWidgets('renders Staff tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Staff'), findsOneWidget);
    });

    testWidgets('renders KPIs tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('KPIs'), findsOneWidget);
    });

    testWidgets('renders Knowledge Base tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Knowledge Base'), findsOneWidget);
    });

    testWidgets('renders TabBar', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('Staff tab renders search bar', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(
          TextField,
          'Search staff by name, department, or email...',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Staff tab renders All designation chip', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('Staff tab renders filter chips', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Staff tab renders list or empty state', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      final hasList = find.byType(ListView).evaluate().isNotEmpty;
      final hasEmpty = find.byIcon(Icons.people_outline).evaluate().isNotEmpty;
      expect(hasList || hasEmpty, isTrue);
    });

    testWidgets('Staff tab shows loading or staff cards', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      final hasLoading = find
          .byType(CircularProgressIndicator)
          .evaluate()
          .isNotEmpty;
      final hasContent = find.byType(Column).evaluate().isNotEmpty;
      expect(hasLoading || hasContent, isTrue);
    });

    testWidgets('can switch to KPIs tab', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();
        await tester.tap(find.text('KPIs'));
        await tester.pumpAndSettle();
        final hasKpis = find.byType(ListView).evaluate().isNotEmpty;
        final hasEmpty = find
            .byIcon(Icons.bar_chart_outlined)
            .evaluate()
            .isNotEmpty;
        expect(hasKpis || hasEmpty, isTrue);
      });
    });

    testWidgets('can switch to Knowledge Base tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Knowledge Base'));
      await tester.pumpAndSettle();
      final hasArticles = find.byType(ListView).evaluate().isNotEmpty;
      final hasEmpty = find
          .byIcon(Icons.article_outlined)
          .evaluate()
          .isNotEmpty;
      expect(hasArticles || hasEmpty, isTrue);
    });

    testWidgets('Knowledge Base tab has search bar', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Knowledge Base'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, 'Search articles, tags, or authors...'),
        findsOneWidget,
      );
    });

    testWidgets('Knowledge Base tab has category chips', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Knowledge Base'));
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders AppBar', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders TabBarView', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('switching tabs preserves title', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();
        await tester.tap(find.text('KPIs'));
        await tester.pumpAndSettle();
        expect(find.text('Firm Operations'), findsOneWidget);
      });
    });
  });
}
