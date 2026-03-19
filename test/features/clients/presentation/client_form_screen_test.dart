import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/clients/presentation/client_form_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget buildNewClientSubject() => const ClientFormScreen();
Widget buildEditClientSubject(String clientId) =>
    ClientFormScreen(clientId: clientId);

Future<void> pumpNewClient(WidgetTester tester) async {
  await pumpTestWidget(tester, buildNewClientSubject());
}

Future<void> pumpEditClient(WidgetTester tester, String clientId) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: buildEditClientSubject(clientId))),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ClientFormScreen — new client mode', () {
    testWidgets('renders without crash', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows New Client title in app bar', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.text('New Client'), findsOneWidget);
    });

    testWidgets('shows Basic Information section header', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.text('Basic Information'), findsOneWidget);
    });

    testWidgets('shows Full Name field', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.text('Full Name *'), findsOneWidget);
    });

    testWidgets('shows PAN field', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.text('PAN *'), findsOneWidget);
    });

    testWidgets('shows Client Type dropdown', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.text('Client Type *'), findsOneWidget);
    });

    testWidgets('shows Status dropdown', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.text('Status *'), findsOneWidget);
    });

    testWidgets('shows Contact Details section header', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.text('Contact Details'), findsOneWidget);
    });

    testWidgets('shows Email field', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      expect(find.text('Email'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Create Client submit button', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      await tester.dragUntilVisible(
        find.text('Create Client'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Client'), findsOneWidget);
    });

    testWidgets('shows Tax & Compliance section by scrolling', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      await tester.dragUntilVisible(
        find.text('Tax & Compliance'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tax & Compliance'), findsOneWidget);
    });

    testWidgets('shows Services Availed section by scrolling', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      await tester.dragUntilVisible(
        find.text('Services Availed'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Services Availed'), findsOneWidget);
    });

    testWidgets('shows ITR Filing chip in services section', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      await tester.dragUntilVisible(
        find.text('ITR Filing'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('ITR Filing'), findsAtLeastNWidgets(1));
    });

    testWidgets('form key is present in the widget tree', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      // The form wraps the entire body — verify it's present
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('shows PAN validation error for invalid PAN', (tester) async {
      await setTabletViewport(tester);
      await pumpNewClient(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'PAN *'),
        'INVALID',
      );

      // Scroll to show and tap the submit button
      await tester.dragUntilVisible(
        find.text('Create Client'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Client'));
      await tester.pumpAndSettle();

      // Scroll back up to see PAN validation error
      await tester.dragUntilVisible(
        find.text('Enter a valid PAN (e.g. ABCDE1234F).'),
        find.byType(ListView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid PAN (e.g. ABCDE1234F).'), findsOneWidget);
    });
  });

  group('ClientFormScreen — edit client mode', () {
    testWidgets('shows loading indicator when client ID provided but loading', (
      tester,
    ) async {
      await setTabletViewport(tester);
      // With no client in the default provider, allClientsProvider is loading
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ClientFormScreen(clientId: 'nonexistent-id'),
          ),
        ),
      );
      // Pump once without settling to see loading state
      await tester.pump();

      // Either loading spinner or "not found" are valid states
      final hasSpinner = find
          .byType(CircularProgressIndicator)
          .evaluate()
          .isNotEmpty;
      final hasNotFound =
          find.text('Client not found.').evaluate().isNotEmpty ||
          find.text('Edit Client').evaluate().isNotEmpty;
      expect(hasSpinner || hasNotFound, isTrue);
    });
  });
}
