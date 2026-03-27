import 'package:flutter/material.dart';

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr2/itr2_form_data.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

/// Lifecycle status of a filing job managed by the CA.
enum FilingJobStatus {
  notStarted(
    label: 'Not Started',
    color: Color(0xFF9E9E9E),
    icon: Icons.hourglass_empty_rounded,
  ),
  documentsCollected(
    label: 'Docs Collected',
    color: Color(0xFF6A1B9A),
    icon: Icons.folder_open_rounded,
  ),
  draft(
    label: 'Draft',
    color: Color(0xFF757575),
    icon: Icons.edit_note_rounded,
  ),
  review(
    label: 'Under Review',
    color: Color(0xFF1565C0),
    icon: Icons.rate_review_rounded,
  ),
  ready(
    label: 'Ready to File',
    color: Color(0xFFD4890E),
    icon: Icons.task_alt_rounded,
  ),
  filed(
    label: 'Filed',
    color: Color(0xFF0D7C7C),
    icon: Icons.upload_file_rounded,
  ),
  verified(
    label: 'Verified',
    color: Color(0xFF1A7A3A),
    icon: Icons.verified_rounded,
  ),
  rejected(
    label: 'Rejected',
    color: Color(0xFFC62828),
    icon: Icons.cancel_rounded,
  );

  const FilingJobStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Type of filing submission.
enum FilingType {
  original('Original — s.139(1)'),
  revised('Revised — s.139(5)'),
  belated('Belated — s.139(4)'),
  updated('Updated (ITR-U) — s.139(8A)'),
  defective('Defective Response — s.139(9)');

  const FilingType(this.label);
  final String label;
}

/// Residential status of the assessee.
enum ResidentialStatus {
  resident('Resident (ROR)'),
  nri('Non-Resident (NRI)'),
  rnor('Resident but Not Ordinarily Resident (RNOR)');

  const ResidentialStatus(this.label);
  final String label;
}

/// Priority level for a filing job.
enum FilingPriority {
  low('Low', Color(0xFF43A047)),
  medium('Medium', Color(0xFFFFA000)),
  high('High', Color(0xFFE65100)),
  urgent('Urgent', Color(0xFFC62828));

  const FilingPriority(this.label, this.color);
  final String label;
  final Color color;
}

/// Immutable model representing a CA's ITR filing job for a client.
class FilingJob {
  const FilingJob({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.itrType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.mobile,
    this.email,
    this.filingType = FilingType.original,
    this.residentialStatus = ResidentialStatus.resident,
    this.taxRegime,
    this.dueDate,
    this.assignedTo,
    this.priority = FilingPriority.medium,
    this.remarks,
    this.feeQuoted,
    this.feeReceived,
    this.itr1Data,
    this.itr2Data,
    this.acknowledgementNumber,
    this.filingDate,
    this.eVerificationStatus,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String pan;
  final String? mobile;
  final String? email;
  final String assessmentYear;
  final ItrType itrType;
  final FilingType filingType;
  final ResidentialStatus residentialStatus;
  final TaxRegime? taxRegime;
  final FilingJobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? filingDate;
  final String? assignedTo;
  final FilingPriority priority;
  final String? remarks;
  final double? feeQuoted;
  final double? feeReceived;
  final Itr1FormData? itr1Data;
  final Itr2FormData? itr2Data;
  final String? acknowledgementNumber;
  final String? eVerificationStatus;

  FilingJob copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? pan,
    String? mobile,
    String? email,
    String? assessmentYear,
    ItrType? itrType,
    FilingType? filingType,
    ResidentialStatus? residentialStatus,
    TaxRegime? taxRegime,
    FilingJobStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? filingDate,
    String? assignedTo,
    FilingPriority? priority,
    String? remarks,
    double? feeQuoted,
    double? feeReceived,
    Itr1FormData? itr1Data,
    Itr2FormData? itr2Data,
    String? acknowledgementNumber,
    String? eVerificationStatus,
  }) {
    return FilingJob(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      pan: pan ?? this.pan,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      itrType: itrType ?? this.itrType,
      filingType: filingType ?? this.filingType,
      residentialStatus: residentialStatus ?? this.residentialStatus,
      taxRegime: taxRegime ?? this.taxRegime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      filingDate: filingDate ?? this.filingDate,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      remarks: remarks ?? this.remarks,
      feeQuoted: feeQuoted ?? this.feeQuoted,
      feeReceived: feeReceived ?? this.feeReceived,
      itr1Data: itr1Data ?? this.itr1Data,
      itr2Data: itr2Data ?? this.itr2Data,
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
      eVerificationStatus: eVerificationStatus ?? this.eVerificationStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingJob && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
