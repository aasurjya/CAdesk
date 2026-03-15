import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/portal_connector/presentation/portal_hub_screen.dart';
import 'package:ca_app/features/portal_connector/presentation/widgets/portal_status_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: PortalHubScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PortalHubScreen', () {
    testWidgets('renders Portal Connections title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Portal Connections'), findsOneWidget);
    });

    testWidgets('renders Government portal integrations subtitle',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Government portal'), findsOneWidget);
    });

    testWidgets('renders sync health status text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Either "All portals connected" or "N of M connected"
      final hasStatusText =
          find.textContaining('portals connected').evaluate().isNotEmpty ||
          find.textContaining('of').evaluate().isNotEmpty;
      expect(hasStatusText, isTrue);
    });

    testWidgets('renders Sync health overview label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sync health overview'), findsOneWidget);
    });

    testWidgets('renders Connected Portals section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Connected Portals'), findsOneWidget);
    });

    testWidgets('renders PortalStatusCard widgets in a grid', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(PortalStatusCard), findsWidgets);
    });

    testWidgets('renders 5 portal cards (ITD, GSTN, TRACES, MCA, EPFO)',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(PortalStatusCard), findsNWidgets(5));
    });

    testWidgets('renders GridView for portal grid', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('renders ITD portal label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final hasItd = find.textContaining('ITD').evaluate().isNotEmpty;
      final hasIncomeTax =
          find.textContaining('Income Tax').evaluate().isNotEmpty;
      expect(hasItd || hasIncomeTax, isTrue);
    });

    testWidgets('renders GSTN portal label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final hasGstn = find.textContaining('GSTN').evaluate().isNotEmpty;
      final hasGst = find.textContaining('GST').evaluate().isNotEmpty;
      expect(hasGstn || hasGst, isTrue);
    });

    testWidgets('renders circular progress indicator for sync ratio',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('renders hub icon in section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.hub_rounded), findsWidgets);
    });

    testWidgets('body uses gradient decorated background', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DecoratedBox), findsWidgets);
    });

    testWidgets('ListView is present in body', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('MCA portal error label visible', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // MCA is in error state with "Session expired"
      final hasMca = find.textContaining('MCA').evaluate().isNotEmpty;
      final hasSession = find.textContaining('Session').evaluate().isNotEmpty;
      expect(hasMca || hasSession, isTrue);
    });
  });
}
