import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/billing/domain/models/invoice.dart';

class InvoiceMapper {
  const InvoiceMapper._();

  // Drift row → Invoice domain model
  static Invoice fromRow(InvoiceRow row) {
    return Invoice(
      id: row.id,
      invoiceNumber: row.invoiceNumber,
      clientId: row.clientId,
      clientName: row.clientName,
      gstin: row.gstin,
      invoiceDate: DateTime.parse(row.invoiceDate),
      dueDate: DateTime.parse(row.dueDate),
      lineItems: _parseLineItems(row.lineItems),
      subtotal: row.subtotal,
      totalGst: row.totalGst,
      grandTotal: row.grandTotal,
      paidAmount: row.paidAmount,
      balanceDue: row.balanceDue,
      status: _safeStatus(row.status),
      paymentDate: row.paymentDate != null
          ? DateTime.tryParse(row.paymentDate!)
          : null,
      paymentMethod: row.paymentMethod,
      remarks: row.remarks,
      isRecurring: row.isRecurring,
      recurringFrequency: row.recurringFrequency != null
          ? _safeRecurringFrequency(row.recurringFrequency!)
          : null,
    );
  }

  // Invoice domain model → Drift companion (for insert/update)
  static InvoicesTableCompanion toCompanion(
    Invoice invoice, {
    String firmId = '',
  }) {
    return InvoicesTableCompanion(
      id: Value(invoice.id),
      firmId: Value(firmId),
      clientId: Value(invoice.clientId),
      clientName: Value(invoice.clientName),
      invoiceNumber: Value(invoice.invoiceNumber),
      gstin: Value(invoice.gstin),
      invoiceDate: Value(invoice.invoiceDate.toIso8601String()),
      dueDate: Value(invoice.dueDate.toIso8601String()),
      lineItems: Value(_serializeLineItems(invoice.lineItems)),
      subtotal: Value(invoice.subtotal),
      totalGst: Value(invoice.totalGst),
      grandTotal: Value(invoice.grandTotal),
      paidAmount: Value(invoice.paidAmount),
      balanceDue: Value(invoice.balanceDue),
      status: Value(invoice.status.name),
      paymentDate: Value(invoice.paymentDate?.toIso8601String()),
      paymentMethod: Value(invoice.paymentMethod),
      remarks: Value(invoice.remarks),
      isRecurring: Value(invoice.isRecurring),
      recurringFrequency: Value(invoice.recurringFrequency?.name),
      isDirty: const Value(true),
    );
  }

  // JSON (from Supabase) → Invoice domain model
  // lineItems are fetched separately in Phase 2; pass them in or default to [].
  static Invoice fromJson(
    Map<String, dynamic> json, {
    List<LineItem> lineItems = const [],
  }) {
    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      gstin: json['gstin'] as String?,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      lineItems: lineItems,
      subtotal: (json['subtotal'] as num).toDouble(),
      totalGst: (json['total_gst'] as num).toDouble(),
      grandTotal: (json['grand_total'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num).toDouble(),
      balanceDue: (json['balance_due'] as num).toDouble(),
      status: _safeStatus(json['status'] as String? ?? 'draft'),
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'] as String)
          : null,
      paymentMethod: json['payment_method'] as String?,
      remarks: json['remarks'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringFrequency: json['recurring_frequency'] != null
          ? _safeRecurringFrequency(json['recurring_frequency'] as String)
          : null,
    );
  }

  // Invoice domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(Invoice invoice) {
    return {
      'id': invoice.id,
      'invoice_number': invoice.invoiceNumber,
      'client_id': invoice.clientId,
      'client_name': invoice.clientName,
      'gstin': invoice.gstin,
      'invoice_date': invoice.invoiceDate.toIso8601String(),
      'due_date': invoice.dueDate.toIso8601String(),
      'subtotal': invoice.subtotal,
      'total_gst': invoice.totalGst,
      'grand_total': invoice.grandTotal,
      'paid_amount': invoice.paidAmount,
      'balance_due': invoice.balanceDue,
      'status': invoice.status.name,
      'payment_date': invoice.paymentDate?.toIso8601String(),
      'payment_method': invoice.paymentMethod,
      'remarks': invoice.remarks,
      'is_recurring': invoice.isRecurring,
      'recurring_frequency': invoice.recurringFrequency?.name,
    };
  }

  static List<LineItem> _parseLineItems(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => _lineItemFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static String _serializeLineItems(List<LineItem> items) {
    return jsonEncode(items.map(_lineItemToJson).toList());
  }

  static LineItem _lineItemFromJson(Map<String, dynamic> json) {
    return LineItem(
      description: json['description'] as String,
      hsn: json['hsn'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      taxableAmount: (json['taxable_amount'] as num).toDouble(),
      gstRate: (json['gst_rate'] as num).toDouble(),
      cgst: (json['cgst'] as num).toDouble(),
      sgst: (json['sgst'] as num).toDouble(),
      igst: (json['igst'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  static Map<String, dynamic> _lineItemToJson(LineItem item) {
    return {
      'description': item.description,
      'hsn': item.hsn,
      'quantity': item.quantity,
      'rate': item.rate,
      'taxable_amount': item.taxableAmount,
      'gst_rate': item.gstRate,
      'cgst': item.cgst,
      'sgst': item.sgst,
      'igst': item.igst,
      'total': item.total,
    };
  }

  static InvoiceStatus _safeStatus(String name) {
    try {
      return InvoiceStatus.values.byName(name);
    } catch (_) {
      return InvoiceStatus.draft;
    }
  }

  static RecurringFrequency? _safeRecurringFrequency(String name) {
    try {
      return RecurringFrequency.values.byName(name);
    } catch (_) {
      return null;
    }
  }
}
