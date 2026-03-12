import 'package:ca_app/features/ocr/domain/models/extracted_bank_statement.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_transaction.dart';
import 'package:ca_app/features/ocr/domain/services/ocr_data_mapper_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mapper = OcrDataMapperService.instance;

  const sampleForm16 = ExtractedForm16(
    employeePan: 'ABCDE1234F',
    employerTan: 'AAATA1234X',
    employerName: 'ABC COMPANY PVT LTD',
    financialYear: 2024,
    assessmentYear: '2024-25',
    grossSalary: 60000000, // 600000 INR
    taxableIncome: 55000000, // 550000 INR
    tdsDeducted: 1500000, // 15000 INR
    professionalTax: 0,
    standardDeduction: 5000000, // 50000 INR
    confidence: 0.95,
  );

  // ---------------------------------------------------------------------------
  // mapToItrIncome
  // ---------------------------------------------------------------------------
  group('OcrDataMapperService.mapToItrIncome', () {
    test('returns a non-empty map', () {
      final result = mapper.mapToItrIncome(sampleForm16);
      expect(result, isNotEmpty);
    });

    test('grossSalary key maps to correct paise value', () {
      final result = mapper.mapToItrIncome(sampleForm16);
      expect(result['grossSalary'], 60000000);
    });

    test('taxableIncome key maps to correct paise value', () {
      final result = mapper.mapToItrIncome(sampleForm16);
      expect(result['taxableIncome'], 55000000);
    });

    test('standardDeduction key maps to correct paise value', () {
      final result = mapper.mapToItrIncome(sampleForm16);
      expect(result['standardDeduction'], 5000000);
    });

    test('tdsDeducted key is present', () {
      final result = mapper.mapToItrIncome(sampleForm16);
      expect(result.containsKey('tdsDeducted'), isTrue);
    });

    test('all values are non-negative integers', () {
      final result = mapper.mapToItrIncome(sampleForm16);
      for (final entry in result.entries) {
        expect(entry.value, greaterThanOrEqualTo(0),
            reason: '${entry.key} should be non-negative');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // mapToTdsEntry
  // ---------------------------------------------------------------------------
  group('OcrDataMapperService.mapToTdsEntry', () {
    test('returns a TdsEntry with correct deducteePan', () {
      final entry = mapper.mapToTdsEntry(sampleForm16);
      expect(entry.deducteePan, 'ABCDE1234F');
    });

    test('tdsDeducted matches form16 value', () {
      final entry = mapper.mapToTdsEntry(sampleForm16);
      expect(entry.tdsDeducted, 1500000);
    });

    test('deductorTan matches employerTan', () {
      final entry = mapper.mapToTdsEntry(sampleForm16);
      expect(entry.deductorTan, 'AAATA1234X');
    });

    test('assessmentYear is set correctly', () {
      final entry = mapper.mapToTdsEntry(sampleForm16);
      expect(entry.assessmentYear, '2024-25');
    });

    test('grossAmount matches grossSalary', () {
      final entry = mapper.mapToTdsEntry(sampleForm16);
      expect(entry.grossAmount, 60000000);
    });
  });

  // ---------------------------------------------------------------------------
  // mapTransactionsToJournalEntries
  // ---------------------------------------------------------------------------
  group('OcrDataMapperService.mapTransactionsToJournalEntries', () {
    final statement = ExtractedBankStatement(
      accountNumber: 'XXXX1234',
      bankName: 'SBI',
      ifscCode: 'SBIN0001234',
      period: 'Apr 2023',
      openingBalance: 5000000,
      closingBalance: 9900000,
      transactions: [
        ExtractedTransaction(
          date: DateTime(2023, 4, 1),
          description: 'UPI Payment',
          debit: 100000,
          credit: 0,
          balance: 4900000,
          referenceNumber: null,
        ),
        ExtractedTransaction(
          date: DateTime(2023, 4, 5),
          description: 'Salary Credit',
          debit: 0,
          credit: 5000000,
          balance: 9900000,
          referenceNumber: 'REF001',
        ),
      ],
    );

    test('returns one journal entry per transaction', () {
      final entries = mapper.mapTransactionsToJournalEntries(statement);
      expect(entries.length, 2);
    });

    test('debit transaction creates correct journal entry', () {
      final entries = mapper.mapTransactionsToJournalEntries(statement);
      final debitEntry = entries[0];
      expect(debitEntry.amount, 100000);
      expect(debitEntry.isDebit, isTrue);
    });

    test('credit transaction creates correct journal entry', () {
      final entries = mapper.mapTransactionsToJournalEntries(statement);
      final creditEntry = entries[1];
      expect(creditEntry.amount, 5000000);
      expect(creditEntry.isDebit, isFalse);
    });

    test('journal entry dates match transaction dates', () {
      final entries = mapper.mapTransactionsToJournalEntries(statement);
      expect(entries[0].date, DateTime(2023, 4, 1));
      expect(entries[1].date, DateTime(2023, 4, 5));
    });

    test('journal entry descriptions match transaction descriptions', () {
      final entries = mapper.mapTransactionsToJournalEntries(statement);
      expect(entries[0].description, contains('UPI Payment'));
      expect(entries[1].description, contains('Salary Credit'));
    });

    test('referenceNumber is propagated when present', () {
      final entries = mapper.mapTransactionsToJournalEntries(statement);
      expect(entries[1].referenceNumber, 'REF001');
    });

    test('empty transactions returns empty list', () {
      final emptyStmt = statement.copyWith(transactions: const []);
      final entries = mapper.mapTransactionsToJournalEntries(emptyStmt);
      expect(entries, isEmpty);
    });
  });
}
