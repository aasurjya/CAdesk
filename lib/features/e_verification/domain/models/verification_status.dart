import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Status of an ITR e-verification request.
enum VerificationStatus {
  pending(label: 'Pending', color: AppColors.warning),
  verifiedEvc(label: 'Verified (EVC)', color: AppColors.success),
  verifiedAadhaar(label: 'Verified (Aadhaar)', color: AppColors.success),
  verifiedDsc(label: 'Verified (DSC)', color: AppColors.success),
  expired(label: 'Expired', color: AppColors.error);

  const VerificationStatus({required this.label, required this.color});

  final String label;
  final Color color;

  bool get isVerified =>
      this == verifiedEvc || this == verifiedAadhaar || this == verifiedDsc;
}
