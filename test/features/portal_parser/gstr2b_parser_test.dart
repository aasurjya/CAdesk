import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_parser/models/gstr2b_data.dart';
import 'package:ca_app/features/portal_parser/services/gstr2b_parser.dart';
import 'package:ca_app/features/gst/domain/models/gstr2b_entry.dart';

void main() {
  group('Gstr2bParser', () {
    late Gstr2bParser parser;

    setUp(() {
      parser = Gstr2bParser.instance;
    });

    // --------------- parseJson ---------------

    group('parseJson', () {
      const sampleGstr2bJson = '''
{
  "data": {
    "gstin": "27AABCU9603R1ZX",
    "rtnprd": "012024",
    "docdata": {
      "b2b": [
        {
          "ctin": "29AADCS0472N1Z1",
          "trdnm": "Supplier Co Pvt Ltd",
          "inv": [
            {
              "inum": "INV-001",
              "idt": "05-01-2024",
              "val": 118000,
              "taxval": 100000,
              "igst": 18000,
              "cgst": 0,
              "sgst": 0,
              "cess": 0,
              "pos": "27",
              "rchrg": "N",
              "itcavl": "Y"
            }
          ]
        }
      ]
    }
  }
}''';

      test('parses GSTIN correctly', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.gstin, equals('27AABCU9603R1ZX'));
      });

      test('parses return period correctly', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.returnPeriod, equals('012024'));
      });

      test('parses B2B entries', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.b2bEntries, hasLength(1));
      });

      test('parses supplier GSTIN from B2B entry', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.b2bEntries.first.supplierGstin, equals('29AADCS0472N1Z1'));
      });

      test('parses supplier name from B2B entry', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.b2bEntries.first.supplierName, equals('Supplier Co Pvt Ltd'));
      });

      test('parses invoice number', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.b2bEntries.first.invoiceNumber, equals('INV-001'));
      });

      test('parses invoice date correctly', () {
        final result = parser.parseJson(sampleGstr2bJson);
        final date = result.b2bEntries.first.invoiceDate;
        expect(date.day, equals(5));
        expect(date.month, equals(1));
        expect(date.year, equals(2024));
      });

      test('computes totalIgstCredit in paise', () {
        final result = parser.parseJson(sampleGstr2bJson);
        // IGST 18000 rupees → 1800000 paise
        expect(result.totalIgstCredit, equals(1800000));
      });

      test('computes totalCgstCredit as 0 when no CGST entries', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.totalCgstCredit, equals(0));
      });

      test('computes totalSgstCredit as 0 when no SGST entries', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.totalSgstCredit, equals(0));
      });

      test('parses itcAvailable Y as ItcAvailability.yes', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.b2bEntries.first.itcAvailable, equals(ItcAvailability.yes));
      });

      test('parses reverseCharge N as false', () {
        final result = parser.parseJson(sampleGstr2bJson);
        expect(result.b2bEntries.first.reverseCharge, isFalse);
      });

      test('parses multiple invoices under same supplier', () {
        const json = '''
{
  "data": {
    "gstin": "27AABCU9603R1ZX",
    "rtnprd": "022024",
    "docdata": {
      "b2b": [
        {
          "ctin": "29AADCS0472N1Z1",
          "trdnm": "Supplier Co",
          "inv": [
            {
              "inum": "INV-001",
              "idt": "01-02-2024",
              "val": 59000,
              "taxval": 50000,
              "igst": 9000,
              "cgst": 0,
              "sgst": 0,
              "cess": 0,
              "pos": "27",
              "rchrg": "N",
              "itcavl": "Y"
            },
            {
              "inum": "INV-002",
              "idt": "15-02-2024",
              "val": 11800,
              "taxval": 10000,
              "igst": 1800,
              "cgst": 0,
              "sgst": 0,
              "cess": 0,
              "pos": "27",
              "rchrg": "N",
              "itcavl": "Y"
            }
          ]
        }
      ]
    }
  }
}''';
        final result = parser.parseJson(json);
        expect(result.b2bEntries, hasLength(2));
        expect(result.totalIgstCredit, equals(1080000)); // 10800 * 100
      });

      test('handles empty B2B array', () {
        const json = '''
{
  "data": {
    "gstin": "27AABCU9603R1ZX",
    "rtnprd": "032024",
    "docdata": {
      "b2b": []
    }
  }
}''';
        final result = parser.parseJson(json);
        expect(result.b2bEntries, isEmpty);
        expect(result.totalIgstCredit, equals(0));
      });

      test('parses CGST and SGST correctly for intra-state supplies', () {
        const json = '''
{
  "data": {
    "gstin": "27AABCU9603R1ZX",
    "rtnprd": "012024",
    "docdata": {
      "b2b": [
        {
          "ctin": "27AADCS0472N1Z1",
          "trdnm": "Local Supplier",
          "inv": [
            {
              "inum": "INV-L01",
              "idt": "10-01-2024",
              "val": 118000,
              "taxval": 100000,
              "igst": 0,
              "cgst": 9000,
              "sgst": 9000,
              "cess": 0,
              "pos": "27",
              "rchrg": "N",
              "itcavl": "Y"
            }
          ]
        }
      ]
    }
  }
}''';
        final result = parser.parseJson(json);
        expect(result.totalCgstCredit, equals(900000));
        expect(result.totalSgstCredit, equals(900000));
        expect(result.totalIgstCredit, equals(0));
      });

      test('parses itcAvailable N as ItcAvailability.no', () {
        const json = '''
{
  "data": {
    "gstin": "27AABCU9603R1ZX",
    "rtnprd": "012024",
    "docdata": {
      "b2b": [
        {
          "ctin": "29AADCS0472N1Z1",
          "trdnm": "Restricted Supplier",
          "inv": [
            {
              "inum": "INV-R01",
              "idt": "20-01-2024",
              "val": 11800,
              "taxval": 10000,
              "igst": 1800,
              "cgst": 0,
              "sgst": 0,
              "cess": 0,
              "pos": "27",
              "rchrg": "N",
              "itcavl": "N"
            }
          ]
        }
      ]
    }
  }
}''';
        final result = parser.parseJson(json);
        expect(result.b2bEntries.first.itcAvailable, equals(ItcAvailability.no));
      });

      test('parses reverseCharge Y as true', () {
        const json = '''
{
  "data": {
    "gstin": "27AABCU9603R1ZX",
    "rtnprd": "012024",
    "docdata": {
      "b2b": [
        {
          "ctin": "29AADCS0472N1Z1",
          "trdnm": "RCM Supplier",
          "inv": [
            {
              "inum": "INV-RCM",
              "idt": "25-01-2024",
              "val": 11800,
              "taxval": 10000,
              "igst": 1800,
              "cgst": 0,
              "sgst": 0,
              "cess": 0,
              "pos": "27",
              "rchrg": "Y",
              "itcavl": "Y"
            }
          ]
        }
      ]
    }
  }
}''';
        final result = parser.parseJson(json);
        expect(result.b2bEntries.first.reverseCharge, isTrue);
      });
    });

    // --------------- Model equality / immutability ---------------

    group('Gstr2bData model', () {
      test('two identical instances are equal', () {
        final entry = Gstr2bEntry(
          supplierGstin: '29AADCS0472N1Z1',
          supplierName: 'Test Supplier',
          invoiceNumber: 'INV-001',
          invoiceDate: DateTime(2024, 1, 5),
          invoiceValue: 118000,
          taxableValue: 100000,
          igst: 18000,
          cgst: 0,
          sgst: 0,
          cess: 0,
          placeOfSupply: '27',
          reverseCharge: false,
          itcAvailable: ItcAvailability.yes,
        );
        final a = Gstr2bData(
          gstin: '27AABCU9603R1ZX',
          returnPeriod: '012024',
          b2bEntries: [entry],
          totalIgstCredit: 1800000,
          totalCgstCredit: 0,
          totalSgstCredit: 0,
        );
        final b = Gstr2bData(
          gstin: '27AABCU9603R1ZX',
          returnPeriod: '012024',
          b2bEntries: [entry],
          totalIgstCredit: 1800000,
          totalCgstCredit: 0,
          totalSgstCredit: 0,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('copyWith creates new instance with updated field', () {
        const original = Gstr2bData(
          gstin: '27AABCU9603R1ZX',
          returnPeriod: '012024',
          b2bEntries: [],
          totalIgstCredit: 0,
          totalCgstCredit: 0,
          totalSgstCredit: 0,
        );
        final updated = original.copyWith(returnPeriod: '022024');
        expect(updated.returnPeriod, equals('022024'));
        expect(original.returnPeriod, equals('012024'));
      });
    });
  });
}
