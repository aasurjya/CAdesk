/// Status of a billing invoice.
enum InvoiceStatus {
  draft('Draft'),
  sent('Sent'),
  partial('Partial'),
  paid('Paid'),
  overdue('Overdue'),
  cancelled('Cancelled');

  const InvoiceStatus(this.label);
  final String label;
}

/// Frequency for recurring invoices.
enum RecurringFrequency {
  monthly('Monthly'),
  quarterly('Quarterly'),
  halfYearly('Half-Yearly'),
  yearly('Yearly');

  const RecurringFrequency(this.label);
  final String label;
}

/// A single line item in an invoice.
class LineItem {
  const LineItem({
    required this.description,
    required this.hsn,
    required this.quantity,
    required this.rate,
    required this.taxableAmount,
    required this.gstRate,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.total,
  });

  final String description;

  /// HSN / SAC code.
  final String hsn;
  final double quantity;
  final double rate;
  final double taxableAmount;

  /// GST rate as a percentage (e.g. 18 for 18%).
  final double gstRate;
  final double cgst;
  final double sgst;
  final double igst;
  final double total;

  LineItem copyWith({
    String? description,
    String? hsn,
    double? quantity,
    double? rate,
    double? taxableAmount,
    double? gstRate,
    double? cgst,
    double? sgst,
    double? igst,
    double? total,
  }) {
    return LineItem(
      description: description ?? this.description,
      hsn: hsn ?? this.hsn,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      gstRate: gstRate ?? this.gstRate,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      igst: igst ?? this.igst,
      total: total ?? this.total,
    );
  }
}

/// Immutable GST-compliant invoice model.
class Invoice {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.invoiceDate,
    required this.dueDate,
    required this.lineItems,
    required this.subtotal,
    required this.totalGst,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceDue,
    required this.status,
    this.gstin,
    this.paymentDate,
    this.paymentMethod,
    this.remarks,
    this.isRecurring = false,
    this.recurringFrequency,
  });

  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String? gstin;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<LineItem> lineItems;
  final double subtotal;
  final double totalGst;
  final double grandTotal;
  final double paidAmount;
  final double balanceDue;
  final InvoiceStatus status;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? remarks;
  final bool isRecurring;
  final RecurringFrequency? recurringFrequency;

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    String? gstin,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<LineItem>? lineItems,
    double? subtotal,
    double? totalGst,
    double? grandTotal,
    double? paidAmount,
    double? balanceDue,
    InvoiceStatus? status,
    DateTime? paymentDate,
    String? paymentMethod,
    String? remarks,
    bool? isRecurring,
    RecurringFrequency? recurringFrequency,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      gstin: gstin ?? this.gstin,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      totalGst: totalGst ?? this.totalGst,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      remarks: remarks ?? this.remarks,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
