import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/clients/presentation/client_360_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _testId = 'test-360';

final _testClient = Client(
  id: _testId,
  name: 'Rajesh Kumar Sharma',
  pan: 'ABCPS1234A',
  email: 'rajesh@example.com',
  phone: '9876543210',
  alternatePhone: '9111222333',
  aadhaar: '1234 5678 9012',
  gstin: '27ABCPS1234A1Z5',
  tan: 'MUMB12345A',
  clientType: ClientType.individual,
  address: '42, MG Road, Bandra West',
  city: 'Mumbai',
  state: 'Maharashtra',
  pincode: '400050',
  servicesAvailed: [ServiceType.itrFiling, ServiceType.gstFiling],
  status: ClientStatus.active,
  createdAt: DateTime(2024, 1, 10),
  updatedAt: DateTime(2026, 3, 1),
  notes: 'Senior manager at TCS. Files ITR-2 every year.',
  dateOfBirth: DateTime(1975, 6, 15),
);

const _testHealthScore = ClientHealthScore(
  clientId: _testId,
  overallScore: 85,
  itrStatus: 'Filed',
  gstStatus: 'Compliant',
  tdsStatus: 'N/A',
  pendingActions: ['Upload Form 16 for AY 2026-27'],
  lastUpdated: 'Mar 2026',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> pumpClient360(
  WidgetTester tester, {
  Client? client,
  ClientHealthScore? healthScore,
}) async {
  final effectiveClient = client ?? _testClient;
  final effectiveHealth = healthScore ?? _testHealthScore;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clientByIdProvider(_testId).overrideWith((ref) => effectiveClient),
        clientHealthScoreProvider(
          _testId,
        ).overrideWith((ref) => effectiveHealth),
      ],
      child: const MaterialApp(home: Client360Screen(clientId: _testId)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpNotFound(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [clientByIdProvider(_testId).overrideWith((ref) => null)],
      child: const MaterialApp(home: Client360Screen(clientId: _testId)),
    ),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Client360Screen', () {
    testWidgets('renders 5 tabs', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      expect(find.byType(Tab), findsNWidgets(5));
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Compliance'), findsOneWidget);
      expect(find.text('Docs'), findsOneWidget);
      expect(find.text('Billing'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('default tab is Overview with contact info', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      // Overview tab content should be visible by default
      expect(find.text('Contact Information'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
    });

    testWidgets('shows client name and PAN in app bar', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      expect(find.text('Rajesh Kumar Sharma'), findsOneWidget);
      expect(find.text('ABCPS1234A'), findsOneWidget);
    });

    testWidgets('tapping Compliance tab shows health content', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      // Tap the Compliance tab
      await tester.tap(find.text('Compliance'));
      await tester.pumpAndSettle();

      // Should show compliance content
      expect(find.text('Compliance Score'), findsOneWidget);
      expect(find.text('Compliance Status'), findsOneWidget);
    });

    testWidgets('tapping Docs tab shows documents content', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();

      expect(find.text('Client Documents'), findsOneWidget);
      expect(find.text('Upload Document'), findsOneWidget);
      expect(find.text('PAN Card'), findsOneWidget);
    });

    testWidgets('tapping Billing tab shows billing content', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();

      expect(find.text('Outstanding Amount'), findsOneWidget);
      expect(find.text('Recent Invoices'), findsOneWidget);
    });

    testWidgets('tapping Notes tab shows client notes', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      expect(find.text('Client Notes'), findsOneWidget);
      expect(
        find.text('Senior manager at TCS. Files ITR-2 every year.'),
        findsOneWidget,
      );
    });

    testWidgets('all tabs render without overflow on tablet', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      // Overview (default)
      expect(tester.takeException(), isNull);

      // Compliance
      await tester.tap(find.text('Compliance'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Docs
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Billing
      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Notes
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows not-found when client does not exist', (tester) async {
      await setTabletViewport(tester);
      await pumpNotFound(tester);

      expect(find.text('Client not found'), findsOneWidget);
      // Should not have tabs
      expect(find.byType(Tab), findsNothing);
    });

    testWidgets('shows edit FAB', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('Overview tab shows services chips', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      expect(find.text('Services Availed'), findsOneWidget);
      expect(find.text('ITR Filing'), findsAtLeastNWidgets(1));
      expect(find.text('GST Filing'), findsAtLeastNWidgets(1));
    });

    testWidgets('Overview tab shows Quick Actions', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('File ITR'), findsOneWidget);
      expect(find.text('File GST'), findsOneWidget);
      expect(find.text('File TDS'), findsOneWidget);
    });

    testWidgets('Compliance tab shows pending actions', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      await tester.tap(find.text('Compliance'));
      await tester.pumpAndSettle();

      expect(find.text('Pending Actions (1)'), findsOneWidget);
      expect(find.text('Upload Form 16 for AY 2026-27'), findsOneWidget);
    });

    testWidgets('status badge shown in app bar', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows delete option in popup menu', (tester) async {
      await setTabletViewport(tester);
      await pumpClient360(tester);

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Delete Client'), findsOneWidget);
    });
  });
}
