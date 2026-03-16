import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/gstn_api/presentation/gstn_api_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: GstnApiScreen()));

void main() {
  group('GstnApiScreen', () {
    testWidgets('renders GSTN API title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('GSTN API'), findsOneWidget);
    });

    testWidgets('renders GST Network integration hub subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('GST Network integration hub'), findsOneWidget);
    });

    testWidgets('renders API Usage label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('API Usage'), findsOneWidget);
    });

    testWidgets('renders usage progress indicator', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders remaining requests label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('requests remaining'), findsOneWidget);
    });

    testWidgets('renders GSTIN Lookup section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('GSTIN Lookup'), findsOneWidget);
    });

    testWidgets('renders search icon in GSTIN search bar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsWidgets);
    });

    testWidgets('renders GSTIN search hint text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Enter 15-character GSTIN'), findsOneWidget);
    });

    testWidgets('renders Filing Status section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Filing Status'), findsOneWidget);
    });

    testWidgets('renders fact check icon for Filing Status', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fact_check_rounded), findsOneWidget);
    });

    testWidgets('renders GSTR-2B ITC section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('GSTR-2B ITC'), findsOneWidget);
    });

    testWidgets('renders receipt long icon for GSTR-2B', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('renders Fetch GSTR-2B button when no data', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Fetch GSTR-2B'), findsOneWidget);
    });

    testWidgets('renders Auto-drafted ITC description text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Auto-drafted ITC statement'), findsOneWidget);
    });

    testWidgets('renders filing status no-data text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('No status checked yet'), findsOneWidget);
    });
  });
}
