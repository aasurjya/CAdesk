import 'package:ca_app/features/ocr/domain/models/extracted_bank_statement.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_invoice.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_line_item.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_transaction.dart';
import 'package:ca_app/features/ocr/domain/services/document_validator_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final validator = DocumentValidatorService.instance;

  // ---------------------------------------------------------------------------
  // validateForm16
  // ---------------------------------------------------------------------------
  group('DocumentValidatorService.validateForm16', () {
    const validForm16 = ExtractedForm16(
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

    test('no errors for valid form16', () {
      final errors = validator.validateForm16(validForm16);
      expect(errors, isEmpty);
    });

    test('error for invalid PAN format', () {
      final form16 = validForm16.copyWith(employeePan: 'INVALID');
      final errors = validator.validateForm16(form16);
      expect(errors, anyElement(contains('PAN')));
    });

    test('error for invalid TAN format', () {
      final form16 = validForm16.copyWith(employerTan: 'BADTAN');
      final errors = validator.validateForm16(form16);
      expect(errors, anyElement(contains('TAN')));
    });

    test('error when taxable > 250000 INR but TDS is zero', () {
      final form16 = validForm16.copyWith(
        taxableIncome: 30000000, // 300000 INR (above 2.5L)
        tdsDeducted: 0,
      );
      final errors = validator.validateForm16(form16);
      expect(errors, anyElement(contains('TDS')));
    });

    test('no TDS error when taxable income is exactly 250000 INR (2.5L)', () {
      final form16 = validForm16.copyWith(
        taxableIncome: 25000000, // exactly 2.5L INR in paise
        tdsDeducted: 0,
      );
      final errors = validator.validateForm16(form16);
      expect(errors.where((e) => e.contains('TDS')), isEmpty);
    });

    test('error for empty employeePan', () {
      final form16 = validForm16.copyWith(employeePan: '');
      final errors = validator.validateForm16(form16);
      expect(errors, anyElement(contains('PAN')));
    });

    test('error for empty employerTan', () {
      final form16 = validForm16.copyWith(employerTan: '');
      final errors = validator.validateForm16(form16);
      expect(errors, anyElement(contains('TAN')));
    });
  });

  // ---------------------------------------------------------------------------
  // validateBankStatement
  // ---------------------------------------------------------------------------
  group('DocumentValidatorService.validateBankStatement', () {
    // Opening: 5000000 paise (50000 INR)
    // Tx1: debit 100000 → balance 4900000
    // Tx2: credit 5000000 → balance 9900000
    // Closing: 9900000 paise (99000 INR) ✓
    final validStatement = ExtractedBankStatement(
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
          referenceNumber: null,
        ),
      ],
    );

    test('no errors for valid bank statement', () {
      final errors = validator.validateBankStatement(validStatement);
      expect(errors, isEmpty);
    });

    test('error when balance continuity fails', () {
      final badTx = ExtractedTransaction(
        date: DateTime(2023, 4, 1),
        description: 'UPI Payment',
        debit: 100000,
        credit: 0,
        balance: 4800000, // wrong balance
        referenceNumber: null,
      );
      final stmt = ExtractedBankStatement(
        accountNumber: 'XXXX1234',
        bankName: 'SBI',
        ifscCode: 'SBIN0001234',
        period: 'Apr 2023',
        openingBalance: 5000000,
        closingBalance: 9900000,
        transactions: [badTx, validStatement.transactions[1]],
      );
      final errors = validator.validateBankStatement(stmt);
      expect(errors, isNotEmpty);
    });

    test(
      'error when closing balance does not match last transaction balance',
      () {
        final stmt = validStatement.copyWith(closingBalance: 8000000);
        final errors = validator.validateBankStatement(stmt);
        expect(errors, anyElement(contains('closing')));
      },
    );

    test('tolerance of ±100 paise (1 INR) is allowed', () {
      // Adjust closing by 50 paise — within tolerance
      final stmt = validStatement.copyWith(closingBalance: 9900050);
      final errors = validator.validateBankStatement(stmt);
      expect(errors.where((e) => e.contains('closing')), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // validateInvoice
  // ---------------------------------------------------------------------------
  group('DocumentValidatorService.validateInvoice', () {
    final validInvoice = ExtractedInvoice(
      invoiceNumber: 'INV-001',
      invoiceDate: DateTime(2024, 6, 15),
      sellerName: 'ACME Supplies Pvt Ltd',
      sellerGstin: '29ABCDE1234F1Z5',
      buyerName: 'XYZ Enterprises',
      buyerGstin: '27FGHIJ5678K2A1',
      lineItems: [
        ExtractedLineItem(
          description: 'Consulting Services',
          quantity: 1,
          unitPrice: 1000000,
          amount: 1000000,
          hsnCode: '998314',
        ),
      ],
      totalAmount: 1180000,
      gstAmount: 180000,
      hsnCode: '998314',
    );

    test('no errors for valid invoice', () {
      final errors = validator.validateInvoice(validInvoice);
      expect(errors, isEmpty);
    });

    test('error for invalid seller GSTIN format', () {
      final invoice = validInvoice.copyWith(sellerGstin: 'BADGSTIN');
      final errors = validator.validateInvoice(invoice);
      expect(errors, anyElement(contains('GSTIN')));
    });

    test('error for invalid buyer GSTIN format', () {
      final invoice = validInvoice.copyWith(buyerGstin: 'INVALID');
      final errors = validator.validateInvoice(invoice);
      expect(errors, anyElement(contains('GSTIN')));
    });

    test('error when total != sum of line items + gst', () {
      final invoice = validInvoice.copyWith(totalAmount: 999999);
      final errors = validator.validateInvoice(invoice);
      expect(errors, anyElement(contains('total')));
    });

    test('no error when GSTIN fields are null (optional)', () {
      final invoice = ExtractedInvoice(
        invoiceNumber: 'INV-002',
        invoiceDate: DateTime(2024),
        sellerName: 'Small Seller',
        sellerGstin: null,
        buyerName: 'Small Buyer',
        buyerGstin: null,
        lineItems: [
          ExtractedLineItem(
            description: 'Item',
            quantity: 1,
            unitPrice: 500000,
            amount: 500000,
            hsnCode: null,
          ),
        ],
        totalAmount: 500000,
        gstAmount: 0,
        hsnCode: null,
      );
      final errors = validator.validateInvoice(invoice);
      expect(errors, isEmpty);
    });

    test('no error when total matches line items with zero GST', () {
      final invoice = ExtractedInvoice(
        invoiceNumber: 'INV-003',
        invoiceDate: null,
        sellerName: 'Seller',
        sellerGstin: null,
        buyerName: 'Buyer',
        buyerGstin: null,
        lineItems: [
          ExtractedLineItem(
            description: 'Product',
            quantity: 2,
            unitPrice: 250000,
            amount: 500000,
            hsnCode: null,
          ),
        ],
        totalAmount: 500000,
        gstAmount: 0,
        hsnCode: null,
      );
      final errors = validator.validateInvoice(invoice);
      expect(errors, isEmpty);
    });
  });
}
