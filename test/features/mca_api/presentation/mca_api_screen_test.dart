import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/mca_api/presentation/mca_api_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: McaApiScreen()));

void main() {
  group('McaApiScreen', () {
    testWidgets('renders MCA API title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('MCA API'), findsOneWidget);
    });

    testWidgets('renders Ministry of Corporate Affairs subtitle', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Ministry of Corporate Affairs'), findsOneWidget);
    });

    testWidgets('renders MCA Portal Integration banner text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('MCA Portal Integration'), findsOneWidget);
    });

    testWidgets('renders CIN / Company Search section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('CIN / Company Search'), findsOneWidget);
    });

    testWidgets('renders company search hint text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Search by CIN or company name'),
        findsOneWidget,
      );
    });

    testWidgets('renders Director DIN Lookup section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Director DIN Lookup'), findsOneWidget);
    });

    testWidgets('renders DIN TextField', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders Director DIN label in field', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Director DIN'), findsOneWidget);
    });

    testWidgets('renders Lookup Director button', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Lookup Director'), findsOneWidget);
    });

    testWidgets('renders Filing History section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Filing History'), findsOneWidget);
    });

    testWidgets('renders Load Filing History button', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Load Filing History'), findsOneWidget);
    });

    testWidgets('renders Annual Return Compliance section header', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Annual Return Compliance'), findsOneWidget);
    });

    testWidgets('renders Annual Return Status card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Annual Return Status'), findsOneWidget);
    });

    testWidgets('renders MGT-7 form compliance row', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('MGT-7'), findsOneWidget);
    });

    testWidgets('renders AOC-4 form compliance row', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('AOC-4'), findsOneWidget);
    });
  });
}
