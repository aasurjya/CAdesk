import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/billing/data/mappers/payment_mapper.dart';
import 'package:ca_app/features/billing/domain/models/payment_record.dart';

void main() {
  group('PaymentMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all fields from JSON', () {
        final json = {
          'id': 'pay-001',
          'invoice_id': 'inv-001',
          'client_name': 'Rajesh Kumar',
          'amount': 11800.0,
          'payment_date': '15 Apr 2025',
          'payment_mode': 'NEFT',
          'reference_number': 'UTR123456789',
          'notes': 'Full payment received',
        };

        final payment = PaymentMapper.fromJson(json);

        expect(payment.id, 'pay-001');
        expect(payment.invoiceId, 'inv-001');
        expect(payment.clientName, 'Rajesh Kumar');
        expect(payment.amount, 11800.0);
        expect(payment.paymentDate, '15 Apr 2025');
        expect(payment.mode, 'NEFT');
        expect(payment.reference, 'UTR123456789');
        expect(payment.notes, 'Full payment received');
      });

      test('defaults notes to empty string when null', () {
        final json = {
          'id': 'pay-002',
          'invoice_id': 'inv-002',
          'client_name': 'Mehta & Sons',
          'amount': 5900.0,
          'payment_date': '20 Apr 2025',
          'payment_mode': 'UPI',
          'reference_number': 'UPI/TXN/2025/001',
          'notes': null,
        };

        final payment = PaymentMapper.fromJson(json);
        expect(payment.notes, '');
      });

      test('handles integer amount (num coercion)', () {
        final json = {
          'id': 'pay-003',
          'invoice_id': 'inv-003',
          'client_name': 'Test Client',
          'amount': 5000,
          'payment_date': '01 May 2025',
          'payment_mode': 'Cash',
          'reference_number': 'CASH-001',
          'notes': '',
        };

        final payment = PaymentMapper.fromJson(json);
        expect(payment.amount, 5000.0);
        expect(payment.amount, isA<double>());
      });

      test('maps UPI payment mode correctly', () {
        final json = {
          'id': 'pay-004',
          'invoice_id': 'inv-004',
          'client_name': 'Test',
          'amount': 2500.0,
          'payment_date': '05 May 2025',
          'payment_mode': 'UPI',
          'reference_number': 'UPI12345',
          'notes': 'UPI payment',
        };

        final payment = PaymentMapper.fromJson(json);
        expect(payment.mode, 'UPI');
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late PaymentRecord samplePayment;

      setUp(() {
        samplePayment = const PaymentRecord(
          id: 'pay-json-001',
          invoiceId: 'inv-json-001',
          clientName: 'Priya Nair',
          amount: 23600.0,
          paymentDate: '10 Apr 2025',
          mode: 'RTGS',
          reference: 'RTGS/2025/001',
          notes: 'Advance payment',
        );
      });

      test('includes all fields', () {
        final json = PaymentMapper.toJson(samplePayment);

        expect(json['id'], 'pay-json-001');
        expect(json['invoice_id'], 'inv-json-001');
        expect(json['client_name'], 'Priya Nair');
        expect(json['amount'], 23600.0);
        expect(json['payment_date'], '10 Apr 2025');
        expect(json['payment_mode'], 'RTGS');
        expect(json['reference_number'], 'RTGS/2025/001');
        expect(json['notes'], 'Advance payment');
      });

      test('serializes empty notes as empty string', () {
        final emptyNotesPayment = samplePayment.copyWith(notes: '');
        final json = PaymentMapper.toJson(emptyNotesPayment);
        expect(json['notes'], '');
      });

      test('serializes zero amount correctly', () {
        final zeroPayment = samplePayment.copyWith(amount: 0.0);
        final json = PaymentMapper.toJson(zeroPayment);
        expect(json['amount'], 0.0);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = PaymentMapper.toJson(samplePayment);
        final restored = PaymentMapper.fromJson(json);

        expect(restored.id, samplePayment.id);
        expect(restored.invoiceId, samplePayment.invoiceId);
        expect(restored.clientName, samplePayment.clientName);
        expect(restored.amount, samplePayment.amount);
        expect(restored.paymentDate, samplePayment.paymentDate);
        expect(restored.mode, samplePayment.mode);
        expect(restored.reference, samplePayment.reference);
        expect(restored.notes, samplePayment.notes);
      });

      test('preserves special characters in reference number', () {
        final payWithSpecialRef = samplePayment.copyWith(
          reference: 'UTR/2025-26/001/XYZ',
        );
        final json = PaymentMapper.toJson(payWithSpecialRef);
        expect(json['reference_number'], 'UTR/2025-26/001/XYZ');
      });

      test('handles large amount values', () {
        final largePayment = samplePayment.copyWith(amount: 9999999.99);
        final json = PaymentMapper.toJson(largePayment);
        expect(json['amount'], 9999999.99);
      });
    });
  });
}
