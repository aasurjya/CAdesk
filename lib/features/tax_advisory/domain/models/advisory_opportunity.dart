import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum OpportunityType {
  regimeOptimisation(
    'Regime Optimisation',
    Icons.swap_horiz_rounded,
    AppColors.primary,
  ),
  capitalGainsHarvesting(
    'Capital Gains Harvesting',
    Icons.trending_up_rounded,
    AppColors.success,
  ),
  missingDeductions(
    'Missing Deductions',
    Icons.find_in_page_rounded,
    AppColors.warning,
  ),
  advanceTaxPlanning(
    'Advance Tax Planning',
    Icons.calendar_month_rounded,
    AppColors.secondary,
  ),
  gstOptimisation(
    'GST Optimisation',
    Icons.receipt_long_rounded,
    AppColors.accent,
  ),
  tdsPlanning('TDS Planning', Icons.account_balance_rounded, AppColors.primary),
  retainerUpsell('Retainer Upsell', Icons.handshake_rounded, AppColors.success),
  nriCompliance('NRI Compliance', Icons.flight_rounded, AppColors.secondary),
  startupIncentive(
    'Startup Incentive',
    Icons.rocket_launch_rounded,
    AppColors.accent,
  ),
  corporateRestructuring(
    'Corporate Restructuring',
    Icons.corporate_fare_rounded,
    AppColors.error,
  );

  const OpportunityType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

enum OpportunityPriority {
  high('High', AppColors.error),
  medium('Medium', AppColors.warning),
  low('Low', AppColors.neutral400);

  const OpportunityPriority(this.label, this.color);

  final String label;
  final Color color;
}

enum OpportunityStatus {
  new_('New'),
  reviewed('Reviewed'),
  proposalSent('Proposal Sent'),
  converted('Converted'),
  dismissed('Dismissed');

  const OpportunityStatus(this.label);

  final String label;
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Immutable model representing a detected tax advisory opportunity for a client.
class AdvisoryOpportunity {
  const AdvisoryOpportunity({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.opportunityType,
    required this.title,
    required this.description,
    required this.estimatedFee,
    required this.priority,
    required this.status,
    required this.detectedAt,
    required this.signals,
  });

  final String id;
  final String clientId;
  final String clientName;
  final OpportunityType opportunityType;
  final String title;
  final String description;
  final double estimatedFee;
  final OpportunityPriority priority;
  final OpportunityStatus status;
  final DateTime detectedAt;
  final List<String> signals;

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  /// Fee formatted as Indian currency string (e.g. "₹85,000").
  String get formattedFee {
    if (estimatedFee >= 100000) {
      final lakhs = estimatedFee / 100000;
      final formatted = lakhs == lakhs.truncateToDouble()
          ? '${lakhs.toInt()}L'
          : '${lakhs.toStringAsFixed(1)}L';
      return '₹$formatted';
    }
    if (estimatedFee >= 1000) {
      final thousands = estimatedFee / 1000;
      final formatted = thousands == thousands.truncateToDouble()
          ? '${thousands.toInt()}K'
          : '${thousands.toStringAsFixed(1)}K';
      return '₹$formatted';
    }
    return '₹${estimatedFee.toInt()}';
  }

  /// Human-readable relative time since detection.
  String get timeAgo {
    final now = DateTime(2026, 3, 11);
    final diff = now.difference(detectedAt);
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  AdvisoryOpportunity copyWith({
    String? id,
    String? clientId,
    String? clientName,
    OpportunityType? opportunityType,
    String? title,
    String? description,
    double? estimatedFee,
    OpportunityPriority? priority,
    OpportunityStatus? status,
    DateTime? detectedAt,
    List<String>? signals,
  }) {
    return AdvisoryOpportunity(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      opportunityType: opportunityType ?? this.opportunityType,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      detectedAt: detectedAt ?? this.detectedAt,
      signals: signals ?? this.signals,
    );
  }
}
