import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

enum RetainerStatus {
  active('Active', AppColors.success),
  expiringSoon('Expiring Soon', AppColors.warning),
  expired('Expired', AppColors.error),
  paused('Paused', AppColors.neutral400);

  const RetainerStatus(this.label, this.color);
  final String label;
  final Color color;
}

class RetainerContract {
  const RetainerContract({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.serviceScope,
    required this.monthlyFee,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
    required this.status,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String serviceScope;
  final double monthlyFee;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final RetainerStatus status;

  /// Today's reference date.
  static final _today = DateTime(2026, 3, 11);

  int get daysToExpiry => endDate.difference(_today).inDays;

  bool get isExpiringSoon {
    if (_today.isAfter(endDate)) return false;
    return daysToExpiry < 60;
  }

  double get annualValue => monthlyFee * 12;

  String get formattedMonthlyFee => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(monthlyFee);

  String get formattedAnnualValue => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(annualValue);

  RetainerContract copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? serviceScope,
    double? monthlyFee,
    DateTime? startDate,
    DateTime? endDate,
    bool? autoRenew,
    RetainerStatus? status,
  }) {
    return RetainerContract(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      serviceScope: serviceScope ?? this.serviceScope,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      autoRenew: autoRenew ?? this.autoRenew,
      status: status ?? this.status,
    );
  }
}
