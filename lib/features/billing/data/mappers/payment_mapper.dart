import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/billing/domain/models/payment_record.dart';

class PaymentMapper {
  const PaymentMapper._();

  // Drift row → PaymentRecord domain model
  static PaymentRecord fromRow(PaymentRow row) {
    return PaymentRecord(
      id: row.id,
      invoiceId: row.invoiceId,
      clientName: row.clientName,
      amount: row.amount,
      paymentDate: row.paymentDate,
      mode: row.mode,
      reference: row.reference,
      notes: row.notes,
    );
  }

  // PaymentRecord domain model → Drift companion (for insert/update)
  static PaymentsTableCompanion toCompanion(
    PaymentRecord payment, {
    String firmId = '',
  }) {
    return PaymentsTableCompanion(
      id: Value(payment.id),
      firmId: Value(firmId),
      invoiceId: Value(payment.invoiceId),
      clientName: Value(payment.clientName),
      amount: Value(payment.amount),
      paymentDate: Value(payment.paymentDate),
      mode: Value(payment.mode),
      reference: Value(payment.reference),
      notes: Value(payment.notes),
      isDirty: const Value(true),
    );
  }

  // JSON (from Supabase) → PaymentRecord domain model
  static PaymentRecord fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      clientName: json['client_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: json['payment_date'] as String,
      mode: json['payment_mode'] as String,
      reference: json['reference_number'] as String,
      notes: json['notes'] as String? ?? '',
    );
  }

  // PaymentRecord domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(PaymentRecord payment) {
    return {
      'id': payment.id,
      'invoice_id': payment.invoiceId,
      'client_name': payment.clientName,
      'amount': payment.amount,
      'payment_date': payment.paymentDate,
      'payment_mode': payment.mode,
      'reference_number': payment.reference,
      'notes': payment.notes,
    };
  }
}
