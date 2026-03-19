import 'package:ca_app/features/portal_parser/domain/models/form26as_data.dart';
import 'package:ca_app/features/portal_parser/domain/services/form26as_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Sample JSON payloads
// ---------------------------------------------------------------------------

const _validPayload = <String, Object?>{
  'Form26AS': {
    'PAN': 'ABCDE1234F',
    'AssessmentYear': '2025-26',
    'PartA': [
      {
        'TAN': 'MUMR12345A',
        'DeductorName': 'Acme Ltd',
        'Section': '192',
        'AmountPaid': 600000,
        'TaxDeducted': 60000,
        'TaxDeposited': 60000,
        'DepositDate': '2024-06-15',
        'BookingStatus': 'F',
      },
    ],
    'PartB': [
      {
        'TAN': 'DELX99999Z',
        'CollectorName': 'Beta Corp',
        'Section': '206C',
        'AmountPaid': 100000,
        'TaxCollected': 1000,
        'TaxDeposited': 1000,
        'DepositDate': '2024-07-01',
        'BookingStatus': 'F',
      },
    ],
    'PartC': [
      {
        'ChallanType': 'ADVANCE',
        'BSRCode': '0001234',
        'ChallanSerial': '00001',
        'DepositDate': '2024-06-15',
        'Amount': 50000,
      },
      {
        'ChallanType': 'SELF_ASSESSMENT',
        'BSRCode': '0005678',
        'ChallanSerial': '00002',
        'DepositDate': '2025-07-31',
        'Amount': 10000,
      },
    ],
    'PartD': [
      {
        'AssessmentYear': '2024-25',
        'Amount': 5000,
        'Mode': 'ECS',
        'PaymentDate': '2024-11-20',
      },
    ],
    'PartE': [
      {
        'ReportingEntity': 'SBI',
        'ReportingEntityPAN': 'SBINX1234A',
        'Category': 'CASH DEPOSIT',
        'Amount': 200000,
        'TransactionDate': '2024-08-10',
        'Description': 'Cash deposit SBI',
      },
    ],
  },
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Form26AsParserService', () {
    const parser = Form26AsParserService.instance;

    // ── instance ─────────────────────────────────────────────────────────────

    test('instance is a singleton', () {
      expect(
        identical(
          Form26AsParserService.instance,
          Form26AsParserService.instance,
        ),
        isTrue,
      );
    });

    // ── validate ─────────────────────────────────────────────────────────────

    group('validate', () {
      test('returns empty errors for valid payload', () {
        final errors = parser.validate(_validPayload);
        expect(errors, isEmpty);
      });

      test('returns error for empty payload', () {
        final errors = parser.validate({});
        expect(errors, isNotEmpty);
      });

      test('returns error for missing PAN', () {
        final payload = <String, Object?>{
          'Form26AS': {'AssessmentYear': '2025-26'},
        };
        final errors = parser.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('PAN')), isTrue);
      });

      test('returns error for PAN with wrong length', () {
        final payload = <String, Object?>{
          'Form26AS': {'PAN': 'ABCDE', 'AssessmentYear': '2025-26'},
        };
        final errors = parser.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('PAN')), isTrue);
      });

      test('returns error for missing AssessmentYear', () {
        final payload = <String, Object?>{
          'Form26AS': {'PAN': 'ABCDE1234F'},
        };
        final errors = parser.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('AssessmentYear')), isTrue);
      });

      test('returns error for AssessmentYear with wrong format', () {
        final payload = <String, Object?>{
          'Form26AS': {'PAN': 'ABCDE1234F', 'AssessmentYear': '2025'},
        };
        final errors = parser.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('AssessmentYear')), isTrue);
      });

      test('returns error when PartA is not a list', () {
        final payload = <String, Object?>{
          'Form26AS': {
            'PAN': 'ABCDE1234F',
            'AssessmentYear': '2025-26',
            'PartA': 'not-a-list',
          },
        };
        final errors = parser.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('PartA')), isTrue);
      });

      test('returns no errors when Part arrays are absent (optional)', () {
        final payload = <String, Object?>{
          'Form26AS': {'PAN': 'ABCDE1234F', 'AssessmentYear': '2025-26'},
        };
        final errors = parser.validate(payload);
        expect(errors, isEmpty);
      });
    });

    // ── parse — top-level fields ──────────────────────────────────────────────

    group('parse — top-level fields', () {
      late Form26AsParserData result;

      setUp(() {
        result = parser.parse(_validPayload);
      });

      test('parses PAN correctly', () {
        expect(result.pan, 'ABCDE1234F');
      });

      test('parses AssessmentYear correctly', () {
        expect(result.assessmentYear, '2025-26');
      });
    });

    // ── parse — Part A (TDS) ──────────────────────────────────────────────────

    group('parse — Part A TDS entries', () {
      late Form26AsParserData result;

      setUp(() {
        result = parser.parse(_validPayload);
      });

      test('parses one TDS entry from PartA', () {
        expect(result.tdsEntries, hasLength(1));
      });

      test('TDS entry has correct deductorTan', () {
        expect(result.tdsEntries.first.deductorTan, 'MUMR12345A');
      });

      test('TDS entry has correct deductorName', () {
        expect(result.tdsEntries.first.deductorName, 'Acme Ltd');
      });

      test('TDS entry has correct section', () {
        expect(result.tdsEntries.first.section, '192');
      });

      test('TDS entry converts amountPaid to paise (×100)', () {
        // 600000 rupees × 100 = 60000000 paise
        expect(result.tdsEntries.first.amountPaidPaise, 60000000);
      });

      test('TDS entry converts taxDeducted to paise', () {
        expect(result.tdsEntries.first.taxDeductedPaise, 6000000);
      });

      test('TDS entry booking status is booked (F)', () {
        expect(
          result.tdsEntries.first.bookingStatus,
          Form26AsBookingStatus.booked,
        );
      });

      test('TDS entry depositDate is parsed correctly', () {
        expect(result.tdsEntries.first.depositDate, DateTime(2024, 6, 15));
      });

      test('totalTdsPaise is sum of all TDS entries', () {
        expect(result.totalTdsPaise, 6000000);
      });
    });

    // ── parse — Part B (TCS) ──────────────────────────────────────────────────

    group('parse — Part B TCS entries', () {
      late Form26AsParserData result;

      setUp(() {
        result = parser.parse(_validPayload);
      });

      test('parses one TCS entry from PartB', () {
        expect(result.tcsEntries, hasLength(1));
      });

      test('TCS entry has correct collectorTan', () {
        expect(result.tcsEntries.first.collectorTan, 'DELX99999Z');
      });

      test('TCS entry converts taxCollected to paise', () {
        // 1000 rupees × 100 = 100000 paise
        expect(result.tcsEntries.first.taxCollectedPaise, 100000);
      });

      test('totalTcsPaise is sum of TCS entries', () {
        expect(result.totalTcsPaise, 100000);
      });
    });

    // ── parse — Part C (tax payments) ────────────────────────────────────────

    group('parse — Part C tax payments', () {
      late Form26AsParserData result;

      setUp(() {
        result = parser.parse(_validPayload);
      });

      test('parses advance tax payment', () {
        expect(result.advanceTaxPayments, hasLength(1));
        expect(result.advanceTaxPayments.first.challanType, 'ADVANCE');
      });

      test('parses self-assessment tax payment', () {
        expect(result.selfAssessmentPayments, hasLength(1));
        expect(
          result.selfAssessmentPayments.first.challanType,
          'SELF_ASSESSMENT',
        );
      });

      test('advance tax amount is converted to paise', () {
        // 50000 × 100 = 5000000 paise
        expect(result.advanceTaxPayments.first.amountPaise, 5000000);
      });

      test('totalAdvanceTaxPaise sums advance payments', () {
        expect(result.totalAdvanceTaxPaise, 5000000);
      });

      test('totalSelfAssessmentPaise sums self-assessment payments', () {
        expect(result.totalSelfAssessmentPaise, 1000000);
      });
    });

    // ── parse — Part D (refunds) ──────────────────────────────────────────────

    group('parse — Part D refund entries', () {
      test('parses refund entry', () {
        final result = parser.parse(_validPayload);
        expect(result.refundEntries, hasLength(1));
        expect(result.refundEntries.first.assessmentYear, '2024-25');
        expect(result.refundEntries.first.mode, 'ECS');
      });

      test('refund amount is converted to paise', () {
        final result = parser.parse(_validPayload);
        // 5000 × 100 = 500000
        expect(result.refundEntries.first.amountPaise, 500000);
      });

      test('totalRefundPaise sums all refund entries', () {
        final result = parser.parse(_validPayload);
        expect(result.totalRefundPaise, 500000);
      });
    });

    // ── parse — Part E (SFT) ─────────────────────────────────────────────────

    group('parse — Part E SFT entries', () {
      test('parses SFT entry', () {
        final result = parser.parse(_validPayload);
        expect(result.sftEntries, hasLength(1));
        expect(result.sftEntries.first.reportingEntity, 'SBI');
        expect(result.sftEntries.first.category, SftCategory.cashDeposit);
      });

      test('SFT amount converted to paise', () {
        final result = parser.parse(_validPayload);
        // 200000 × 100 = 20000000
        expect(result.sftEntries.first.amountPaise, 20000000);
      });
    });

    // ── parse — empty payload ─────────────────────────────────────────────────

    group('parse — empty or minimal payloads', () {
      test('returns empty entry lists for empty payload', () {
        final result = parser.parse({});
        expect(result.tdsEntries, isEmpty);
        expect(result.tcsEntries, isEmpty);
        expect(result.advanceTaxPayments, isEmpty);
        expect(result.selfAssessmentPayments, isEmpty);
        expect(result.refundEntries, isEmpty);
        expect(result.sftEntries, isEmpty);
      });

      test('parses without Form26AS wrapper', () {
        final directPayload = <String, Object?>{
          'PAN': 'ZZZZZ9999Z',
          'AssessmentYear': '2024-25',
        };
        final result = parser.parse(directPayload);
        expect(result.pan, 'ZZZZZ9999Z');
      });

      test('handles missing DepositDate gracefully (null)', () {
        final payload = <String, Object?>{
          'Form26AS': {
            'PAN': 'ABCDE1234F',
            'AssessmentYear': '2025-26',
            'PartA': [
              {
                'TAN': 'MUMR12345A',
                'DeductorName': 'Acme Ltd',
                'Section': '192',
                'AmountPaid': 100000,
                'TaxDeducted': 10000,
                'TaxDeposited': 10000,
                'BookingStatus': 'F',
              },
            ],
          },
        };
        final result = parser.parse(payload);
        expect(result.tdsEntries.first.depositDate, isNull);
      });

      test('handles amount as double', () {
        final payload = <String, Object?>{
          'Form26AS': {
            'PAN': 'ABCDE1234F',
            'AssessmentYear': '2025-26',
            'PartA': [
              {
                'TAN': 'MUMR12345A',
                'DeductorName': 'Test',
                'Section': '192',
                'AmountPaid': 50000.50,
                'TaxDeducted': 5000.5,
                'TaxDeposited': 5000.5,
                'BookingStatus': 'F',
              },
            ],
          },
        };
        final result = parser.parse(payload);
        // 50000.50 × 100 rounded = 5000050
        expect(result.tdsEntries.first.amountPaidPaise, 5000050);
      });
    });

    // ── booking status mapping ────────────────────────────────────────────────

    group('booking status mapping', () {
      test('"U" maps to unmatched', () {
        expect(
          Form26AsBookingStatus.fromCode('U'),
          Form26AsBookingStatus.unmatched,
        );
      });

      test('"O" maps to overBooked', () {
        expect(
          Form26AsBookingStatus.fromCode('O'),
          Form26AsBookingStatus.overBooked,
        );
      });

      test('unknown code maps to unmatched', () {
        expect(
          Form26AsBookingStatus.fromCode('X'),
          Form26AsBookingStatus.unmatched,
        );
      });
    });

    // ── SFT category mapping ──────────────────────────────────────────────────

    group('SftCategory mapping', () {
      test('"CASH DEPOSIT" maps to cashDeposit', () {
        expect(SftCategory.fromString('CASH DEPOSIT'), SftCategory.cashDeposit);
      });

      test('"FIXED DEPOSIT" maps to fixedDeposit', () {
        expect(
          SftCategory.fromString('FIXED DEPOSIT'),
          SftCategory.fixedDeposit,
        );
      });

      test('"PROPERTY PURCHASE" maps to propertyPurchase', () {
        expect(
          SftCategory.fromString('PROPERTY PURCHASE'),
          SftCategory.propertyPurchase,
        );
      });

      test('unknown category maps to other', () {
        expect(SftCategory.fromString('UNKNOWN'), SftCategory.other);
      });
    });
  });
}
