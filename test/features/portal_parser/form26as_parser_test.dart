import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_parser/models/form26as_data.dart';
import 'package:ca_app/features/portal_parser/models/tds_entry_26as.dart';
import 'package:ca_app/features/portal_parser/services/form26as_parser.dart';

void main() {
  group('Form26AsParser', () {
    late Form26AsParser parser;

    setUp(() {
      parser = Form26AsParser.instance;
    });

    // --------------- parseXml ---------------

    group('parseXml', () {
      const sampleXml = '''
<Form26AS>
  <AssessmentYear>2024-25</AssessmentYear>
  <PAN>ABCDE1234F</PAN>
  <TDSDetails>
    <DeductorDetails>
      <TAN>AAATA1234X</TAN>
      <DeductorName>ABC Company Ltd</DeductorName>
      <Section>192</Section>
      <PaidCredit>500000</PaidCredit>
      <TaxDeducted>50000</TaxDeducted>
      <DateOfDeduction>31-03-2024</DateOfDeduction>
      <BookingStatus>F</BookingStatus>
    </DeductorDetails>
  </TDSDetails>
</Form26AS>''';

      test('returns Form26AsData with correct PAN and assessment year', () {
        final result = parser.parseXml(sampleXml);
        expect(result.pan, equals('ABCDE1234F'));
        expect(result.assessmentYear, equals('2024-25'));
      });

      test('parses TDS entry with correct deductor TAN', () {
        final result = parser.parseXml(sampleXml);
        expect(result.tdsEntries, hasLength(1));
        expect(result.tdsEntries.first.deductorTan, equals('AAATA1234X'));
      });

      test('parses TDS entry deductor name', () {
        final result = parser.parseXml(sampleXml);
        expect(result.tdsEntries.first.deductorName, equals('ABC Company Ltd'));
      });

      test('parses TDS entry section', () {
        final result = parser.parseXml(sampleXml);
        expect(result.tdsEntries.first.section, equals('192'));
      });

      test('converts amount to paise (multiply by 100)', () {
        final result = parser.parseXml(sampleXml);
        expect(result.tdsEntries.first.amount, equals(50000000));
      });

      test('converts tdsDeducted to paise', () {
        final result = parser.parseXml(sampleXml);
        expect(result.tdsEntries.first.tdsDeducted, equals(5000000));
      });

      test('parses booking status F as booked', () {
        final result = parser.parseXml(sampleXml);
        expect(result.tdsEntries.first.status, equals(BookingStatus.booked));
      });

      test('parses booking status U as unmatched', () {
        const xmlU = '''
<Form26AS>
  <AssessmentYear>2024-25</AssessmentYear>
  <PAN>ABCDE1234F</PAN>
  <TDSDetails>
    <DeductorDetails>
      <TAN>AAATA1234X</TAN>
      <DeductorName>ABC Ltd</DeductorName>
      <Section>194C</Section>
      <PaidCredit>100000</PaidCredit>
      <TaxDeducted>10000</TaxDeducted>
      <DateOfDeduction>15-06-2023</DateOfDeduction>
      <BookingStatus>U</BookingStatus>
    </DeductorDetails>
  </TDSDetails>
</Form26AS>''';
        final result = parser.parseXml(xmlU);
        expect(result.tdsEntries.first.status, equals(BookingStatus.unmatched));
      });

      test('parses booking status O as overBooked', () {
        const xmlO = '''
<Form26AS>
  <AssessmentYear>2024-25</AssessmentYear>
  <PAN>ABCDE1234F</PAN>
  <TDSDetails>
    <DeductorDetails>
      <TAN>AAATA1234X</TAN>
      <DeductorName>ABC Ltd</DeductorName>
      <Section>194I</Section>
      <PaidCredit>200000</PaidCredit>
      <TaxDeducted>20000</TaxDeducted>
      <DateOfDeduction>01-01-2024</DateOfDeduction>
      <BookingStatus>O</BookingStatus>
    </DeductorDetails>
  </TDSDetails>
</Form26AS>''';
        final result = parser.parseXml(xmlO);
        expect(result.tdsEntries.first.status, equals(BookingStatus.overBooked));
      });

      test('parses multiple TDS entries', () {
        const xmlMulti = '''
<Form26AS>
  <AssessmentYear>2024-25</AssessmentYear>
  <PAN>ABCDE1234F</PAN>
  <TDSDetails>
    <DeductorDetails>
      <TAN>AAATA1234X</TAN>
      <DeductorName>ABC Company</DeductorName>
      <Section>192</Section>
      <PaidCredit>500000</PaidCredit>
      <TaxDeducted>50000</TaxDeducted>
      <DateOfDeduction>31-03-2024</DateOfDeduction>
      <BookingStatus>F</BookingStatus>
    </DeductorDetails>
    <DeductorDetails>
      <TAN>BBBTB5678Y</TAN>
      <DeductorName>XYZ Corp</DeductorName>
      <Section>194C</Section>
      <PaidCredit>100000</PaidCredit>
      <TaxDeducted>2000</TaxDeducted>
      <DateOfDeduction>15-09-2023</DateOfDeduction>
      <BookingStatus>F</BookingStatus>
    </DeductorDetails>
  </TDSDetails>
</Form26AS>''';
        final result = parser.parseXml(xmlMulti);
        expect(result.tdsEntries, hasLength(2));
      });

      test('computes totalTdsCredited from all entries', () {
        final result = parser.parseXml(sampleXml);
        // tdsDeducted = 50000 rupees = 5000000 paise
        expect(result.totalTdsCredited, equals(5000000));
      });

      test('returns empty tdsEntries when TDSDetails is absent', () {
        const xmlEmpty = '''
<Form26AS>
  <AssessmentYear>2024-25</AssessmentYear>
  <PAN>ZZZZZ9999Z</PAN>
</Form26AS>''';
        final result = parser.parseXml(xmlEmpty);
        expect(result.tdsEntries, isEmpty);
        expect(result.totalTdsCredited, equals(0));
      });

      test('parses dateOfDeduction correctly', () {
        final result = parser.parseXml(sampleXml);
        final date = result.tdsEntries.first.dateOfDeduction;
        expect(date, isNotNull);
        expect(date!.day, equals(31));
        expect(date.month, equals(3));
        expect(date.year, equals(2024));
      });
    });

    // --------------- parseCsv ---------------

    group('parseCsv', () {
      // CSV format: pan,assessmentYear,tan,deductorName,section,amount,tdsDeducted,dateOfDeduction,status
      const sampleCsv =
          'pan,assessmentYear,tan,deductorName,section,amount,tdsDeducted,dateOfDeduction,status\n'
          'ABCDE1234F,2024-25,AAATA1234X,ABC Company Ltd,192,500000,50000,31-03-2024,F\n';

      test('returns Form26AsData with correct PAN from CSV', () {
        final result = parser.parseCsv(sampleCsv);
        expect(result.pan, equals('ABCDE1234F'));
      });

      test('parses TDS entry from CSV row', () {
        final result = parser.parseCsv(sampleCsv);
        expect(result.tdsEntries, hasLength(1));
        expect(result.tdsEntries.first.deductorTan, equals('AAATA1234X'));
      });

      test('converts CSV amount to paise', () {
        final result = parser.parseCsv(sampleCsv);
        expect(result.tdsEntries.first.amount, equals(50000000));
      });

      test('skips header row in CSV', () {
        final result = parser.parseCsv(sampleCsv);
        // Only 1 data row, not 2
        expect(result.tdsEntries, hasLength(1));
      });

      test('returns empty entries for CSV with only header', () {
        const headerOnly =
            'pan,assessmentYear,tan,deductorName,section,amount,tdsDeducted,dateOfDeduction,status\n';
        final result = parser.parseCsv(headerOnly);
        expect(result.tdsEntries, isEmpty);
      });
    });

    // --------------- Model equality / immutability ---------------

    group('Form26AsData model', () {
      test('two identical instances are equal', () {
        const entry = TdsEntry26As(
          deductorTan: 'AAATA1234X',
          deductorName: 'ABC Co',
          section: '192',
          amount: 50000000,
          tdsDeducted: 5000000,
          dateOfDeduction: null,
          status: BookingStatus.booked,
        );
        const a = Form26AsData(
          pan: 'ABCDE1234F',
          assessmentYear: '2024-25',
          tdsEntries: [entry],
          tcsTcsEntries: [],
          advanceTaxEntries: [],
          selfAssessmentEntries: [],
          refundEntries: [],
          totalTdsCredited: 5000000,
          totalTcsCredited: 0,
        );
        const b = Form26AsData(
          pan: 'ABCDE1234F',
          assessmentYear: '2024-25',
          tdsEntries: [entry],
          tcsTcsEntries: [],
          advanceTaxEntries: [],
          selfAssessmentEntries: [],
          refundEntries: [],
          totalTdsCredited: 5000000,
          totalTcsCredited: 0,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('copyWith creates a new instance with updated field', () {
        const original = Form26AsData(
          pan: 'ABCDE1234F',
          assessmentYear: '2024-25',
          tdsEntries: [],
          tcsTcsEntries: [],
          advanceTaxEntries: [],
          selfAssessmentEntries: [],
          refundEntries: [],
          totalTdsCredited: 0,
          totalTcsCredited: 0,
        );
        final updated = original.copyWith(pan: 'XYZAB5678G');
        expect(updated.pan, equals('XYZAB5678G'));
        expect(original.pan, equals('ABCDE1234F'));
      });
    });
  });
}
