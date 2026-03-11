import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Retainer tier represents the pricing tier — stored as reference, not on the
/// [CfoRetainer] model itself.
enum RetainerTier {
  starter('Starter', Color(0xFF718096), '₹8K/mo'),
  growth('Growth', Color(0xFF0D7C7C), '₹18K/mo'),
  enterprise('Enterprise', Color(0xFF1B3A5C), '₹35K/mo');

  const RetainerTier(this.label, this.color, this.priceLabel);

  final String label;
  final Color color;
  final String priceLabel;
}

/// Lifecycle status of a CFO retainer engagement.
enum CfoRetainerStatus {
  active('Active', Color(0xFF1A7A3A), Icons.check_circle_rounded),
  review('Under Review', Color(0xFFD4890E), Icons.rate_review_rounded),
  onHold('On Hold', Color(0xFF718096), Icons.pause_circle_rounded),
  churned('Churned', Color(0xFFC62828), Icons.cancel_rounded);

  const CfoRetainerStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Immutable model representing a CFO/Planning retainer for an SME client.
class CfoRetainer {
  const CfoRetainer({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.industry,
    required this.monthlyFee,
    required this.startDate,
    required this.nextReviewDate,
    required this.deliverables,
    required this.status,
    required this.assignedPartner,
    required this.healthScore,
  }) : assert(
         healthScore >= 0 && healthScore <= 100,
         'healthScore must be between 0 and 100',
       );

  final String id;
  final String clientId;
  final String clientName;
  final String industry;

  /// Monthly retainer fee in INR.
  final double monthlyFee;

  final DateTime startDate;
  final DateTime nextReviewDate;

  /// List of deliverable titles committed in the retainer scope.
  final List<String> deliverables;

  final CfoRetainerStatus status;
  final String assignedPartner;

  /// Health score from 0 (at risk) to 100 (excellent).
  final int healthScore;

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  /// Annual retainer value in INR.
  double get annualValue => monthlyFee * 12;

  /// Monthly fee formatted as an Indian rupee string (e.g. ₹18,000).
  String get formattedFee {
    final amount = monthlyFee.toInt();
    if (amount >= 100000) {
      final lakhs = amount / 100000;
      return '₹${lakhs.toStringAsFixed(lakhs.truncateToDouble() == lakhs ? 0 : 1)}L/mo';
    }
    if (amount >= 1000) {
      final thousands = amount / 1000;
      return '₹${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}K/mo';
    }
    return '₹$amount/mo';
  }

  /// Whether the client is in a healthy engagement state (score > 70).
  bool get isHealthy => healthScore > 70;

  /// Days until the next review date (negative means overdue).
  int get nextReviewDaysLeft => nextReviewDate.difference(_today).inDays;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  CfoRetainer copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? industry,
    double? monthlyFee,
    DateTime? startDate,
    DateTime? nextReviewDate,
    List<String>? deliverables,
    CfoRetainerStatus? status,
    String? assignedPartner,
    int? healthScore,
  }) {
    return CfoRetainer(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      industry: industry ?? this.industry,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      startDate: startDate ?? this.startDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      deliverables: deliverables ?? this.deliverables,
      status: status ?? this.status,
      assignedPartner: assignedPartner ?? this.assignedPartner,
      healthScore: healthScore ?? this.healthScore,
    );
  }
}

/// Pinned reference date used for computed date properties.
final _today = DateTime(2026, 3, 11);
