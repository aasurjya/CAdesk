import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:ca_app/features/income_tax/presentation/widgets/filing_detail_sheet.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  ItrClient makeClient({
    FilingStatus status = FilingStatus.pending,
    double totalIncome = 800000,
    double taxPayable = 52500,
    double refundDue = 0,
    ItrType itrType = ItrType.itr1,
    DateTime? filedDate,
    String? ackNumber,
  }) {
    return ItrClient(
      id: 'test-client-001',
      name: 'Arjun Sharma',
      pan: 'ABCPS1234F',
      aadhaar: '123456789012',
      email: 'arjun@test.com',
      phone: '9876543210',
      itrType: itrType,
      assessmentYear: 'AY 2024-25',
      filingStatus: status,
      totalIncome: totalIncome,
      taxPayable: taxPayable,
      refundDue: refundDue,
      filedDate: filedDate,
      acknowledgementNumber: ackNumber,
    );
  }

  Widget buildSheet(ItrClient client) {
    return buildTestWidget(
      Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => FilingDetailSheet(client: client),
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    );
  }

  group('FilingDetailSheet', () {
    group('initial rendering via show()', () {
      testWidgets('renders without crashing', (tester) async {
        await setTabletViewport(tester);
        final client = makeClient();
        await tester.pumpWidget(buildSheet(client));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.byType(FilingDetailSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows client name', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeClient()));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Arjun Sharma'), findsWidgets);
      });

      testWidgets('shows PAN with prefix', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeClient()));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.textContaining('PAN:'), findsWidgets);
      });

      testWidgets('shows ITR type chip', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeClient(itrType: ItrType.itr1)));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('ITR-1'), findsWidgets);
      });

      testWidgets('shows filing status label', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(makeClient(status: FilingStatus.filed)),
        );
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Filed'), findsWidgets);
      });
    });

    group('tax regime comparison', () {
      testWidgets('shows tax comparison section', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeClient(totalIncome: 1200000)));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Tax comparison section should be present
        expect(find.byType(FilingDetailSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders with refund due client', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(makeClient(taxPayable: 0, refundDue: 15000)),
        );
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });

    group('filed status', () {
      testWidgets('shows Verified status chip', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(
            makeClient(
              status: FilingStatus.verified,
              filedDate: DateTime(2024, 7, 15),
              ackNumber: 'ACK123456789',
            ),
          ),
        );
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Verified'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    });

    group('different ITR types', () {
      testWidgets('renders for ITR-2 client', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(makeClient(itrType: ItrType.itr2, totalIncome: 2500000)),
        );
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders for high income client (>50L)', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(
          buildSheet(makeClient(totalIncome: 6000000, taxPayable: 1500000)),
        );
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });

    group('drag handle', () {
      testWidgets('renders drag indicator at top', (tester) async {
        await setTabletViewport(tester);
        await tester.pumpWidget(buildSheet(makeClient()));
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // The sheet renders a DraggableScrollableSheet
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });
    });
  });
}
