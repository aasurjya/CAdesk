import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/portal_parser/presentation/portal_parser_screen.dart';
import 'package:ca_app/features/portal_parser/presentation/widgets/import_record_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: PortalParserScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PortalParserScreen', () {
    testWidgets('renders Portal Import title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Portal Import'), findsOneWidget);
    });

    testWidgets('renders Completed metric tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsWidgets);
    });

    testWidgets('renders Pending metric tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('renders Failed metric tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Failed'), findsWidgets);
    });

    testWidgets('renders All filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsWidgets);
    });

    testWidgets('renders Import File FAB', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Import File'), findsOneWidget);
    });

    testWidgets('FAB has upload icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.upload_rounded), findsWidgets);
    });

    testWidgets('body uses Column layout', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('filter chips row is horizontally scrollable', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('shows ImportRecordTile or loading or empty state', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final hasContent =
          find.byType(ImportRecordTile).evaluate().isNotEmpty ||
          find.text('No import records found').evaluate().isNotEmpty ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(hasContent, isTrue);
    });

    testWidgets('summary card shows check_circle icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_outline_rounded), findsWidgets);
    });

    testWidgets('summary card shows hourglass icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.hourglass_top_rounded), findsWidgets);
    });

    testWidgets('summary card shows error icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);
    });

    testWidgets('tapping All filter chip does not throw', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('All').first);
      await tester.pumpAndSettle();

      expect(find.text('Portal Import'), findsOneWidget);
    });

    testWidgets('summary metric containers present', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('GestureDetector chips present in filter row', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}
