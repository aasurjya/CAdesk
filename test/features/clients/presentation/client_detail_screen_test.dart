import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/clients/presentation/client_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _testId = 'test-001';

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

/// Builds the screen with a client loaded via a provider override.
Future<void> pumpDetail(WidgetTester tester, {Client? client}) async {
  final id = client?.id ?? _testId;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clientByIdProvider(
          _testId,
        ).overrideWith((ref) => client ?? _testClient),
      ],
      child: MaterialApp(home: ClientDetailScreen(clientId: id)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpNotFound(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [clientByIdProvider(_testId).overrideWith((ref) => null)],
      child: const MaterialApp(home: ClientDetailScreen(clientId: _testId)),
    ),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ClientDetailScreen', () {
    testWidgets('renders without crash when client exists', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows client name in hero app bar', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Rajesh Kumar Sharma'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows PAN in hero area', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('ABCPS1234A'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Contact Information section', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Contact Information'), findsOneWidget);
    });

    testWidgets('shows phone number', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('9876543210'), findsOneWidget);
    });

    testWidgets('shows email address', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('rajesh@example.com'), findsOneWidget);
    });

    testWidgets('shows Services Availed section with ITR Filing chip', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Services Availed'), findsOneWidget);
      expect(find.text('ITR Filing'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Quick Actions section', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('shows File ITR quick action button', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('File ITR'), findsOneWidget);
    });

    testWidgets('shows Documents section', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Documents'), findsOneWidget);
    });

    testWidgets('shows notes text content', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      // Scroll to the bottom to reveal the notes section
      await tester.dragUntilVisible(
        find.text('Senior manager at TCS. Files ITR-2 every year.'),
        find.byType(CustomScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Senior manager at TCS. Files ITR-2 every year.'),
        findsOneWidget,
      );
    });

    testWidgets('shows edit FAB', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('shows not-found scaffold when client does not exist', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await pumpNotFound(tester);

      expect(find.text('Client not found'), findsOneWidget);
    });

    testWidgets('shows GSTIN in contact section when present', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('27ABCPS1234A1Z5'), findsOneWidget);
    });

    testWidgets('shows client type badge in hero area', (tester) async {
      await setTabletViewport(tester);
      await pumpDetail(tester);

      expect(find.text('Individual'), findsAtLeastNWidgets(1));
    });
  });
}
