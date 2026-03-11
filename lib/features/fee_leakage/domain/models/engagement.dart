import 'package:flutter/material.dart';

enum EngagementStatus {
  onTrack('On Track', Color(0xFF1A7A3A), Icons.check_circle_rounded),
  overScope('Over Scope', Color(0xFFC62828), Icons.warning_rounded),
  underBilled('Under-Billed', Color(0xFFD4890E), Icons.monetization_on_rounded),
  disputed('Disputed', Color(0xFF718096), Icons.gavel_rounded);

  const EngagementStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

class Engagement {
  const Engagement({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.serviceType,
    required this.agreedFee,
    required this.billedAmount,
    required this.actualHours,
    required this.budgetHours,
    required this.status,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String serviceType;
  final double agreedFee;
  final double billedAmount;
  final double actualHours;
  final double budgetHours;
  final EngagementStatus status;

  double get leakageAmount => agreedFee - billedAmount;

  double get leakagePct =>
      agreedFee > 0 ? (leakageAmount / agreedFee) * 100 : 0.0;

  bool get isOverScope => actualHours > budgetHours;

  double get utilizationPct =>
      budgetHours > 0 ? (actualHours / budgetHours) * 100 : 0.0;

  String get formattedLeakage {
    final abs = leakageAmount.abs();
    final sign = leakageAmount >= 0 ? '' : '-';
    if (abs >= 100000) {
      return '$sign₹${(abs / 100000).toStringAsFixed(1)}L';
    } else if (abs >= 1000) {
      return '$sign₹${(abs / 1000).toStringAsFixed(1)}K';
    }
    return '$sign₹${abs.toStringAsFixed(0)}';
  }

  Engagement copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? serviceType,
    double? agreedFee,
    double? billedAmount,
    double? actualHours,
    double? budgetHours,
    EngagementStatus? status,
  }) {
    return Engagement(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      serviceType: serviceType ?? this.serviceType,
      agreedFee: agreedFee ?? this.agreedFee,
      billedAmount: billedAmount ?? this.billedAmount,
      actualHours: actualHours ?? this.actualHours,
      budgetHours: budgetHours ?? this.budgetHours,
      status: status ?? this.status,
    );
  }
}
