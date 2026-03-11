import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum CampaignType {
  itrSeason('ITR Season', Icons.receipt_long_rounded),
  gstAnnual('GST Annual', Icons.account_balance_rounded),
  advanceTax('Advance Tax', Icons.payments_rounded),
  newBusiness('New Business', Icons.add_business_rounded),
  dormantReactivation('Dormant Reactivation', Icons.refresh_rounded),
  referralDrive('Referral Drive', Icons.share_rounded);

  const CampaignType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum CampaignStatus {
  planning('Planning', Color(0xFF718096)),
  active('Active', Color(0xFF1A7A3A)),
  paused('Paused', Color(0xFFD4890E)),
  completed('Completed', Color(0xFF1B3A5C));

  const CampaignStatus(this.label, this.color);
  final String label;
  final Color color;
}

class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.leadsGenerated,
    required this.conversions,
    required this.targetService,
  });

  final String id;
  final String title;
  final CampaignType type;
  final CampaignStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int leadsGenerated;
  final int conversions;
  final String targetService;

  /// Conversion rate: conversions / leadsGenerated (0.0 if no leads).
  double get roi => leadsGenerated == 0 ? 0.0 : conversions / leadsGenerated;

  /// Budget formatted as ₹X.XL or ₹X,XXX.
  String get formattedBudget {
    if (budget >= 100000) {
      final lakhs = budget / 100000;
      return '₹${lakhs.toStringAsFixed(1)}L';
    }
    final formatter = NumberFormat('#,##0', 'en_IN');
    return '₹${formatter.format(budget.toInt())}';
  }

  /// Whether the campaign is currently running.
  bool get isActive => status == CampaignStatus.active;

  Campaign copyWith({
    String? id,
    String? title,
    CampaignType? type,
    CampaignStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    int? leadsGenerated,
    int? conversions,
    String? targetService,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      leadsGenerated: leadsGenerated ?? this.leadsGenerated,
      conversions: conversions ?? this.conversions,
      targetService: targetService ?? this.targetService,
    );
  }
}
