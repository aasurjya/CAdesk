import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:ca_app/features/portal_autosubmit/data/services/excel_import_models.dart';
import 'package:ca_app/features/portal_autosubmit/data/services/excel_import_service.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test helper: builds a minimal .xlsx (zip) in memory from a list of rows.
//
// Each row is a List<String?> matching the columns defined by the header row.
// The first element of [rows] MUST be the header row.
// ---------------------------------------------------------------------------

/// Builds a minimal valid .xlsx (OpenXml) zip archive from [rows].
///
/// The first entry in [rows] is the header row. Subsequent entries are
/// data rows. Values are stored in the shared-string table so the decoder
/// reads them back as strings — matching typical Excel behaviour.
Uint8List buildTestXlsx(List<List<String?>> rows) {
  // Collect all unique strings into a shared-string table.
  final allStrings = <String>[];
  final stringIndex = <String, int>{};

  for (final row in rows) {
    for (final cell in row) {
      if (cell != null && !stringIndex.containsKey(cell)) {
        stringIndex[cell] = allStrings.length;
        allStrings.add(cell);
      }
    }
  }

  // Build xl/sharedStrings.xml
  final ssBuf = StringBuffer()
    ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    ..write(
      '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'count="${allStrings.length}" uniqueCount="${allStrings.length}">',
    );
  for (final s in allStrings) {
    ssBuf.write('<si><t>${_xmlEscape(s)}</t></si>');
  }
  ssBuf.write('</sst>');

  // Build xl/worksheets/sheet1.xml
  final wsBuf = StringBuffer()
    ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    ..write(
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    )
    ..write('<sheetData>');

  for (var r = 0; r < rows.length; r++) {
    wsBuf.write('<row r="${r + 1}">');
    for (var c = 0; c < rows[r].length; c++) {
      final cell = rows[r][c];
      if (cell != null) {
        final colLetter = String.fromCharCode(65 + c); // A-Z (max 26 cols)
        final ref = '$colLetter${r + 1}';
        final idx = stringIndex[cell]!;
        wsBuf.write('<c r="$ref" t="s"><v>$idx</v></c>');
      }
    }
    wsBuf.write('</row>');
  }

  wsBuf.write('</sheetData></worksheet>');

  // Build xl/workbook.xml
  const workbook =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<sheets><sheet name="Sheet1" sheetId="1" r:id="rId1"/></sheets></workbook>';

  // Build xl/_rels/workbook.xml.rels
  const wbRels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
      'Target="worksheets/sheet1.xml"/>'
      '<Relationship Id="rId2" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" '
      'Target="sharedStrings.xml"/>'
      '</Relationships>';

  // Build [Content_Types].xml
  const contentTypes =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Override PartName="/xl/workbook.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/worksheets/sheet1.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
      '<Override PartName="/xl/sharedStrings.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>'
      '</Types>';

  // Build _rels/.rels
  const rootRels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
      'Target="xl/workbook.xml"/>'
      '</Relationships>';

  // Assemble into a zip archive.
  final archive = Archive();
  void addFile(String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  addFile('[Content_Types].xml', contentTypes);
  addFile('_rels/.rels', rootRels);
  addFile('xl/workbook.xml', workbook);
  addFile('xl/_rels/workbook.xml.rels', wbRels);
  addFile('xl/sharedStrings.xml', ssBuf.toString());
  addFile('xl/worksheets/sheet1.xml', wsBuf.toString());

  final encoded = ZipEncoder().encode(archive);
  return Uint8List.fromList(encoded!);
}

String _xmlEscape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const service = ExcelImportService();

  /// Stub encryption: just prefixes with "enc:".
  Future<String> stubEncrypt(String plaintext) async => 'enc:$plaintext';

  group('ExcelImportService', () {
    test('parses valid Excel data correctly', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password', 'Portal'],
        ['ABCDE1234F', 'Ravi Sharma', 'secret123', 'ITD'],
        ['XYZAB9876C', 'Priya Gupta', 'pass456', 'GSTN'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.totalRows, 2);
      expect(result.validRows.length, 2);
      expect(result.errors, isEmpty);

      final first = result.validRows[0];
      expect(first.pan, 'ABCDE1234F');
      expect(first.name, 'Ravi Sharma');
      expect(first.encryptedPassword, 'enc:secret123');
      expect(first.portalType, PortalType.itd);
      expect(first.rowNumber, 2);

      final second = result.validRows[1];
      expect(second.pan, 'XYZAB9876C');
      expect(second.name, 'Priya Gupta');
      expect(second.portalType, PortalType.gstn);
      expect(second.rowNumber, 3);
    });

    test('validates PAN format — valid PANs accepted', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
        ['ABCDE1234F', 'Valid PAN', 'pass1'],
        ['ZZZZZ9999A', 'Another Valid', 'pass2'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows.length, 2);
      expect(result.errors, isEmpty);
    });

    test('validates PAN format — invalid PANs rejected', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
        ['ABC123', 'Bad PAN Short', 'pass1'],
        ['12345ABCDE', 'Bad PAN Digits First', 'pass2'],
        ['ABCDE1234', 'Bad PAN Missing Last', 'pass3'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows.length, 0);
      expect(result.errors.length, 3);

      for (final err in result.errors) {
        expect(err.message, contains('Invalid PAN format'));
      }
    });

    test('rejects rows with missing required fields — PAN', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
        [null, 'No PAN', 'pass1'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows, isEmpty);
      expect(result.errors.length, 1);
      expect(result.errors[0].message, 'PAN is required');
      expect(result.errors[0].rowNumber, 2);
    });

    test('rejects rows with missing required fields — Name', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
        ['ABCDE1234F', null, 'pass1'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows, isEmpty);
      expect(result.errors.length, 1);
      expect(result.errors[0].message, 'Name is required');
    });

    test('rejects rows with missing required fields — Password', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
        ['ABCDE1234F', 'Has Name', null],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows, isEmpty);
      expect(result.errors.length, 1);
      expect(result.errors[0].message, 'Password is required');
    });

    test(
      'rejects rows with multiple missing required fields and reports all',
      () async {
        // Use a row with at least one non-null cell so it is not skipped
        // as a blank row — portal value ensures it's treated as a data row.
        final bytes = buildTestXlsx([
          ['PAN', 'Name', 'Password', 'Portal'],
          [null, null, null, 'ITD'],
        ]);

        final result = await service.parseExcelBytes(
          bytes: bytes,
          encryptPassword: stubEncrypt,
        );

        expect(result.validRows, isEmpty);
        expect(result.errors.length, 3);

        final messages = result.errors.map((e) => e.message).toList();
        expect(messages, contains('PAN is required'));
        expect(messages, contains('Name is required'));
        expect(messages, contains('Password is required'));
      },
    );

    test('maps portal string to PortalType correctly', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password', 'Portal'],
        ['ABCDE1234F', 'Client A', 'p1', 'ITD'],
        ['BCDEF2345G', 'Client B', 'p2', 'GSTN'],
        ['CDEFG3456H', 'Client C', 'p3', 'TRACES'],
        ['DEFGH4567I', 'Client D', 'p4', 'MCA'],
        ['EFGHI5678J', 'Client E', 'p5', 'EPFO'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows.length, 5);
      expect(result.errors, isEmpty);
      expect(result.validRows[0].portalType, PortalType.itd);
      expect(result.validRows[1].portalType, PortalType.gstn);
      expect(result.validRows[2].portalType, PortalType.traces);
      expect(result.validRows[3].portalType, PortalType.mca);
      expect(result.validRows[4].portalType, PortalType.epfo);
    });

    test('defaults portal to ITD when not provided', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password', 'Portal'],
        ['ABCDE1234F', 'Client A', 'p1', null],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows.length, 1);
      expect(result.validRows[0].portalType, PortalType.itd);
    });

    test('rejects invalid portal string', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password', 'Portal'],
        ['ABCDE1234F', 'Client A', 'p1', 'UNKNOWN'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows, isEmpty);
      expect(result.errors.length, 1);
      expect(result.errors[0].message, contains('Invalid portal'));
      expect(result.errors[0].message, contains('UNKNOWN'));
    });

    test('returns errors with correct row numbers', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
        ['ABCDE1234F', 'Valid Row', 'pass1'], // row 2 — valid
        [null, 'Missing PAN', 'pass2'], // row 3 — error
        ['BCDEF2345G', 'Another Valid', 'pass3'], // row 4 — valid
        ['BAD', 'Bad PAN', 'pass4'], // row 5 — error
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows.length, 2);
      expect(result.validRows[0].rowNumber, 2);
      expect(result.validRows[1].rowNumber, 4);

      expect(result.errors.length, 2);
      expect(result.errors[0].rowNumber, 3);
      expect(result.errors[1].rowNumber, 5);
    });

    test('handles empty spreadsheet gracefully', () async {
      // Spreadsheet with only a header and no data rows.
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.totalRows, 0);
      expect(result.validRows, isEmpty);
      expect(result.errors, isEmpty);
    });

    test('handles completely empty sheet (no rows at all)', () async {
      final bytes = buildTestXlsx([]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.totalRows, 0);
      expect(result.validRows, isEmpty);
      expect(result.errors, isEmpty);
    });

    test('password encryption callback is called for each valid row', () async {
      final encryptedPasswords = <String>[];

      Future<String> trackingEncrypt(String plaintext) async {
        encryptedPasswords.add(plaintext);
        return 'encrypted:$plaintext';
      }

      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
        ['ABCDE1234F', 'Client A', 'alpha'],
        [null, 'Bad Row', 'beta'], // invalid — no PAN
        ['BCDEF2345G', 'Client B', 'gamma'],
        ['CDEFG3456H', 'Client C', 'delta'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: trackingEncrypt,
      );

      // Only 3 valid rows should trigger encryption.
      expect(encryptedPasswords, ['alpha', 'gamma', 'delta']);
      expect(result.validRows.length, 3);
      expect(result.validRows[0].encryptedPassword, 'encrypted:alpha');
      expect(result.validRows[1].encryptedPassword, 'encrypted:gamma');
      expect(result.validRows[2].encryptedPassword, 'encrypted:delta');
    });

    test('handles invalid file bytes gracefully', () async {
      final result = await service.parseExcelBytes(
        bytes: Uint8List.fromList([1, 2, 3, 4]),
        encryptPassword: stubEncrypt,
      );

      expect(result.totalRows, 0);
      expect(result.validRows, isEmpty);
      expect(result.errors.length, 1);
      expect(result.errors[0].message, contains('Failed to decode file'));
    });

    test('rejects spreadsheet missing required header columns', () async {
      final bytes = buildTestXlsx([
        ['PAN', 'Portal'], // missing Name and Password
        ['ABCDE1234F', 'ITD'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows, isEmpty);
      expect(result.errors.length, 1);
      expect(result.errors[0].message, contains('required columns'));
    });

    test('parses optional income and deduction fields', () async {
      final bytes = buildTestXlsx([
        [
          'PAN',
          'Name',
          'Password',
          'Salary Income',
          'Interest Income',
          '80C Deductions',
          '80D Deductions',
          'Bank Account',
          'IFSC Code',
        ],
        [
          'ABCDE1234F',
          'Full Row',
          'pass1',
          '500000',
          '25000',
          '150000',
          '50000',
          '1234567890',
          'SBIN0001234',
        ],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows.length, 1);
      final row = result.validRows[0];
      expect(row.salaryIncome, 500000);
      expect(row.interestIncome, 25000);
      expect(row.deductions80C, 150000);
      expect(row.deductions80D, 50000);
      expect(row.bankAccount, '1234567890');
      expect(row.ifscCode, 'SBIN0001234');
    });

    test('handles case-insensitive header matching', () async {
      final bytes = buildTestXlsx([
        ['pan', 'name', 'password', 'portal'],
        ['ABCDE1234F', 'Lower Case Headers', 'pass1', 'ITD'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      expect(result.validRows.length, 1);
      expect(result.validRows[0].pan, 'ABCDE1234F');
    });

    test('PAN is normalized to uppercase', () async {
      // Even if sheet has lowercase PAN, it should be stored uppercase.
      final bytes = buildTestXlsx([
        ['PAN', 'Name', 'Password'],
        ['abcde1234f', 'Lowercase PAN Client', 'pass1'],
      ]);

      final result = await service.parseExcelBytes(
        bytes: bytes,
        encryptPassword: stubEncrypt,
      );

      // lowercase PAN should fail validation (ABCDE1234F pattern requires uppercase)
      // because the regex checks the raw input.
      // The validation in service trims + uppercases before regex check,
      // so it should actually pass.
      expect(result.validRows.length, 1);
      expect(result.validRows[0].pan, 'ABCDE1234F');
    });
  });

  group('ExcelImportResult', () {
    test('hasValidRows returns true when valid rows exist', () {
      const result = ExcelImportResult(
        validRows: [
          ExcelClientRow(
            rowNumber: 2,
            pan: 'ABCDE1234F',
            name: 'Test',
            encryptedPassword: 'enc',
            portalType: PortalType.itd,
          ),
        ],
        errors: [],
        totalRows: 1,
      );
      expect(result.hasValidRows, isTrue);
      expect(result.hasErrors, isFalse);
    });

    test('hasErrors returns true when errors exist', () {
      const result = ExcelImportResult(
        validRows: [],
        errors: [ExcelImportError(rowNumber: 2, message: 'bad')],
        totalRows: 1,
      );
      expect(result.hasValidRows, isFalse);
      expect(result.hasErrors, isTrue);
    });
  });

  group('parsePortalType', () {
    test('maps all valid portal strings', () {
      expect(parsePortalType('ITD'), PortalType.itd);
      expect(parsePortalType('GSTN'), PortalType.gstn);
      expect(parsePortalType('TRACES'), PortalType.traces);
      expect(parsePortalType('MCA'), PortalType.mca);
      expect(parsePortalType('EPFO'), PortalType.epfo);
    });

    test('is case-insensitive', () {
      expect(parsePortalType('itd'), PortalType.itd);
      expect(parsePortalType('Gstn'), PortalType.gstn);
    });

    test('defaults to ITD for null or empty', () {
      expect(parsePortalType(null), PortalType.itd);
      expect(parsePortalType(''), PortalType.itd);
      expect(parsePortalType('  '), PortalType.itd);
    });

    test('returns null for unknown portal', () {
      expect(parsePortalType('UNKNOWN'), isNull);
      expect(parsePortalType('TDS'), isNull);
    });
  });

  group('isValidPan', () {
    test('accepts valid PAN formats', () {
      expect(isValidPan('ABCDE1234F'), isTrue);
      expect(isValidPan('ZZZZZ9999A'), isTrue);
    });

    test('rejects invalid PAN formats', () {
      expect(isValidPan(null), isFalse);
      expect(isValidPan(''), isFalse);
      expect(isValidPan('ABC123'), isFalse);
      expect(isValidPan('12345ABCDE'), isFalse);
      expect(isValidPan('ABCDE1234'), isFalse);
      expect(isValidPan('ABCDE12345'), isFalse);
    });

    test('handles lowercase by normalizing to uppercase', () {
      expect(isValidPan('abcde1234f'), isTrue);
    });
  });

  group('ExcelClientRow', () {
    test('equality works correctly', () {
      const a = ExcelClientRow(
        rowNumber: 2,
        pan: 'ABCDE1234F',
        name: 'Test',
        encryptedPassword: 'enc',
        portalType: PortalType.itd,
      );
      const b = ExcelClientRow(
        rowNumber: 2,
        pan: 'ABCDE1234F',
        name: 'Test',
        encryptedPassword: 'enc',
        portalType: PortalType.itd,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes key fields', () {
      const row = ExcelClientRow(
        rowNumber: 3,
        pan: 'ABCDE1234F',
        name: 'Ravi',
        encryptedPassword: 'enc',
        portalType: PortalType.gstn,
      );
      expect(row.toString(), contains('ABCDE1234F'));
      expect(row.toString(), contains('Ravi'));
      expect(row.toString(), contains('gstn'));
    });
  });

  group('ExcelImportError', () {
    test('equality works correctly', () {
      const a = ExcelImportError(rowNumber: 2, message: 'bad');
      const b = ExcelImportError(rowNumber: 2, message: 'bad');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes row and message', () {
      const err = ExcelImportError(rowNumber: 5, message: 'PAN is required');
      expect(err.toString(), contains('5'));
      expect(err.toString(), contains('PAN is required'));
    });
  });
}
