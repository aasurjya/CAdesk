import 'package:flutter/material.dart';

enum AppCategory {
  valuation('Valuation'),
  legal('Legal'),
  payroll('Payroll'),
  banking('Banking'),
  insurance('Insurance'),
  hr('HR');

  const AppCategory(this.label);
  final String label;
}

enum AppInstallStatus {
  installed('Installed', Color(0xFF1A7A3A)),
  available('Available', Color(0xFF1B3A5C)),
  pending('Pending Approval', Color(0xFFD4890E)),
  deprecated('Deprecated', Color(0xFF718096));

  const AppInstallStatus(this.label, this.color);
  final String label;
  final Color color;
}

class MarketplaceApp {
  const MarketplaceApp({
    required this.id,
    required this.name,
    required this.vendor,
    required this.category,
    required this.installStatus,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.isFree,
    this.pricePerMonth,
    this.installedAt,
    this.iconColor,
  });

  final String id;
  final String name;
  final String vendor;
  final AppCategory category;
  final AppInstallStatus installStatus;
  final String description;
  final double rating;
  final int reviewCount;
  final bool isFree;
  final double? pricePerMonth;
  final DateTime? installedAt;
  final Color? iconColor;
}
