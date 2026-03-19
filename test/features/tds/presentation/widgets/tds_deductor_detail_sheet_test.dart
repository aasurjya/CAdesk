import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/tds/domain/models/tds_deductor.dart';
import 'package:ca_app/features/tds/presentation/widgets/tds_deductor_detail_sheet.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  TdsDeductor makeDeductor({DeductorType type = DeductorType.company}) {
    return TdsDeductor(
      id: 'ded-001',
      deductorName: 'ABC Pvt Ltd',
      tan: 'MUMA12345B',
      pan: 'AABCA1234K',
      deductorType: type,
      address: '123 MG Road, Mumbai 400001',
      email: 'tds@abcpvt.com',
      phone: '9876543210',
      responsiblePerson: 'Priya Sharma',
    );
  }

  Widget buildSheet(TdsDeductor deductor) {
    return buildTestWidget(
      Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => TdsDeductorDetailSheet(deductor: deductor),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('TdsDeductorDetailSheet', () {
    testWidgets('renders without crashing', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet(makeDeductor()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(TdsDeductorDetailSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows deductor name', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet(makeDeductor()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('ABC Pvt Ltd'), findsWidgets);
    });

    testWidgets('shows TAN number', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet(makeDeductor()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('MUMA12345B'), findsWidgets);
    });

    testWidgets('shows deductor type label', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(
        buildSheet(makeDeductor(type: DeductorType.company)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Company'), findsWidgets);
    });

    testWidgets('renders firm deductor type', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(
        buildSheet(makeDeductor(type: DeductorType.firm)),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Firm'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows TAN in header', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet(makeDeductor()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // TAN is shown as 'TAN: MUMA12345B'
      expect(find.textContaining('TAN:'), findsWidgets);
    });

    testWidgets('uses DraggableScrollableSheet', (tester) async {
      await setTabletViewport(tester);
      await tester.pumpWidget(buildSheet(makeDeductor()));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });
  });
}
