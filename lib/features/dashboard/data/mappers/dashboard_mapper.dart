import 'package:ca_app/features/dashboard/domain/models/dashboard_summary.dart';

/// Maps between dashboard domain models and JSON (Supabase RPC responses).
///
/// The dashboard module is read-only (aggregated view), so there are no
/// companion or toJson conversions needed for mutations.
class DashboardMapper {
  const DashboardMapper._();

  // ── DashboardSummary ──────────────────────────────────────────────────────

  /// Converts a Supabase RPC JSON response to a [DashboardSummary].
  ///
  /// Expected keys (snake_case):
  ///   total_clients, filed_returns, pending_returns, overdue_tasks,
  ///   upcoming_deadlines, total_billing
  static DashboardSummary summaryFromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalClients: _parseInt(json['total_clients']),
      filedReturns: _parseInt(json['filed_returns']),
      pendingReturns: _parseInt(json['pending_returns']),
      overdueTasks: _parseInt(json['overdue_tasks']),
      upcomingDeadlines: _parseInt(json['upcoming_deadlines']),
      totalBilling: _parseDouble(json['total_billing']),
    );
  }

  // ── RecentFiling ──────────────────────────────────────────────────────────

  /// Converts a Supabase RPC JSON row to a [RecentFiling].
  ///
  /// Expected keys (snake_case):
  ///   client_name, filing_type, status, date
  static RecentFiling recentFilingFromJson(Map<String, dynamic> json) {
    return RecentFiling(
      clientName: json['client_name'] as String? ?? '',
      filingType: json['filing_type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      date: _parseDateTime(json['date']),
    );
  }

  // ── TopClient ─────────────────────────────────────────────────────────────

  /// Converts a Supabase RPC JSON row to a [TopClient].
  ///
  /// Expected keys (snake_case):
  ///   client_name, filing_count, billing_amount
  static TopClient topClientFromJson(Map<String, dynamic> json) {
    return TopClient(
      clientName: json['client_name'] as String? ?? '',
      filingCount: _parseInt(json['filing_count']),
      billingAmount: _parseDouble(json['billing_amount']),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
