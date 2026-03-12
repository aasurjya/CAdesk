import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_balance_sheet.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_equity.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_assets.dart';
import 'package:ca_app/features/accounts/domain/services/schedule_iii_service.dart';

void main() {
  group('ScheduleIIIService', () {
    group('computeBalanceSheet', () {
      test('returns balanced sheet where total equity+liabilities equals total assets', () {
        // Simple set of journal entries: capital injection and asset purchase
        final entries = [
          JournalEntry(
            id: '1',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.shareCapital,
            amount: 1000000, // 10 lakh in paise = 10,00,000 paise
            isDebit: false,
          ),
          JournalEntry(
            id: '2',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.cashAndCashEquivalents,
            amount: 1000000,
            isDebit: true,
          ),
        ];

        final result = ScheduleIIIService.computeBalanceSheet(
          entries: entries,
          financialYear: 2025,
        );

        expect(result.isBalanced, isTrue);
        expect(result.totalEquityAndLiabilities, equals(result.totalAssets));
      });

      test('share capital is credited to equity section', () {
        final entries = [
          JournalEntry(
            id: '1',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.shareCapital,
            amount: 500000,
            isDebit: false,
          ),
          JournalEntry(
            id: '2',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.cashAndCashEquivalents,
            amount: 500000,
            isDebit: true,
          ),
        ];

        final result = ScheduleIIIService.computeBalanceSheet(
          entries: entries,
          financialYear: 2025,
        );

        expect(result.equity.shareCapital, equals(500000));
        expect(result.assets.cashAndCashEquivalents, equals(500000));
      });

      test('long-term borrowings appear in non-current liabilities', () {
        final entries = [
          JournalEntry(
            id: '1',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.longTermBorrowings,
            amount: 2000000,
            isDebit: false,
          ),
          JournalEntry(
            id: '2',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.fixedAssets,
            amount: 2000000,
            isDebit: true,
          ),
        ];

        final result = ScheduleIIIService.computeBalanceSheet(
          entries: entries,
          financialYear: 2025,
        );

        expect(result.equity.longTermBorrowings, equals(2000000));
        expect(result.assets.fixedAssets, equals(2000000));
        expect(result.isBalanced, isTrue);
      });

      test('trade payables appear in current liabilities', () {
        final entries = [
          JournalEntry(
            id: '1',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.tradePayables,
            amount: 300000,
            isDebit: false,
          ),
          JournalEntry(
            id: '2',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.inventories,
            amount: 300000,
            isDebit: true,
          ),
        ];

        final result = ScheduleIIIService.computeBalanceSheet(
          entries: entries,
          financialYear: 2025,
        );

        expect(result.equity.tradePayables, equals(300000));
        expect(result.assets.inventories, equals(300000));
        expect(result.isBalanced, isTrue);
      });

      test('balance sheet stores the financial year', () {
        final entries = [
          JournalEntry(
            id: '1',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.shareCapital,
            amount: 100000,
            isDebit: false,
          ),
          JournalEntry(
            id: '2',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.cashAndCashEquivalents,
            amount: 100000,
            isDebit: true,
          ),
        ];

        final result = ScheduleIIIService.computeBalanceSheet(
          entries: entries,
          financialYear: 2025,
        );

        expect(result.financialYear, equals(2025));
      });

      test('multiple entries of the same account head are aggregated', () {
        final entries = [
          JournalEntry(
            id: '1',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.shareCapital,
            amount: 200000,
            isDebit: false,
          ),
          JournalEntry(
            id: '2',
            date: DateTime(2025, 5, 1),
            accountHead: AccountHead.shareCapital,
            amount: 300000,
            isDebit: false,
          ),
          JournalEntry(
            id: '3',
            date: DateTime(2025, 4, 1),
            accountHead: AccountHead.cashAndCashEquivalents,
            amount: 500000,
            isDebit: true,
          ),
        ];

        final result = ScheduleIIIService.computeBalanceSheet(
          entries: entries,
          financialYear: 2025,
        );

        expect(result.equity.shareCapital, equals(500000));
        expect(result.isBalanced, isTrue);
      });

      test('empty entries produces a zero balance sheet', () {
        final result = ScheduleIIIService.computeBalanceSheet(
          entries: const [],
          financialYear: 2025,
        );

        expect(result.totalAssets, equals(0));
        expect(result.totalEquityAndLiabilities, equals(0));
        expect(result.isBalanced, isTrue);
      });
    });

    group('ScheduleIIIBalanceSheet model', () {
      test('copyWith returns updated instance', () {
        const original = ScheduleIIIBalanceSheet(
          financialYear: 2025,
          equity: ScheduleIIIEquity.zero,
          assets: ScheduleIIIAssets.zero,
          notes: [],
        );

        final updated = original.copyWith(financialYear: 2026);
        expect(updated.financialYear, equals(2026));
        expect(original.financialYear, equals(2025));
      });

      test('equality is value-based', () {
        const a = ScheduleIIIBalanceSheet(
          financialYear: 2025,
          equity: ScheduleIIIEquity.zero,
          assets: ScheduleIIIAssets.zero,
          notes: [],
        );
        const b = ScheduleIIIBalanceSheet(
          financialYear: 2025,
          equity: ScheduleIIIEquity.zero,
          assets: ScheduleIIIAssets.zero,
          notes: [],
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
