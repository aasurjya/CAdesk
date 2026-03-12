/// Sections of the CGST Act under which RCM applies.
enum RcmSection {
  section9_3,
  section9_4,
  section9_5,
  none,
}

/// Immutable result of a reverse charge mechanism determination.
class RcmResult {
  const RcmResult({
    required this.isRcmApplicable,
    required this.rcmSection,
    this.serviceCategory,
    required this.reason,
    required this.selfInvoiceRequired,
  });

  /// Whether reverse charge mechanism is applicable.
  final bool isRcmApplicable;

  /// The CGST Act section under which RCM applies.
  final RcmSection rcmSection;

  /// Category of service (for Section 9(3) notified services).
  final String? serviceCategory;

  /// Human-readable reason for the determination.
  final String reason;

  /// Whether a self-invoice must be issued by the recipient.
  final bool selfInvoiceRequired;

  RcmResult copyWith({
    bool? isRcmApplicable,
    RcmSection? rcmSection,
    String? serviceCategory,
    String? reason,
    bool? selfInvoiceRequired,
  }) {
    return RcmResult(
      isRcmApplicable: isRcmApplicable ?? this.isRcmApplicable,
      rcmSection: rcmSection ?? this.rcmSection,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      reason: reason ?? this.reason,
      selfInvoiceRequired: selfInvoiceRequired ?? this.selfInvoiceRequired,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RcmResult &&
          runtimeType == other.runtimeType &&
          isRcmApplicable == other.isRcmApplicable &&
          rcmSection == other.rcmSection &&
          serviceCategory == other.serviceCategory &&
          reason == other.reason &&
          selfInvoiceRequired == other.selfInvoiceRequired;

  @override
  int get hashCode => Object.hash(
        isRcmApplicable,
        rcmSection,
        serviceCategory,
        reason,
        selfInvoiceRequired,
      );
}
