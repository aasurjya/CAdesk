import 'package:ca_app/features/ocr/domain/models/extracted_bank_statement.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_invoice.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_transaction.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_document.dart';
import 'package:ca_app/features/ocr/domain/services/ocr_pipeline_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = OcrPipelineService.instance;

  // ---------------------------------------------------------------------------
  // detectDocumentType
  // ---------------------------------------------------------------------------
  group('OcrPipelineService.detectDocumentType', () {
    test('detects form16 from "FORM NO. 16" keyword', () {
      const text = 'FORM NO. 16\nCertificate under section 203';
      expect(service.detectDocumentType(text), DocumentType.form16);
    });

    test('detects form26as from "Form 26AS" keyword', () {
      const text = 'Form 26AS - Tax Credit Statement';
      expect(service.detectDocumentType(text), DocumentType.form26as);
    });

    test('detects bankStatement from "Statement of Account" keyword', () {
      const text = 'Statement of Account\nAccount Number: XXXX1234';
      expect(service.detectDocumentType(text), DocumentType.bankStatement);
    });

    test('detects invoice from "Tax Invoice" keyword', () {
      const text = 'TAX INVOICE\nGSTIN: 29ABCDE1234F1Z5';
      expect(service.detectDocumentType(text), DocumentType.invoice);
    });

    test('returns invoice for "GST Invoice" variant', () {
      const text = 'GST INVOICE\nInvoice No: INV-001';
      expect(service.detectDocumentType(text), DocumentType.invoice);
    });

    test('returns form16 when both "Form 16" and "TAN" present', () {
      const text = 'Form 16\nTAN: AAATA1234X';
      expect(service.detectDocumentType(text), DocumentType.form16);
    });

    test('returns invoice for generic Invoice keyword', () {
      const text = 'INVOICE\nSeller: ACME Ltd';
      expect(service.detectDocumentType(text), DocumentType.invoice);
    });
  });

  // ---------------------------------------------------------------------------
  // extractForm16
  // ---------------------------------------------------------------------------
  group('OcrPipelineService.extractForm16', () {
    const sampleText = '''
FORM NO. 16
Certificate under section 203 of the Income-tax Act, 1961
Name and address of the Employer: ABC COMPANY PVT LTD
TAN: AAATA1234X  PAN of Deductor: AAATA1234P
PAN of Employee: ABCDE1234F
Assessment Year: 2024-25
Gross Salary: 600000
Standard Deduction: 50000
Taxable Salary: 550000
Tax Deducted: 15000
''';

    late ExtractedForm16 result;
    setUp(() {
      result = service.extractForm16(sampleText);
    });

    test('extracts employeePan', () {
      expect(result.employeePan, 'ABCDE1234F');
    });

    test('extracts employerTan', () {
      expect(result.employerTan, 'AAATA1234X');
    });

    test('extracts employerName', () {
      expect(result.employerName, 'ABC COMPANY PVT LTD');
    });

    test('extracts assessmentYear', () {
      expect(result.assessmentYear, '2024-25');
    });

    test('extracts grossSalary in paise', () {
      // 600000 INR → 60000000 paise
      expect(result.grossSalary, 60000000);
    });

    test('extracts standardDeduction in paise', () {
      expect(result.standardDeduction, 5000000);
    });

    test('extracts taxableIncome in paise', () {
      expect(result.taxableIncome, 55000000);
    });

    test('extracts tdsDeducted in paise', () {
      expect(result.tdsDeducted, 1500000);
    });

    test('confidence is between 0 and 1', () {
      expect(result.confidence, greaterThanOrEqualTo(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));
    });

    test('returns default values for missing PAN', () {
      final r = service.extractForm16('FORM NO. 16\nGross Salary: 100000');
      expect(r.employeePan, isEmpty);
      expect(r.grossSalary, 10000000);
    });
  });

  // ---------------------------------------------------------------------------
  // extractBankStatement
  // ---------------------------------------------------------------------------
  group('OcrPipelineService.extractBankStatement', () {
    const sampleText = '''
Account Number: XXXX1234  IFSC: SBIN0001234
Opening Balance: 50000.00
Date        Description          Debit    Credit   Balance
01-04-2023  UPI Payment          1000.00           49000.00
05-04-2023  Salary Credit                50000.00  99000.00
Closing Balance: 99000.00
''';

    late ExtractedBankStatement result;
    setUp(() {
      result = service.extractBankStatement(sampleText);
    });

    test('extracts accountNumber', () {
      expect(result.accountNumber, 'XXXX1234');
    });

    test('extracts ifscCode', () {
      expect(result.ifscCode, 'SBIN0001234');
    });

    test('extracts openingBalance in paise', () {
      // 50000.00 INR → 5000000 paise
      expect(result.openingBalance, 5000000);
    });

    test('extracts closingBalance in paise', () {
      expect(result.closingBalance, 9900000);
    });

    test('parses 2 transactions', () {
      expect(result.transactions.length, 2);
    });

    test('first transaction is a debit', () {
      final tx = result.transactions[0];
      expect(tx.debit, 100000); // 1000.00 INR
      expect(tx.credit, 0);
      expect(tx.balance, 4900000);
    });

    test('second transaction is a credit', () {
      final tx = result.transactions[1];
      expect(tx.credit, 5000000); // 50000.00 INR
      expect(tx.debit, 0);
      expect(tx.balance, 9900000);
    });

    test('second transaction description contains Salary', () {
      expect(result.transactions[1].description, contains('Salary'));
    });
  });

  // ---------------------------------------------------------------------------
  // extractInvoice
  // ---------------------------------------------------------------------------
  group('OcrPipelineService.extractInvoice', () {
    const sampleText = '''
TAX INVOICE
Invoice No: INV-2024-001
Invoice Date: 15-06-2024
Seller: ACME SUPPLIES PVT LTD
Seller GSTIN: 29ABCDE1234F1Z5
Buyer: XYZ ENTERPRISES
Buyer GSTIN: 27FGHIJ5678K2A1
HSN: 998314
Total Amount: 11800.00
GST Amount: 1800.00
''';

    late ExtractedInvoice result;
    setUp(() {
      result = service.extractInvoice(sampleText);
    });

    test('extracts invoiceNumber', () {
      expect(result.invoiceNumber, 'INV-2024-001');
    });

    test('extracts sellerGstin', () {
      expect(result.sellerGstin, '29ABCDE1234F1Z5');
    });

    test('extracts buyerGstin', () {
      expect(result.buyerGstin, '27FGHIJ5678K2A1');
    });

    test('extracts totalAmount in paise', () {
      expect(result.totalAmount, 1180000); // 11800.00 INR
    });

    test('extracts gstAmount in paise', () {
      expect(result.gstAmount, 180000); // 1800.00 INR
    });

    test('extracts hsnCode', () {
      expect(result.hsnCode, '998314');
    });

    test('extracts sellerName', () {
      expect(result.sellerName, contains('ACME'));
    });

    test('extracts buyerName', () {
      expect(result.buyerName, contains('XYZ'));
    });
  });

  // ---------------------------------------------------------------------------
  // computeConfidence
  // ---------------------------------------------------------------------------
  group('OcrPipelineService.computeConfidence', () {
    test('high confidence for complete form16', () {
      final doc = OcrDocument(
        documentId: 'doc-1',
        documentType: DocumentType.form16,
        rawText: 'FORM NO. 16',
        confidence: 1.0,
        extractedAt: DateTime(2024),
        pageCount: 1,
        processingStatus: ProcessingStatus.completed,
      );
      final form16 = ExtractedForm16(
        employeePan: 'ABCDE1234F',
        employerTan: 'AAATA1234X',
        employerName: 'ABC Corp',
        financialYear: 2024,
        assessmentYear: '2024-25',
        grossSalary: 60000000,
        taxableIncome: 55000000,
        tdsDeducted: 1500000,
        professionalTax: 0,
        standardDeduction: 5000000,
        confidence: 0.95,
      );
      final confidence = service.computeConfidence(doc, form16);
      expect(confidence, greaterThan(0.7));
    });

    test('lower confidence when PAN is empty', () {
      final doc = OcrDocument(
        documentId: 'doc-2',
        documentType: DocumentType.form16,
        rawText: 'FORM NO. 16',
        confidence: 1.0,
        extractedAt: DateTime(2024),
        pageCount: 1,
        processingStatus: ProcessingStatus.completed,
      );
      final form16 = ExtractedForm16(
        employeePan: '',
        employerTan: 'AAATA1234X',
        employerName: 'ABC Corp',
        financialYear: 2024,
        assessmentYear: '2024-25',
        grossSalary: 60000000,
        taxableIncome: 55000000,
        tdsDeducted: 1500000,
        professionalTax: 0,
        standardDeduction: 5000000,
        confidence: 0.5,
      );
      final fullConfidence = service.computeConfidence(
        doc,
        ExtractedForm16(
          employeePan: 'ABCDE1234F',
          employerTan: 'AAATA1234X',
          employerName: 'ABC Corp',
          financialYear: 2024,
          assessmentYear: '2024-25',
          grossSalary: 60000000,
          taxableIncome: 55000000,
          tdsDeducted: 1500000,
          professionalTax: 0,
          standardDeduction: 5000000,
          confidence: 0.95,
        ),
      );
      final emptyPanConfidence = service.computeConfidence(doc, form16);
      expect(emptyPanConfidence, lessThan(fullConfidence));
    });

    test('confidence is bounded between 0 and 1', () {
      final doc = OcrDocument(
        documentId: 'doc-3',
        documentType: DocumentType.form16,
        rawText: '',
        confidence: 0.0,
        extractedAt: DateTime(2024),
        pageCount: 1,
        processingStatus: ProcessingStatus.failed,
      );
      final form16 = ExtractedForm16(
        employeePan: '',
        employerTan: '',
        employerName: '',
        financialYear: 0,
        assessmentYear: '',
        grossSalary: 0,
        taxableIncome: 0,
        tdsDeducted: 0,
        professionalTax: 0,
        standardDeduction: 0,
        confidence: 0.0,
      );
      final confidence = service.computeConfidence(doc, form16);
      expect(confidence, greaterThanOrEqualTo(0.0));
      expect(confidence, lessThanOrEqualTo(1.0));
    });
  });

  // ---------------------------------------------------------------------------
  // Model immutability (copyWith)
  // ---------------------------------------------------------------------------
  group('ExtractedTransaction copyWith', () {
    final tx = ExtractedTransaction(
      date: DateTime(2023, 4, 1),
      description: 'UPI Payment',
      debit: 100000,
      credit: 0,
      balance: 4900000,
      referenceNumber: null,
    );

    test('copyWith creates a new instance', () {
      final updated = tx.copyWith(debit: 200000);
      expect(updated.debit, 200000);
      expect(updated.credit, tx.credit);
      expect(identical(tx, updated), isFalse);
    });

    test('equality based on all fields', () {
      final copy = tx.copyWith();
      expect(copy, equals(tx));
    });
  });

  group('ExtractedForm16 copyWith', () {
    const form16 = ExtractedForm16(
      employeePan: 'ABCDE1234F',
      employerTan: 'AAATA1234X',
      employerName: 'ABC Corp',
      financialYear: 2024,
      assessmentYear: '2024-25',
      grossSalary: 60000000,
      taxableIncome: 55000000,
      tdsDeducted: 1500000,
      professionalTax: 0,
      standardDeduction: 5000000,
      confidence: 0.95,
    );

    test('copyWith returns new instance with changed field', () {
      final updated = form16.copyWith(employeePan: 'XYZAB1234Z');
      expect(updated.employeePan, 'XYZAB1234Z');
      expect(updated.employerTan, form16.employerTan);
      expect(identical(form16, updated), isFalse);
    });

    test('equality is value-based', () {
      const copy = ExtractedForm16(
        employeePan: 'ABCDE1234F',
        employerTan: 'AAATA1234X',
        employerName: 'ABC Corp',
        financialYear: 2024,
        assessmentYear: '2024-25',
        grossSalary: 60000000,
        taxableIncome: 55000000,
        tdsDeducted: 1500000,
        professionalTax: 0,
        standardDeduction: 5000000,
        confidence: 0.95,
      );
      expect(form16, equals(copy));
    });
  });

  group('OcrDocument copyWith', () {
    final doc = OcrDocument(
      documentId: 'doc-1',
      documentType: DocumentType.form16,
      rawText: 'raw',
      confidence: 0.9,
      extractedAt: DateTime(2024),
      pageCount: 2,
      processingStatus: ProcessingStatus.completed,
    );

    test('copyWith updates processingStatus', () {
      final updated = doc.copyWith(processingStatus: ProcessingStatus.failed);
      expect(updated.processingStatus, ProcessingStatus.failed);
      expect(updated.documentId, doc.documentId);
    });
  });
}
