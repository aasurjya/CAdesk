import 'package:ca_app/features/analytics/domain/models/client_health_score.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/practice/domain/models/billing_invoice.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';

// ---------------------------------------------------------------------------
// Scoring constants
// ---------------------------------------------------------------------------

/// Starting score before adjustments.
const double _baseScore = 70.0;

/// Penalty: no engagement in the past 6 months.
const double _penaltyNoRecentEngagement = -30.0;

/// Penalty: outstanding invoice overdue by more than 90 days.
const double _penaltyOverdueInvoice = -20.0;

/// Penalty: client uses only one service type.
const double _penaltySingleService = -10.0;

/// Penalty: number of engagements in past 12 months is decreasing vs prior
/// 12 months (detected as count < 2 for simplicity; can be replaced with
/// a more sophisticated trend check when historical data is available).
const double _penaltyDecreasingEngagement = -15.0;

/// Bonus: client joined less than 6 months ago.
const double _bonusNewClient = 10.0;

/// Bonus: client uses more than one service type.
const double _bonusMultipleServices = 15.0;

/// Bonus: client has no outstanding invoices (proxy for auto-pay or prompt
/// payment behaviour).
const double _bonusPromptPayment = 10.0;

/// Months threshold for "new client" bonus.
const int _newClientMonths = 6;

/// Days threshold for "no recent engagement" penalty.
const int _noEngagementDays = 180;

/// Days threshold for "overdue invoice" penalty.
const int _overdueInvoiceDays = 90;

/// Provides rule-based churn risk scoring for clients.
///
/// Stateless singleton — all methods are pure functions of their inputs.
class ChurnPredictionService {
  ChurnPredictionService._();

  static final ChurnPredictionService instance = ChurnPredictionService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Computes a [ClientHealthScore] for [client].
  ///
  /// [history] is the full engagement history for this client.
  /// [invoices] are all billing invoices for this client.
  /// [now] defaults to [DateTime.now()] and can be overridden in tests.
  ClientHealthScore scoreClient(
    Client client,
    List<Engagement> history,
    List<BillingInvoice> invoices, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final riskFactors = <String>[];
    var score = _baseScore;

    // --- Engagement recency ---------------------------------------------------
    final recentEngagements = _engagementsInPast12Months(history, today);
    final lastServiceDate = _latestEngagementDate(history);

    if (lastServiceDate == null ||
        today.difference(lastServiceDate).inDays >= _noEngagementDays) {
      score += _penaltyNoRecentEngagement;
      riskFactors.add('No engagement in 6+ months');
    }

    // --- Outstanding invoice age ----------------------------------------------
    final hasOldOutstanding = invoices.any(
      (inv) =>
          inv.paymentStatus != PaymentStatus.paid &&
          inv.paymentStatus != PaymentStatus.cancelled &&
          today.difference(inv.dueDate).inDays > _overdueInvoiceDays,
    );
    if (hasOldOutstanding) {
      score += _penaltyOverdueInvoice;
      riskFactors.add('Outstanding invoice > 90 days');
    }

    // --- Service breadth ------------------------------------------------------
    final serviceCount = client.servicesAvailed.length;
    if (serviceCount <= 1) {
      score += _penaltySingleService;
      riskFactors.add('Only 1 service type');
    } else {
      score += _bonusMultipleServices;
    }

    // --- Engagement trend -----------------------------------------------------
    if (recentEngagements.length < 2) {
      score += _penaltyDecreasingEngagement;
    }

    // --- New client bonus -----------------------------------------------------
    final monthsSinceJoined = _monthsBetween(client.createdAt, today);
    if (monthsSinceJoined < _newClientMonths) {
      score += _bonusNewClient;
    }

    // --- Prompt payment bonus -------------------------------------------------
    final hasOutstanding = invoices.any(
      (inv) =>
          inv.paymentStatus != PaymentStatus.paid &&
          inv.paymentStatus != PaymentStatus.cancelled,
    );
    if (!hasOutstanding) {
      score += _bonusPromptPayment;
    }

    // --- Clamp and derive risk ------------------------------------------------
    final clamped = score.clamp(0.0, 100.0);
    final risk = _deriveRisk(clamped);

    // --- Outstanding total ----------------------------------------------------
    final outstandingAmount = invoices
        .where(
          (inv) =>
              inv.paymentStatus != PaymentStatus.paid &&
              inv.paymentStatus != PaymentStatus.cancelled,
        )
        .fold(0, (sum, inv) => sum + inv.totalAmount);

    final lastPaymentDate = _latestPaymentDate(invoices);

    return ClientHealthScore(
      clientPan: client.pan,
      score: clamped,
      churnRisk: risk,
      riskFactors: List.unmodifiable(riskFactors),
      lastServiceDate: lastServiceDate,
      lastPaymentDate: lastPaymentDate,
      outstandingAmount: outstandingAmount,
      engagementCount: recentEngagements.length,
      recommendation: _buildRecommendation(risk, riskFactors),
    );
  }

  /// Derives [ChurnRisk] from a numeric [score].
  ///
  /// Thresholds:
  /// - 70–100 → low
  /// - 40–69  → medium
  /// - 20–39  → high
  /// - 0–19   → critical
  ChurnRisk predictChurnRisk(ClientHealthScore score) =>
      _deriveRisk(score.score);

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  ChurnRisk _deriveRisk(double score) {
    if (score >= 70.0) return ChurnRisk.low;
    if (score >= 40.0) return ChurnRisk.medium;
    if (score >= 20.0) return ChurnRisk.high;
    return ChurnRisk.critical;
  }

  List<Engagement> _engagementsInPast12Months(
    List<Engagement> history,
    DateTime today,
  ) {
    final cutoff = today.subtract(const Duration(days: 365));
    return history.where((e) {
      final date = e.completedDate;
      return date != null && date.isAfter(cutoff);
    }).toList();
  }

  DateTime? _latestEngagementDate(List<Engagement> history) {
    final dates = history
        .map((e) => e.completedDate)
        .whereType<DateTime>()
        .toList();
    if (dates.isEmpty) return null;
    dates.sort((a, b) => b.compareTo(a));
    return dates.first;
  }

  DateTime? _latestPaymentDate(List<BillingInvoice> invoices) {
    final paid = invoices
        .where((inv) => inv.paymentStatus == PaymentStatus.paid)
        .toList();
    if (paid.isEmpty) return null;
    // Use dueDate as proxy for payment date (actual payment date not on model).
    paid.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return paid.first.dueDate;
  }

  int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  String _buildRecommendation(ChurnRisk risk, List<String> factors) {
    switch (risk) {
      case ChurnRisk.low:
        return 'Client is healthy. Continue regular service.';
      case ChurnRisk.medium:
        return 'Schedule a check-in call. '
            'Address: ${factors.isEmpty ? "monitor activity" : factors.join(", ")}.';
      case ChurnRisk.high:
        return 'High churn risk detected. Immediate outreach recommended. '
            'Key issues: ${factors.join(", ")}.';
      case ChurnRisk.critical:
        return 'Client likely churning. Escalate to senior partner. '
            'Issues: ${factors.isEmpty ? "all risk areas" : factors.join(", ")}.';
    }
  }
}
