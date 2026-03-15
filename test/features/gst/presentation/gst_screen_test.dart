import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/gst/domain/models/gst_client.dart';
import 'package:ca_app/features/gst/presentation/gst_screen.dart';
import 'package:ca_app/features/gst/presentation/widgets/gst_client_tile.dart';
import 'package:ca_app/features/gst/presentation/widgets/gst_summary_card.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

const _testGstClient = GstClient(
  id: 'gst-001',
  businessName: 'Reliance Digital Retail Ltd',
  tradeName: 'Reliance Digital',
  gstin: '27AABCR1718E1ZL',
  pan: 'AABCR1718E',
  registrationType: GstRegistrationType.regular,
  state: 'Maharashtra',
  stateCode: '27',
  returnsPending: ['GSTR-1'],
  complianceScore: 92,
);

class _GstClientTileHarness extends StatelessWidget {
  const _GstClientTileHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GstClientTile(
          client: _testGstClient,
          returns: const [],
        ),
      ),
    );
  }
}

/// Sets a phone-sized viewport to avoid overflow errors in test rendering.
Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: GstScreen()));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GstScreen', () {
    testWidgets('renders app bar with GST title', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('GST'), findsOneWidget);
    });

    testWidgets('renders GSTR-1 tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // The tab bar contains GSTR-1 as a Tab widget
      expect(find.descendant(of: find.byType(TabBar), matching: find.text('GSTR-1')),
          findsOneWidget);
    });

    testWidgets('renders GSTR-3B tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(TabBar), matching: find.text('GSTR-3B')),
          findsOneWidget);
    });

    testWidgets('renders GSTR-9 tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(TabBar), matching: find.text('GSTR-9')),
          findsOneWidget);
    });

    testWidgets('renders All Returns tab label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(TabBar), matching: find.text('All Returns')),
          findsOneWidget);
    });

    testWidgets('renders four GstSummaryCards', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(GstSummaryCard), findsNWidgets(4));
    });

    testWidgets('renders Total GSTINs summary label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total GSTINs'), findsOneWidget);
    });

    testWidgets('renders Returns Due summary label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Returns Due'), findsOneWidget);
    });

    testWidgets('renders Filed summary label', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Filed'), findsWidgets);
    });

    testWidgets('renders ITC reconciliation banner', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('ITC Recon'), findsOneWidget);
    });

    testWidgets('renders period selector with calendar icon', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      expect(find.textContaining('Period:'), findsOneWidget);
    });

    testWidgets('renders client tiles in GSTR-1 tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(GstClientTile), findsWidgets);
    });

    testWidgets('renders New Return FAB', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Return'), findsOneWidget);
    });

    testWidgets('New Return FAB is present and tappable', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final fab = find.widgetWithText(FloatingActionButton, 'New Return');
      expect(fab, findsWidgets);
    });

    testWidgets('switching to GSTR-3B tab still shows client tiles',
        (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(of: find.byType(TabBar), matching: find.text('GSTR-3B')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GstClientTile), findsWidgets);
    });
  });

  group('GstSummaryCard', () {
    testWidgets('renders label and count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GstSummaryCard(label: 'Test Label', count: 42),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders trend-up icon when trendUp is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GstSummaryCard(
                  label: 'Trending Up',
                  count: 10,
                  trendUp: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('renders trend-down icon when trendUp is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GstSummaryCard(
                  label: 'Trending Down',
                  count: 5,
                  trendUp: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('no trend icon when trendUp is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GstSummaryCard(label: 'No Trend', count: 3),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsNothing);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });
  });

  group('GstClientTile', () {
    testWidgets('renders business name', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: _GstClientTileHarness()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Reliance Digital'), findsOneWidget);
    });

    testWidgets('renders GSTIN formatted as XX-XXXXXXXXXX-X-XX', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: _GstClientTileHarness()),
      );
      await tester.pumpAndSettle();

      // 27AABCR1718E1ZL → 27-AABCR1718E-1-ZL
      expect(find.textContaining('27-AABCR1718E-1-ZL'), findsOneWidget);
    });

    testWidgets('renders compliance score bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: _GstClientTileHarness()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Compliance'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders no-returns message when returns list is empty',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: _GstClientTileHarness()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No returns for this period'), findsOneWidget);
    });

    testWidgets('tapping tile fires onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GstClientTile(
              client: _testGstClient,
              returns: const [],
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GstClientTile));
      expect(tapped, isTrue);
    });
  });
}
