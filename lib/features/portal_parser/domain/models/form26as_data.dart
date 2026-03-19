import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Booking status of a TDS entry in Form 26AS.
enum Form26AsBookingStatus {
  booked(label: 'Booked', code: 'F'),
  unmatched(label: 'Unmatched', code: 'U'),
  overBooked(label: 'Over-booked', code: 'O');

  const Form26AsBookingStatus({required this.label, required this.code});

  final String label;
  final String code;

  /// Maps a single-character portal code to a [Form26AsBookingStatus].
  static Form26AsBookingStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'F':
        return Form26AsBookingStatus.booked;
      case 'O':
        return Form26AsBookingStatus.overBooked;
      default:
        return Form26AsBookingStatus.unmatched;
    }
  }
}

/// Category of a high-value transaction in SFT (Part E of Form 26AS).
enum SftCategory {
  cashDeposit(label: 'Cash Deposit'),
  fixedDeposit(label: 'Fixed Deposit'),
  propertyPurchase(label: 'Property Purchase'),
  propertySale(label: 'Property Sale'),
  shareTransaction(label: 'Share Transaction'),
  mutualFund(label: 'Mutual Fund'),
  foreignRemittance(label: 'Foreign Remittance'),
  other(label: 'Other');

  const SftCategory({required this.label});

  final String label;

  /// Maps a portal string to an [SftCategory].
  static SftCategory fromString(String value) {
    final upper = value.toUpperCase().trim();
    if (upper.contains('CASH')) return SftCategory.cashDeposit;
    if (upper.contains('FIXED') || upper.contains('FD')) {
      return SftCategory.fixedDeposit;
    }
    if (upper.contains('PROPERTY') && upper.contains('PURCHASE')) {
      return SftCategory.propertyPurchase;
    }
    if (upper.contains('PROPERTY') && upper.contains('SALE')) {
      return SftCategory.propertySale;
    }
    if (upper.contains('SHARE')) return SftCategory.shareTransaction;
    if (upper.contains('MUTUAL')) return SftCategory.mutualFund;
    if (upper.contains('FOREIGN') || upper.contains('REMITTANCE')) {
      return SftCategory.foreignRemittance;
    }
    return SftCategory.other;
  }
}

// ---------------------------------------------------------------------------
// Entry models
// ---------------------------------------------------------------------------

/// A single TDS entry (Part A) in the parsed Form 26AS.
@immutable
class Form26AsTdsEntry {
  const Form26AsTdsEntry({
    required this.deductorTan,
    required this.deductorName,
    required this.section,
    required this.amountPaidPaise,
    required this.taxDeductedPaise,
    required this.taxDepositedPaise,
    required this.depositDate,
    required this.bookingStatus,
  });

  final String deductorTan;
  final String deductorName;

  /// TDS section (e.g. "192", "194C").
  final String section;

  /// Gross amount paid/credited in paise.
  final int amountPaidPaise;

  /// Tax deducted in paise.
  final int taxDeductedPaise;

  /// Tax deposited with government in paise.
  final int taxDepositedPaise;

  /// Date the tax was deposited; null if not reported.
  final DateTime? depositDate;

  final Form26AsBookingStatus bookingStatus;

  Form26AsTdsEntry copyWith({
    String? deductorTan,
    String? deductorName,
    String? section,
    int? amountPaidPaise,
    int? taxDeductedPaise,
    int? taxDepositedPaise,
    DateTime? depositDate,
    Form26AsBookingStatus? bookingStatus,
  }) {
    return Form26AsTdsEntry(
      deductorTan: deductorTan ?? this.deductorTan,
      deductorName: deductorName ?? this.deductorName,
      section: section ?? this.section,
      amountPaidPaise: amountPaidPaise ?? this.amountPaidPaise,
      taxDeductedPaise: taxDeductedPaise ?? this.taxDeductedPaise,
      taxDepositedPaise: taxDepositedPaise ?? this.taxDepositedPaise,
      depositDate: depositDate ?? this.depositDate,
      bookingStatus: bookingStatus ?? this.bookingStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26AsTdsEntry &&
          runtimeType == other.runtimeType &&
          deductorTan == other.deductorTan &&
          section == other.section &&
          taxDeductedPaise == other.taxDeductedPaise;

  @override
  int get hashCode => Object.hash(deductorTan, section, taxDeductedPaise);
}

/// A single TCS entry (Part B) in the parsed Form 26AS.
@immutable
class Form26AsTcsEntry {
  const Form26AsTcsEntry({
    required this.collectorTan,
    required this.collectorName,
    required this.section,
    required this.amountPaidPaise,
    required this.taxCollectedPaise,
    required this.taxDepositedPaise,
    required this.depositDate,
    required this.bookingStatus,
  });

  final String collectorTan;
  final String collectorName;
  final String section;
  final int amountPaidPaise;
  final int taxCollectedPaise;
  final int taxDepositedPaise;
  final DateTime? depositDate;
  final Form26AsBookingStatus bookingStatus;

  Form26AsTcsEntry copyWith({
    String? collectorTan,
    String? collectorName,
    String? section,
    int? amountPaidPaise,
    int? taxCollectedPaise,
    int? taxDepositedPaise,
    DateTime? depositDate,
    Form26AsBookingStatus? bookingStatus,
  }) {
    return Form26AsTcsEntry(
      collectorTan: collectorTan ?? this.collectorTan,
      collectorName: collectorName ?? this.collectorName,
      section: section ?? this.section,
      amountPaidPaise: amountPaidPaise ?? this.amountPaidPaise,
      taxCollectedPaise: taxCollectedPaise ?? this.taxCollectedPaise,
      taxDepositedPaise: taxDepositedPaise ?? this.taxDepositedPaise,
      depositDate: depositDate ?? this.depositDate,
      bookingStatus: bookingStatus ?? this.bookingStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26AsTcsEntry &&
          runtimeType == other.runtimeType &&
          collectorTan == other.collectorTan &&
          section == other.section &&
          taxCollectedPaise == other.taxCollectedPaise;

  @override
  int get hashCode => Object.hash(collectorTan, section, taxCollectedPaise);
}

/// An advance tax or self-assessment payment entry (Part C).
@immutable
class Form26AsTaxPayment {
  const Form26AsTaxPayment({
    required this.bsrCode,
    required this.challanSerial,
    required this.depositDate,
    required this.amountPaise,
    required this.challanType,
  });

  final String bsrCode;
  final String challanSerial;
  final DateTime? depositDate;

  /// Amount deposited in paise.
  final int amountPaise;

  /// "ADVANCE" or "SELF_ASSESSMENT".
  final String challanType;

  Form26AsTaxPayment copyWith({
    String? bsrCode,
    String? challanSerial,
    DateTime? depositDate,
    int? amountPaise,
    String? challanType,
  }) {
    return Form26AsTaxPayment(
      bsrCode: bsrCode ?? this.bsrCode,
      challanSerial: challanSerial ?? this.challanSerial,
      depositDate: depositDate ?? this.depositDate,
      amountPaise: amountPaise ?? this.amountPaise,
      challanType: challanType ?? this.challanType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26AsTaxPayment &&
          runtimeType == other.runtimeType &&
          bsrCode == other.bsrCode &&
          challanSerial == other.challanSerial &&
          amountPaise == other.amountPaise;

  @override
  int get hashCode => Object.hash(bsrCode, challanSerial, amountPaise);
}

/// A refund entry (Part D) in Form 26AS.
@immutable
class Form26AsRefundEntry {
  const Form26AsRefundEntry({
    required this.assessmentYear,
    required this.amountPaise,
    required this.mode,
    required this.paymentDate,
  });

  final String assessmentYear;
  final int amountPaise;

  /// e.g. "ECS", "NEFT", "Cheque".
  final String mode;
  final DateTime? paymentDate;

  Form26AsRefundEntry copyWith({
    String? assessmentYear,
    int? amountPaise,
    String? mode,
    DateTime? paymentDate,
  }) {
    return Form26AsRefundEntry(
      assessmentYear: assessmentYear ?? this.assessmentYear,
      amountPaise: amountPaise ?? this.amountPaise,
      mode: mode ?? this.mode,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26AsRefundEntry &&
          runtimeType == other.runtimeType &&
          assessmentYear == other.assessmentYear &&
          amountPaise == other.amountPaise;

  @override
  int get hashCode => Object.hash(assessmentYear, amountPaise);
}

/// A high-value transaction (SFT, Part E) in Form 26AS.
@immutable
class Form26AsSftEntry {
  const Form26AsSftEntry({
    required this.reportingEntity,
    required this.reportingEntityPan,
    required this.category,
    required this.amountPaise,
    required this.transactionDate,
    required this.description,
  });

  final String reportingEntity;
  final String reportingEntityPan;
  final SftCategory category;
  final int amountPaise;
  final DateTime? transactionDate;
  final String description;

  Form26AsSftEntry copyWith({
    String? reportingEntity,
    String? reportingEntityPan,
    SftCategory? category,
    int? amountPaise,
    DateTime? transactionDate,
    String? description,
  }) {
    return Form26AsSftEntry(
      reportingEntity: reportingEntity ?? this.reportingEntity,
      reportingEntityPan: reportingEntityPan ?? this.reportingEntityPan,
      category: category ?? this.category,
      amountPaise: amountPaise ?? this.amountPaise,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26AsSftEntry &&
          runtimeType == other.runtimeType &&
          reportingEntityPan == other.reportingEntityPan &&
          category == other.category &&
          amountPaise == other.amountPaise;

  @override
  int get hashCode => Object.hash(reportingEntityPan, category, amountPaise);
}

// ---------------------------------------------------------------------------
// Aggregate model
// ---------------------------------------------------------------------------

/// Immutable structured output from parsing a full Form 26AS.
///
/// All monetary amounts are in **paise** (1 rupee = 100 paise).
@immutable
class Form26AsParserData {
  const Form26AsParserData({
    required this.pan,
    required this.assessmentYear,
    required this.tdsEntries,
    required this.tcsEntries,
    required this.advanceTaxPayments,
    required this.selfAssessmentPayments,
    required this.refundEntries,
    required this.sftEntries,
  });

  /// 10-character PAN.
  final String pan;

  /// Assessment year in "YYYY-YY" format (e.g. "2025-26").
  final String assessmentYear;

  /// Part A: TDS entries (employer, bank, other deductors).
  final List<Form26AsTdsEntry> tdsEntries;

  /// Part B: TCS entries.
  final List<Form26AsTcsEntry> tcsEntries;

  /// Part C: advance tax payments.
  final List<Form26AsTaxPayment> advanceTaxPayments;

  /// Part C: self-assessment tax payments.
  final List<Form26AsTaxPayment> selfAssessmentPayments;

  /// Part D: refund entries.
  final List<Form26AsRefundEntry> refundEntries;

  /// Part E: SFT (high-value transaction) entries.
  final List<Form26AsSftEntry> sftEntries;

  // -- Derived computations --

  /// Total TDS credited across all Part A entries.
  int get totalTdsPaise =>
      tdsEntries.fold(0, (sum, e) => sum + e.taxDeductedPaise);

  /// Total TCS credited across all Part B entries.
  int get totalTcsPaise =>
      tcsEntries.fold(0, (sum, e) => sum + e.taxCollectedPaise);

  /// Total advance tax paid (Part C).
  int get totalAdvanceTaxPaise =>
      advanceTaxPayments.fold(0, (sum, e) => sum + e.amountPaise);

  /// Total self-assessment tax paid (Part C).
  int get totalSelfAssessmentPaise =>
      selfAssessmentPayments.fold(0, (sum, e) => sum + e.amountPaise);

  /// Total refund received (Part D).
  int get totalRefundPaise =>
      refundEntries.fold(0, (sum, e) => sum + e.amountPaise);

  Form26AsParserData copyWith({
    String? pan,
    String? assessmentYear,
    List<Form26AsTdsEntry>? tdsEntries,
    List<Form26AsTcsEntry>? tcsEntries,
    List<Form26AsTaxPayment>? advanceTaxPayments,
    List<Form26AsTaxPayment>? selfAssessmentPayments,
    List<Form26AsRefundEntry>? refundEntries,
    List<Form26AsSftEntry>? sftEntries,
  }) {
    return Form26AsParserData(
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      tdsEntries: tdsEntries ?? this.tdsEntries,
      tcsEntries: tcsEntries ?? this.tcsEntries,
      advanceTaxPayments: advanceTaxPayments ?? this.advanceTaxPayments,
      selfAssessmentPayments:
          selfAssessmentPayments ?? this.selfAssessmentPayments,
      refundEntries: refundEntries ?? this.refundEntries,
      sftEntries: sftEntries ?? this.sftEntries,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form26AsParserData &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          assessmentYear == other.assessmentYear;

  @override
  int get hashCode => Object.hash(pan, assessmentYear);

  @override
  String toString() =>
      'Form26AsParserData(pan: $pan, ay: $assessmentYear, '
      'tds: ${tdsEntries.length}, tcs: ${tcsEntries.length}, '
      'sft: ${sftEntries.length})';
}
