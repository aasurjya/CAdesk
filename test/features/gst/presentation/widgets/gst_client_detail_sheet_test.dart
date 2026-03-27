import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/gst/data/providers/gst_providers.dart';
import 'package:ca_app/features/gst/domain/models/gst_client.dart';
import 'package:ca_app/features/gst/presentation/widgets/gst_client_detail_sheet.dart';
// ignore_for_file: unused_import

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  GstClient makeClient({String id = 'gst-001'}) {
    return GstClient(
      id: id,
      businessName: 'XYZ Traders Pvt Ltd',
      gstin: '27AABCX1234K1Z5',
      pan: 'AABCX1234K',
      registrationType: GstRegistrationType.regular,
      state: 'Maharashtra',
      stateCode: '27',
      returnsPending: const [],
      complianceScore: 85,
    );
  }

  Widget buildSheet(String clientId, {GstClient? client}) {
    final c = client ?? makeClient(id: clientId);
    return ProviderScope(
      overrides: [
        gstClientsProvider.overrideWithValue([c]),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => GstClientDetailSheet(clientId: clientId),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('GstClientDetailSheet', () {
    testWidgets('renders without crashing', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet('gst-001'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(GstClientDetailSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows legal name', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet('gst-001'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('XYZ Traders'), findsWidgets);
    });

    testWidgets('shows GSTIN', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet('gst-001'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // GSTIN is formatted with dashes: 27-AABCX1234K-1-Z5
      expect(find.textContaining('AABCX1234K'), findsWidgets);
    });

    testWidgets('shows registration type', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet('gst-001'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Regular'), findsWidgets);
    });

    testWidgets('uses DraggableScrollableSheet', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet('gst-001'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('renders compliance score', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet('gst-001'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Compliance score 85 is shown in the ring
      expect(find.textContaining('85'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
