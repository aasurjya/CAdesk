/// Immutable model representing a batch IRN generation job.
///
/// Each batch corresponds to a bulk upload of invoices to the IRP for a
/// single client in one processing run.
class IrnBatch {
  const IrnBatch({
    required this.id,
    required this.clientName,
    required this.totalInvoices,
    required this.successCount,
    required this.failedCount,
    required this.pendingCount,
    required this.totalValue,
    required this.processedDate,
    required this.batchStatus,
  });

  /// Unique batch identifier.
  final String id;

  /// CA client for whom this batch was processed.
  final String clientName;

  /// Total number of invoices submitted in this batch.
  final int totalInvoices;

  /// Invoices for which IRN was successfully generated.
  final int successCount;

  /// Invoices that failed IRN generation (validation / portal errors).
  final int failedCount;

  /// Invoices still awaiting IRP response.
  final int pendingCount;

  /// Aggregate invoice value of this batch in Indian Lakhs (₹L).
  final double totalValue;

  /// Human-readable date when batch was submitted, e.g. "11 Mar 2026".
  final String processedDate;

  /// Overall batch state: Processing | Completed | Failed | Partial
  final String batchStatus;

  /// Returns a copy with the given fields replaced.
  IrnBatch copyWith({
    String? id,
    String? clientName,
    int? totalInvoices,
    int? successCount,
    int? failedCount,
    int? pendingCount,
    double? totalValue,
    String? processedDate,
    String? batchStatus,
  }) {
    return IrnBatch(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      successCount: successCount ?? this.successCount,
      failedCount: failedCount ?? this.failedCount,
      pendingCount: pendingCount ?? this.pendingCount,
      totalValue: totalValue ?? this.totalValue,
      processedDate: processedDate ?? this.processedDate,
      batchStatus: batchStatus ?? this.batchStatus,
    );
  }
}
