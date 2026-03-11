import 'package:flutter/material.dart';

enum VaptScanStatus {
  scheduled('Scheduled', Color(0xFF1B3A5C)),
  inProgress('In Progress', Color(0xFFD4890E)),
  completed('Completed', Color(0xFF1A7A3A)),
  remediation('Remediation', Color(0xFFC62828));

  const VaptScanStatus(this.label, this.color);
  final String label;
  final Color color;
}

class VaptScan {
  const VaptScan({
    required this.id,
    required this.title,
    required this.scanDate,
    required this.status,
    required this.criticalFindings,
    required this.highFindings,
    required this.mediumFindings,
    required this.lowFindings,
    this.remediationDeadline,
    this.vendor,
    this.scope,
  });

  final String id;
  final String title;
  final DateTime scanDate;
  final VaptScanStatus status;
  final int criticalFindings;
  final int highFindings;
  final int mediumFindings;
  final int lowFindings;
  final DateTime? remediationDeadline;
  final String? vendor;
  final String? scope;

  int get totalFindings =>
      criticalFindings + highFindings + mediumFindings + lowFindings;
}
