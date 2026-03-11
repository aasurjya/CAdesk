import 'package:flutter/material.dart';

enum SecurityControlCategory {
  soc2('SOC 2 Type II'),
  iso27001('ISO 27001'),
  vapt('VAPT'),
  rbiCyber('RBI Cyber Security'),
  dataResidency('Data Residency'),
  privacy('Privacy & Consent');

  const SecurityControlCategory(this.label);
  final String label;
}

enum SecurityControlStatus {
  compliant('Compliant', Color(0xFF1A7A3A)),
  nonCompliant('Non-Compliant', Color(0xFFC62828)),
  inReview('In Review', Color(0xFFD4890E)),
  scheduled('Scheduled', Color(0xFF1B3A5C));

  const SecurityControlStatus(this.label, this.color);
  final String label;
  final Color color;
}

enum ControlSeverity {
  critical('Critical', Color(0xFFC62828)),
  high('High', Color(0xFFD4890E)),
  medium('Medium', Color(0xFF0D7C7C)),
  low('Low', Color(0xFF718096));

  const ControlSeverity(this.label, this.color);
  final String label;
  final Color color;
}

class SecurityControl {
  const SecurityControl({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.severity,
    required this.lastAssessmentDate,
    required this.nextDueDate,
    this.owner,
    this.notes,
  });

  final String id;
  final String title;
  final SecurityControlCategory category;
  final SecurityControlStatus status;
  final ControlSeverity severity;
  final DateTime lastAssessmentDate;
  final DateTime nextDueDate;
  final String? owner;
  final String? notes;
}
