import 'dart:convert';

import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';
import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';
import 'package:ca_app/features/portal_export/gst_export/services/gstr3b_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _validGstin = '27AABCE1234F1Z5';

Gstr3bTaxRow _zeroRow() =>
    const Gstr3bTaxRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

ItcRow _zeroItcRow() => const ItcRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

Gstr3bFormData _buildMinimalValidData({
  String gstin = _validGstin,
  int month = 3,
  int year = 2024,
}) {
  return Gstr3bFormData(
    gstin: gstin,
    periodMonth: month,
    periodYear: year,
    taxLiability: Gstr3bTaxLiability(
      outwardTaxable: const Gstr3bTaxRow(
        igst: 18000,
        cgst: 9000,
        sgst: 9000,
        cess: 0,
      ),
      outwardZeroRated: _zeroRow(),
      otherOutward: _zeroRow(),
      inwardRcm: _zeroRow(),
      nonGstOutward: _zeroRow(),
    ),
    itcClaimed: Gstr3bItcClaimed(
      importGoods: _zeroItcRow(),
      importServices: _zeroItcRow(),
      inwardRcm: _zeroItcRow(),
      isd: _zeroItcRow(),
      otherItc: const ItcRow(igst: 5000, cgst: 2500, sgst: 2500, cess: 0),
      reversedSection17_5: _zeroItcRow(),
      reversedOthers: _zeroItcRow(),
      netItcAvailable: const ItcRow(
        igst: 5000,
        cgst: 2500,
        sgst: 2500,
        cess: 0,
      ),
      ineligibleRule38: _zeroItcRow(),
      ineligibleOthers: _zeroItcRow(),
    ),
    exemptSupplies: const Gstr3bExemptSupplies(
      interStateExempt: 0,
      intraStateExempt: 0,
      interStateNilRated: 0,
      intraStateNilRated: 0,
      interStateNonGst: 0,
      intraStateNonGst: 0,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Gstr3bExportService', () {
    // ── Feature flag ─────────────────────────────────────────────────────────

    group('featureFlag', () {
      test('has non-empty static featureFlag constant', () {
        expect(Gstr3bExportService.featureFlag, isNotEmpty);
        expect(Gstr3bExportService.featureFlag, 'gstr3b_export_enabled');
      });
    });

    // ── validate ─────────────────────────────────────────────────────────────

    group('validate', () {
      test('returns empty errors for valid data', () {
        final data = _buildMinimalValidData();
        final errors = Gstr3bExportService.validate(data);
        expect(errors, isEmpty);
      });

      test('returns error for invalid GSTIN', () {
        final data = _buildMinimalValidData(gstin: 'INVALID');
        final errors = Gstr3bExportService.validate(data);
        expect(errors, isNotEmpty);
        expect(errors.first, contains('Invalid GSTIN'));
      });

      test('returns error for invalid period month (0)', () {
        final data = _buildMinimalValidData(month: 0);
        final errors = Gstr3bExportService.validate(data);
        expect(errors, isNotEmpty);
        expect(errors.first, contains('Invalid period month'));
      });

      test('returns error for invalid period month (13)', () {
        final data = _buildMinimalValidData(month: 13);
        final errors = Gstr3bExportService.validate(data);
        expect(errors, isNotEmpty);
        expect(errors.first, contains('Invalid period month'));
      });

      test('returns error for year before GST era (2016)', () {
        final data = _buildMinimalValidData(year: 2016);
        final errors = Gstr3bExportService.validate(data);
        expect(errors, isNotEmpty);
        expect(errors.first, contains('2017'));
      });

      test('accepts boundary month values 1 and 12', () {
        expect(
          Gstr3bExportService.validate(_buildMinimalValidData(month: 1)),
          isEmpty,
        );
        expect(
          Gstr3bExportService.validate(_buildMinimalValidData(month: 12)),
          isEmpty,
        );
      });

      test('accepts boundary year 2017 (GST introduction)', () {
        final data = _buildMinimalValidData(year: 2017);
        expect(Gstr3bExportService.validate(data), isEmpty);
      });
    });

    // ── export — valid data ───────────────────────────────────────────────────

    group('export — valid data', () {
      late Gstr3bFormData validData;
      late GstrExportResult result;

      setUp(() {
        validData = _buildMinimalValidData();
        result = Gstr3bExportService.export(validData);
      });

      test('returns GstrExportResult with returnType gstr3b', () {
        expect(result.returnType, GstrReturnType.gstr3b);
      });

      test('result has correct GSTIN', () {
        expect(result.gstin, _validGstin);
      });

      test('result period is in MMYYYY format', () {
        expect(result.period, '032024');
        expect(RegExp(r'^\d{6}$').hasMatch(result.period), isTrue);
      });

      test('result has non-empty JSON payload', () {
        expect(result.jsonPayload, isNotEmpty);
      });

      test('JSON payload is valid JSON', () {
        expect(() => jsonDecode(result.jsonPayload), returnsNormally);
      });

      test('result has no validation errors', () {
        expect(result.validationErrors, isEmpty);
        expect(result.isValid, isTrue);
      });

      test('result exportedAt is recent', () {
        final before = DateTime.now().subtract(const Duration(seconds: 5));
        expect(result.exportedAt.isAfter(before), isTrue);
      });

      test('JSON payload contains gstin field', () {
        final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
        expect(decoded.containsKey('gstin'), isTrue);
        expect(decoded['gstin'], _validGstin);
      });

      test('JSON payload contains ret_period field', () {
        final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
        expect(decoded.containsKey('ret_period'), isTrue);
        expect(decoded['ret_period'], '032024');
      });

      test('JSON payload contains sup_details (Table 3.1) section', () {
        final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
        expect(decoded.containsKey('sup_details'), isTrue);
      });

      test('JSON payload contains itc_elg (Table 4) section', () {
        final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
        expect(decoded.containsKey('itc_elg'), isTrue);
      });

      test('JSON payload contains intr_ltfee section', () {
        final decoded = jsonDecode(result.jsonPayload) as Map<String, dynamic>;
        expect(decoded.containsKey('intr_ltfee'), isTrue);
      });
    });

    // ── export — period padding ───────────────────────────────────────────────

    group('export — period formatting', () {
      test('single-digit month is padded to 2 digits (01YYYY)', () {
        final data = _buildMinimalValidData(month: 1, year: 2024);
        final result = Gstr3bExportService.export(data);
        expect(result.period, '012024');
      });

      test('double-digit month is not padded (102024)', () {
        final data = _buildMinimalValidData(month: 10, year: 2024);
        final result = Gstr3bExportService.export(data);
        expect(result.period, '102024');
      });
    });

    // ── export — invalid GSTIN ────────────────────────────────────────────────

    group('export — invalid GSTIN', () {
      test('result has validation errors for invalid GSTIN', () {
        final data = _buildMinimalValidData(gstin: 'BADGSTIN');
        final result = Gstr3bExportService.export(data);
        expect(result.validationErrors, isNotEmpty);
        expect(result.isValid, isFalse);
      });

      test('result has validation errors for empty GSTIN', () {
        final data = _buildMinimalValidData(gstin: '');
        final result = Gstr3bExportService.export(data);
        expect(result.isValid, isFalse);
      });
    });

    // ── export — invalid period ───────────────────────────────────────────────

    group('export — invalid period', () {
      test('result has validation errors for month = 0', () {
        final data = _buildMinimalValidData(month: 0);
        final result = Gstr3bExportService.export(data);
        expect(result.validationErrors, isNotEmpty);
        expect(result.isValid, isFalse);
      });

      test('result has validation errors for pre-GST year', () {
        final data = _buildMinimalValidData(year: 2015);
        final result = Gstr3bExportService.export(data);
        expect(result.isValid, isFalse);
      });
    });

    // ── tax computations ─────────────────────────────────────────────────────

    group('tax computations', () {
      test('periodLabel reflects month and year', () {
        final data = _buildMinimalValidData(month: 3, year: 2024);
        expect(data.periodLabel, 'Mar 2024');
      });

      test('netTaxPayable is non-negative for liability exceeding ITC', () {
        final data = _buildMinimalValidData();
        // outward liability total = 18000+9000+9000 = 36000
        // net ITC = 5000+2500+2500 = 10000
        expect(data.netTaxPayable, greaterThanOrEqualTo(0));
      });
    });
  });
}
