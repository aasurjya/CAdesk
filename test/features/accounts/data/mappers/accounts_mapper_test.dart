import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/accounts/data/mappers/accounts_mapper.dart';
import 'package:ca_app/features/accounts/domain/models/financial_statement.dart';

void main() {
  group('AccountsMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'fs-001',
          'client_id': 'client-001',
          'client_name': 'Mehta Traders',
          'statement_type': 'profitLoss',
          'financial_year': 'FY 2024-25',
          'format': 'vertical',
          'prepared_by': 'CA Sharma',
          'prepared_date': '2025-09-01T00:00:00.000Z',
          'approved_date': '2025-09-05T00:00:00.000Z',
          'status': 'approved',
          'total_assets': 5000000.0,
          'total_liabilities': 2000000.0,
          'net_profit': 1500000.0,
        };

        final s = AccountsMapper.fromJson(json);

        expect(s.id, 'fs-001');
        expect(s.clientId, 'client-001');
        expect(s.clientName, 'Mehta Traders');
        expect(s.statementType, StatementType.profitLoss);
        expect(s.financialYear, 'FY 2024-25');
        expect(s.format, StatementFormat.vertical);
        expect(s.preparedBy, 'CA Sharma');
        expect(s.approvedDate, isNotNull);
        expect(s.status, StatementStatus.approved);
        expect(s.totalAssets, 5000000.0);
        expect(s.totalLiabilities, 2000000.0);
        expect(s.netProfit, 1500000.0);
      });

      test('handles null approved_date', () {
        final json = {
          'id': 'fs-002',
          'client_id': 'client-002',
          'client_name': '',
          'statement_type': 'balanceSheet',
          'financial_year': 'FY 2024-25',
          'format': 'horizontal',
          'prepared_by': 'CA Kumar',
          'prepared_date': '2025-08-01T00:00:00.000Z',
          'status': 'draft',
          'total_assets': 0.0,
          'total_liabilities': 0.0,
          'net_profit': 0.0,
        };

        final s = AccountsMapper.fromJson(json);
        expect(s.approvedDate, isNull);
        expect(s.format, StatementFormat.horizontal);
      });

      test('defaults statement_type to balanceSheet for unknown value', () {
        final json = {
          'id': 'fs-003',
          'client_id': 'c1',
          'client_name': '',
          'statement_type': 'unknownType',
          'financial_year': '',
          'format': 'vertical',
          'prepared_by': '',
          'prepared_date': '2025-01-01T00:00:00.000Z',
          'status': 'draft',
          'total_assets': 0.0,
          'total_liabilities': 0.0,
          'net_profit': 0.0,
        };

        final s = AccountsMapper.fromJson(json);
        expect(s.statementType, StatementType.balanceSheet);
      });

      test('defaults status to draft for unknown value', () {
        final json = {
          'id': 'fs-004',
          'client_id': 'c1',
          'client_name': '',
          'statement_type': 'cashFlow',
          'financial_year': '',
          'format': 'vertical',
          'prepared_by': '',
          'prepared_date': '2025-01-01T00:00:00.000Z',
          'status': 'unknownStatus',
          'total_assets': 0.0,
          'total_liabilities': 0.0,
          'net_profit': 0.0,
        };

        final s = AccountsMapper.fromJson(json);
        expect(s.statementType, StatementType.cashFlow);
        expect(s.status, StatementStatus.draft);
      });

      test('handles all StatementType values', () {
        for (final type in StatementType.values) {
          final json = {
            'id': 'fs-type-${type.name}',
            'client_id': 'c1',
            'client_name': '',
            'statement_type': type.name,
            'financial_year': '',
            'format': 'vertical',
            'prepared_by': '',
            'prepared_date': '2025-01-01T00:00:00.000Z',
            'status': 'draft',
            'total_assets': 0.0,
            'total_liabilities': 0.0,
            'net_profit': 0.0,
          };
          final s = AccountsMapper.fromJson(json);
          expect(s.statementType, type);
        }
      });

      test('converts numeric monetary values to double', () {
        final json = {
          'id': 'fs-005',
          'client_id': 'c1',
          'client_name': '',
          'statement_type': 'balanceSheet',
          'financial_year': '',
          'format': 'vertical',
          'prepared_by': '',
          'prepared_date': '2025-01-01T00:00:00.000Z',
          'status': 'draft',
          'total_assets': 5000000,
          'total_liabilities': 2000000,
          'net_profit': 1500000,
        };

        final s = AccountsMapper.fromJson(json);
        expect(s.totalAssets, 5000000.0);
        expect(s.totalAssets, isA<double>());
      });

      test('handles null monetary values with 0.0 default', () {
        final json = {
          'id': 'fs-006',
          'client_id': 'c1',
          'client_name': '',
          'statement_type': 'balanceSheet',
          'financial_year': '',
          'format': 'vertical',
          'prepared_by': '',
          'prepared_date': '2025-01-01T00:00:00.000Z',
          'status': 'draft',
          'total_assets': null,
          'total_liabilities': null,
          'net_profit': null,
        };

        final s = AccountsMapper.fromJson(json);
        expect(s.totalAssets, 0.0);
        expect(s.totalLiabilities, 0.0);
        expect(s.netProfit, 0.0);
      });
    });

    group('toJson', () {
      late FinancialStatement sampleStatement;

      setUp(() {
        sampleStatement = FinancialStatement(
          id: 'fs-json-001',
          clientId: 'client-json-001',
          clientName: 'Sample Corp',
          statementType: StatementType.cashFlow,
          financialYear: 'FY 2024-25',
          format: StatementFormat.horizontal,
          preparedBy: 'CA Mehta',
          preparedDate: DateTime(2025, 9, 1),
          approvedDate: DateTime(2025, 9, 10),
          status: StatementStatus.filed,
          totalAssets: 8000000.0,
          totalLiabilities: 3000000.0,
          netProfit: 2500000.0,
        );
      });

      test('includes all fields', () {
        final json = AccountsMapper.toJson(sampleStatement);

        expect(json['id'], 'fs-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['client_name'], 'Sample Corp');
        expect(json['statement_type'], 'cashFlow');
        expect(json['financial_year'], 'FY 2024-25');
        expect(json['format'], 'horizontal');
        expect(json['prepared_by'], 'CA Mehta');
        expect(json['status'], 'filed');
        expect(json['total_assets'], 8000000.0);
        expect(json['total_liabilities'], 3000000.0);
        expect(json['net_profit'], 2500000.0);
      });

      test('serializes prepared_date and approved_date as ISO strings', () {
        final json = AccountsMapper.toJson(sampleStatement);
        expect(json['prepared_date'], startsWith('2025-09-01'));
        expect(json['approved_date'], startsWith('2025-09-10'));
      });

      test('serializes null approved_date as null', () {
        final draft = FinancialStatement(
          id: 'fs-draft',
          clientId: 'c1',
          clientName: '',
          statementType: StatementType.balanceSheet,
          financialYear: '',
          format: StatementFormat.vertical,
          preparedBy: '',
          preparedDate: DateTime(2025, 1, 1),
          status: StatementStatus.draft,
          totalAssets: 0.0,
          totalLiabilities: 0.0,
          netProfit: 0.0,
        );
        final json = AccountsMapper.toJson(draft);
        expect(json['approved_date'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = AccountsMapper.toJson(sampleStatement);
        final restored = AccountsMapper.fromJson(json);

        expect(restored.id, sampleStatement.id);
        expect(restored.clientId, sampleStatement.clientId);
        expect(restored.statementType, sampleStatement.statementType);
        expect(restored.format, sampleStatement.format);
        expect(restored.status, sampleStatement.status);
        expect(restored.totalAssets, sampleStatement.totalAssets);
        expect(restored.netProfit, sampleStatement.netProfit);
      });
    });
  });
}
