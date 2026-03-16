import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/cma/data/mappers/cma_mapper.dart';
import 'package:ca_app/features/cma/domain/models/cma_report.dart';

void main() {
  group('CmaMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'cma-001',
          'client_id': 'client-001',
          'client_name': 'ABC Industries',
          'bank_name': 'State Bank of India',
          'loan_purpose': 'Working Capital',
          'projection_years': 3,
          'status': 'submitted',
          'prepared_date': '2025-09-01T00:00:00.000Z',
          'submitted_date': '2025-09-10T00:00:00.000Z',
          'requested_amount': 5000000.0,
          'sanctioned_amount': 4500000.0,
          'projections': [
            {
              'year': 2025,
              'sales': 10000000.0,
              'cogs': 6000000.0,
              'gross_profit': 4000000.0,
              'operating_expenses': 2000000.0,
              'ebitda': 2000000.0,
              'net_profit': 1500000.0,
              'current_assets': 3000000.0,
              'current_liabilities': 1500000.0,
              'total_debt': 4500000.0,
              'net_worth': 5000000.0,
              'dscr': 1.45,
              'mpbf': 1000000.0,
            },
          ],
        };

        final report = CmaMapper.fromJson(json);

        expect(report.id, 'cma-001');
        expect(report.clientId, 'client-001');
        expect(report.clientName, 'ABC Industries');
        expect(report.bankName, 'State Bank of India');
        expect(report.loanPurpose, 'Working Capital');
        expect(report.projectionYears, 3);
        expect(report.status, CmaReportStatus.submitted);
        expect(report.submittedDate, isNotNull);
        expect(report.requestedAmount, 5000000.0);
        expect(report.sanctionedAmount, 4500000.0);
        expect(report.projections.length, 1);
        expect(report.projections[0].year, 2025);
        expect(report.projections[0].dscr, 1.45);
      });

      test('handles null submitted_date and sanctioned_amount', () {
        final json = {
          'id': 'cma-002',
          'client_id': 'c1',
          'client_name': '',
          'bank_name': '',
          'loan_purpose': '',
          'projection_years': 1,
          'status': 'draft',
          'prepared_date': '2025-01-01T00:00:00.000Z',
          'requested_amount': 1000000.0,
          'projections': <dynamic>[],
        };

        final report = CmaMapper.fromJson(json);
        expect(report.submittedDate, isNull);
        expect(report.sanctionedAmount, isNull);
        expect(report.projections, isEmpty);
      });

      test('handles empty projections list', () {
        final json = {
          'id': 'cma-003',
          'client_id': 'c1',
          'client_name': '',
          'bank_name': '',
          'loan_purpose': '',
          'projection_years': 1,
          'status': 'draft',
          'prepared_date': '2025-01-01T00:00:00.000Z',
          'requested_amount': 0.0,
          'projections': <dynamic>[],
        };

        final report = CmaMapper.fromJson(json);
        expect(report.projections, isEmpty);
      });

      test('defaults status to draft for unknown value', () {
        final json = {
          'id': 'cma-004',
          'client_id': 'c1',
          'client_name': '',
          'bank_name': '',
          'loan_purpose': '',
          'projection_years': 1,
          'status': 'unknownStatus',
          'prepared_date': '2025-01-01T00:00:00.000Z',
          'requested_amount': 0.0,
          'projections': <dynamic>[],
        };

        final report = CmaMapper.fromJson(json);
        expect(report.status, CmaReportStatus.draft);
      });

      test('handles all CmaReportStatus values', () {
        for (final status in CmaReportStatus.values) {
          final json = {
            'id': 'cma-status-${status.name}',
            'client_id': 'c1',
            'client_name': '',
            'bank_name': '',
            'loan_purpose': '',
            'projection_years': 1,
            'status': status.name,
            'prepared_date': '2025-01-01T00:00:00.000Z',
            'requested_amount': 0.0,
            'projections': <dynamic>[],
          };
          final report = CmaMapper.fromJson(json);
          expect(report.status, status);
        }
      });

      test('handles integer monetary values for projections', () {
        final json = {
          'id': 'cma-005',
          'client_id': 'c1',
          'client_name': '',
          'bank_name': '',
          'loan_purpose': '',
          'projection_years': 1,
          'status': 'draft',
          'prepared_date': '2025-01-01T00:00:00.000Z',
          'requested_amount': 2000000,
          'projections': [
            {
              'year': 2025,
              'sales': 5000000,
              'cogs': 3000000,
              'gross_profit': 2000000,
              'operating_expenses': 1000000,
              'ebitda': 1000000,
              'net_profit': 800000,
              'current_assets': 1500000,
              'current_liabilities': 750000,
              'total_debt': 2000000,
              'net_worth': 3000000,
              'dscr': 1,
              'mpbf': 500000,
            },
          ],
        };

        final report = CmaMapper.fromJson(json);
        expect(report.requestedAmount, 2000000.0);
        expect(report.projections[0].sales, 5000000.0);
        expect(report.projections[0].dscr, 1.0);
      });
    });

    group('toJson', () {
      late CmaReport sampleReport;

      setUp(() {
        sampleReport = CmaReport(
          id: 'cma-json-001',
          clientId: 'client-json-001',
          clientName: 'Test Industries',
          bankName: 'HDFC Bank',
          loanPurpose: 'Term Loan for Plant Expansion',
          projectionYears: 5,
          status: CmaReportStatus.approved,
          preparedDate: DateTime(2025, 8, 1),
          submittedDate: DateTime(2025, 8, 10),
          requestedAmount: 20000000.0,
          sanctionedAmount: 18000000.0,
          projections: const [
            YearProjection(
              year: 2026,
              sales: 15000000.0,
              cogs: 9000000.0,
              grossProfit: 6000000.0,
              operatingExpenses: 3000000.0,
              ebitda: 3000000.0,
              netProfit: 2500000.0,
              currentAssets: 5000000.0,
              currentLiabilities: 2000000.0,
              totalDebt: 18000000.0,
              netWorth: 10000000.0,
              dscr: 1.6,
              mpbf: 2000000.0,
            ),
          ],
        );
      });

      test('includes all fields', () {
        final json = CmaMapper.toJson(sampleReport);

        expect(json['id'], 'cma-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['client_name'], 'Test Industries');
        expect(json['bank_name'], 'HDFC Bank');
        expect(json['loan_purpose'], 'Term Loan for Plant Expansion');
        expect(json['projection_years'], 5);
        expect(json['status'], 'approved');
        expect(json['requested_amount'], 20000000.0);
        expect(json['sanctioned_amount'], 18000000.0);
        expect((json['projections'] as List).length, 1);
      });

      test('serializes dates as ISO strings', () {
        final json = CmaMapper.toJson(sampleReport);
        expect(json['prepared_date'], startsWith('2025-08-01'));
        expect(json['submitted_date'], startsWith('2025-08-10'));
      });

      test('serializes null submitted_date and sanctioned_amount as null', () {
        final draftReport = CmaReport(
          id: 'cma-draft',
          clientId: 'c1',
          clientName: '',
          bankName: '',
          loanPurpose: '',
          projectionYears: 1,
          status: CmaReportStatus.draft,
          preparedDate: DateTime(2025, 1, 1),
          requestedAmount: 0.0,
          projections: const [],
        );

        final json = CmaMapper.toJson(draftReport);
        expect(json['submitted_date'], isNull);
        expect(json['sanctioned_amount'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = CmaMapper.toJson(sampleReport);
        final restored = CmaMapper.fromJson(json);

        expect(restored.id, sampleReport.id);
        expect(restored.clientId, sampleReport.clientId);
        expect(restored.bankName, sampleReport.bankName);
        expect(restored.status, sampleReport.status);
        expect(restored.requestedAmount, sampleReport.requestedAmount);
        expect(restored.sanctionedAmount, sampleReport.sanctionedAmount);
        expect(restored.projections.length, sampleReport.projections.length);
        expect(restored.projections[0].dscr, sampleReport.projections[0].dscr);
      });
    });
  });
}
