import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/ai/ocr/document_classifier.dart';

void main() {
  group('DocumentClassifier', () {
    late DocumentClassifier classifier;

    setUp(() {
      classifier = const DocumentClassifier();
    });

    group('classify — Form 16', () {
      test(
        'text with "Form 16" and supporting keywords classifies as form16',
        () {
          // minScore=2 requires at least 2 keyword matches.
          // 'form 16' + 'income from salaries' = 2 matches → form16.
          const text =
              'Form 16 issued by employer. Income from salaries for FY 2023-24.';
          expect(classifier.classify(text), equals(DocumentType.form16));
        },
      );

      test('text with "TDS Certificate" classifies as form16', () {
        const text =
            'TDS Certificate issued under section 203 of the Income Tax Act. '
            'Salary income declared. Employer TAN details included.';
        expect(classifier.classify(text), equals(DocumentType.form16));
      });

      test('text with "certificate of tax deducted" classifies as form16', () {
        const text =
            'Certificate of tax deducted from salaries. Income from salaries '
            'as computed by the employer.';
        expect(classifier.classify(text), equals(DocumentType.form16));
      });
    });

    group('classify — Form 26AS', () {
      test('text with "26AS" classifies as form26as', () {
        const text =
            'Form 26AS Annual Information Statement. Tax Credit Statement. '
            'Assessment Year 2024-25. TDS/TCS credit details.';
        expect(classifier.classify(text), equals(DocumentType.form26as));
      });

      test(
        'text with "Annual Information Statement" classifies as form26as',
        () {
          const text =
              'Annual Information Statement from TRACES. '
              'Part A – details of tax deducted at source.';
          expect(classifier.classify(text), equals(DocumentType.form26as));
        },
      );
    });

    group('classify — GST Invoice', () {
      test('text with "GSTIN" and "Tax Invoice" classifies as gstInvoice', () {
        const text =
            'Tax Invoice. GSTIN: 29ABCDE1234F1Z5. Place of supply: Karnataka. '
            'CGST: 9%, SGST: 9%. HSN code: 9954.';
        expect(classifier.classify(text), equals(DocumentType.gstInvoice));
      });

      test('text with "IGST" classifies as gstInvoice', () {
        const text =
            'GST Invoice. GSTIN: 07AABCU9603R1ZM. Goods and Services Tax. '
            'IGST @ 18%. SAC code 998311.';
        expect(classifier.classify(text), equals(DocumentType.gstInvoice));
      });
    });

    group('classify — Salary Slip', () {
      test('text with "salary slip" classifies as salarySlip', () {
        const text =
            'Salary Slip for the month of April 2024. Employee ID: EMP001. '
            'Basic Salary: 40000. HRA: 16000. Gross Salary: 56000. '
            'PF: 4800. Professional Tax: 200. Net Salary: 51000.';
        expect(classifier.classify(text), equals(DocumentType.salarySlip));
      });

      test('text with "payslip" classifies as salarySlip', () {
        const text =
            'Payslip. Basic salary: 35000. Net salary: 30000. '
            'House rent allowance included.';
        expect(classifier.classify(text), equals(DocumentType.salarySlip));
      });
    });

    group('classify — unknown', () {
      test('empty text classifies as unknown', () {
        expect(classifier.classify(''), equals(DocumentType.unknown));
      });

      test('whitespace-only text classifies as unknown', () {
        expect(classifier.classify('   '), equals(DocumentType.unknown));
      });

      test('unrelated text classifies as unknown', () {
        const text = 'Dear customer, your package has been shipped.';
        expect(classifier.classify(text), equals(DocumentType.unknown));
      });

      test('single keyword below minScore classifies as unknown', () {
        // minScore = 2 by default; one keyword hit is not enough.
        // 'balance sheet' is one entry → score=1. With minScore=2 → unknown.
        // But there may be other matches; let's use truly isolated text.
        const isolated = 'The word balance appears once here.';
        expect(classifier.classify(isolated), equals(DocumentType.unknown));
      });
    });

    group('classify — case insensitivity', () {
      test('uppercase keywords are correctly matched', () {
        const text =
            'FORM 16 ISSUED BY EMPLOYER. TDS CERTIFICATE. '
            'INCOME FROM SALARIES. EMPLOYER TAN.';
        expect(classifier.classify(text), equals(DocumentType.form16));
      });

      test('mixed case keywords are correctly matched', () {
        const text =
            'Form No. 16 — Certificate of Tax Deducted. Part A and Part B.';
        expect(classifier.classify(text), equals(DocumentType.form16));
      });
    });

    group('extractPrimaryId — PAN extraction', () {
      test('extracts PAN from form16 text', () {
        const text =
            'Form 16 for ABCDE1234F. Employer TAN: MUMJ12345A. '
            'Income from salaries.';
        final pan = classifier.extractPrimaryId(text, DocumentType.form16);

        expect(pan, equals('ABCDE1234F'));
      });

      test('extracts PAN from form26as text', () {
        const text = 'Form 26AS for PAN PQRST5678G. Assessment Year 2024-25.';
        final pan = classifier.extractPrimaryId(text, DocumentType.form26as);

        expect(pan, equals('PQRST5678G'));
      });

      test('returns null when PAN not present in form16 text', () {
        const text = 'Form 16 issued by employer. Income from salaries.';
        final pan = classifier.extractPrimaryId(text, DocumentType.form16);

        expect(pan, isNull);
      });
    });

    group('extractPrimaryId — GSTIN extraction', () {
      test('extracts GSTIN from gstInvoice text', () {
        const text =
            'Tax Invoice. GSTIN 29ABCDE1234F1Z5. Place of supply: Karnataka.';
        final gstin = classifier.extractPrimaryId(
          text,
          DocumentType.gstInvoice,
        );

        expect(gstin, equals('29ABCDE1234F1Z5'));
      });
    });

    group('extractPrimaryId — bank account extraction', () {
      test('extracts account number from bankStatement text', () {
        const text =
            'Account Statement. Account Number: 12345678901234. IFSC: HDFC0001234.';
        final acct = classifier.extractPrimaryId(
          text,
          DocumentType.bankStatement,
        );

        expect(acct, isNotNull);
        expect(acct!.length, greaterThanOrEqualTo(8));
      });
    });

    group('extractPrimaryId — empty text', () {
      test('returns null for empty text', () {
        final id = classifier.extractPrimaryId('', DocumentType.form16);
        expect(id, isNull);
      });

      test('returns null for whitespace text', () {
        final id = classifier.extractPrimaryId('   ', DocumentType.panCard);
        expect(id, isNull);
      });
    });

    group('extractAllIds', () {
      test('extracts PAN, GSTIN, and TAN from mixed text', () {
        const text = 'PAN: ABCDE1234F GSTIN: 29ABCDE1234F1Z5 TAN: MUMJ12345A.';
        final ids = classifier.extractAllIds(text);

        expect(ids['pan'], equals('ABCDE1234F'));
        expect(ids['gstin'], equals('29ABCDE1234F1Z5'));
        expect(ids['tan'], equals('MUMJ12345A'));
      });

      test('returns empty map for text with no recognisable IDs', () {
        const text = 'No identifiers here.';
        final ids = classifier.extractAllIds(text);
        expect(ids, isEmpty);
      });

      test('result map is unmodifiable', () {
        const text = 'PAN: ABCDE1234F';
        final ids = classifier.extractAllIds(text);

        expect(() {
          // ignore: unnecessary_cast
          (ids as Map<String, String>)['newKey'] = 'value';
        }, throwsA(anything));
      });
    });

    group('DocumentClassifier — custom minScore', () {
      test('minScore of 1 classifies with single keyword match', () {
        const lenientClassifier = DocumentClassifier(minScore: 1);
        const text = 'The balance sheet shows assets.';
        // 'balance sheet' + 'assets' = 2 matches → should classify as balanceSheet
        expect(
          lenientClassifier.classify(text),
          equals(DocumentType.balanceSheet),
        );
      });
    });
  });
}
