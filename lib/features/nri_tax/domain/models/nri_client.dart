import 'package:flutter/material.dart';

enum ResidentialStatus {
  resident('Resident', Color(0xFF1A7A3A)),
  nri('NRI', Color(0xFF1B3A5C)),
  rnor('RNOR', Color(0xFFD4890E));

  const ResidentialStatus(this.label, this.color);
  final String label;
  final Color color;
}

enum NriClientStatus {
  active('Active', Color(0xFF1A7A3A), Icons.check_circle_rounded),
  pendingDocuments(
    'Pending Docs',
    Color(0xFFD4890E),
    Icons.pending_actions_rounded,
  ),
  filingDue('Filing Due', Color(0xFFC62828), Icons.assignment_late_rounded),
  completed('Completed', Color(0xFF718096), Icons.task_alt_rounded);

  const NriClientStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class NriClient {
  const NriClient({
    required this.id,
    required this.name,
    required this.pan,
    required this.residentialStatus,
    required this.countryOfResidence,
    required this.stayDaysIndia,
    required this.foreignIncome,
    required this.indianIncome,
    required this.dtaaApplicable,
    required this.status,
  });

  final String id;
  final String name;
  final String pan;
  final ResidentialStatus residentialStatus;
  final String countryOfResidence;
  final int stayDaysIndia;
  final double foreignIncome;
  final double indianIncome;
  final bool dtaaApplicable;
  final NriClientStatus status;

  double get totalIncome => foreignIncome + indianIncome;
  bool get requiresDtaa => dtaaApplicable && foreignIncome > 0;

  String get formattedForeignIncome => _formatInr(foreignIncome);
  String get formattedIndianIncome => _formatInr(indianIncome);

  static String _formatInr(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  NriClient copyWith({
    String? id,
    String? name,
    String? pan,
    ResidentialStatus? residentialStatus,
    String? countryOfResidence,
    int? stayDaysIndia,
    double? foreignIncome,
    double? indianIncome,
    bool? dtaaApplicable,
    NriClientStatus? status,
  }) {
    return NriClient(
      id: id ?? this.id,
      name: name ?? this.name,
      pan: pan ?? this.pan,
      residentialStatus: residentialStatus ?? this.residentialStatus,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      stayDaysIndia: stayDaysIndia ?? this.stayDaysIndia,
      foreignIncome: foreignIncome ?? this.foreignIncome,
      indianIncome: indianIncome ?? this.indianIncome,
      dtaaApplicable: dtaaApplicable ?? this.dtaaApplicable,
      status: status ?? this.status,
    );
  }
}
