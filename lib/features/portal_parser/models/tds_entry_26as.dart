import 'package:flutter/foundation.dart';

/// Booking status of a TDS entry as reported in Form 26AS.
enum BookingStatus {
  booked(label: 'Booked', code: 'F'),
  unmatched(label: 'Unmatched', code: 'U'),
  overBooked(label: 'Over-booked', code: 'O');

  const BookingStatus({required this.label, required this.code});

  final String label;
  final String code;

  /// Maps the single-character code from Form 26AS to a [BookingStatus].
  /// Returns [BookingStatus.unmatched] for unknown codes.
  static BookingStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'F':
        return BookingStatus.booked;
      case 'O':
        return BookingStatus.overBooked;
      default:
        return BookingStatus.unmatched;
    }
  }
}

/// Immutable model for a single TDS deductor entry in Form 26AS.
@immutable
class TdsEntry26As {
  const TdsEntry26As({
    required this.deductorTan,
    required this.deductorName,
    required this.section,
    required this.amount,
    required this.tdsDeducted,
    required this.dateOfDeduction,
    required this.status,
  });

  /// TAN of the deductor.
  final String deductorTan;

  /// Name of the deductor as reported in Form 26AS.
  final String deductorName;

  /// TDS section code (e.g. "192", "194C").
  final String section;

  /// Gross amount credited/paid, in paise.
  final int amount;

  /// TDS deducted by the deductor, in paise.
  final int tdsDeducted;

  /// Date on which TDS was deducted; null if not reported.
  final DateTime? dateOfDeduction;

  /// Booking status of the entry.
  final BookingStatus status;

  TdsEntry26As copyWith({
    String? deductorTan,
    String? deductorName,
    String? section,
    int? amount,
    int? tdsDeducted,
    DateTime? dateOfDeduction,
    BookingStatus? status,
  }) {
    return TdsEntry26As(
      deductorTan: deductorTan ?? this.deductorTan,
      deductorName: deductorName ?? this.deductorName,
      section: section ?? this.section,
      amount: amount ?? this.amount,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      dateOfDeduction: dateOfDeduction ?? this.dateOfDeduction,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsEntry26As &&
          runtimeType == other.runtimeType &&
          deductorTan == other.deductorTan &&
          section == other.section &&
          amount == other.amount &&
          tdsDeducted == other.tdsDeducted &&
          dateOfDeduction == other.dateOfDeduction &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(deductorTan, section, amount, tdsDeducted, dateOfDeduction, status);

  @override
  String toString() =>
      'TdsEntry26As(tan: $deductorTan, section: $section, '
      'tdsDeducted: $tdsDeducted, status: ${status.label})';
}

/// Immutable model for a TCS entry in Form 26AS (Part B).
@immutable
class TcsEntry26As {
  const TcsEntry26As({
    required this.collectorTan,
    required this.collectorName,
    required this.section,
    required this.amount,
    required this.tcsCollected,
    required this.dateOfCollection,
    required this.status,
  });

  final String collectorTan;
  final String collectorName;
  final String section;
  final int amount;
  final int tcsCollected;
  final DateTime? dateOfCollection;
  final BookingStatus status;

  TcsEntry26As copyWith({
    String? collectorTan,
    String? collectorName,
    String? section,
    int? amount,
    int? tcsCollected,
    DateTime? dateOfCollection,
    BookingStatus? status,
  }) {
    return TcsEntry26As(
      collectorTan: collectorTan ?? this.collectorTan,
      collectorName: collectorName ?? this.collectorName,
      section: section ?? this.section,
      amount: amount ?? this.amount,
      tcsCollected: tcsCollected ?? this.tcsCollected,
      dateOfCollection: dateOfCollection ?? this.dateOfCollection,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TcsEntry26As &&
          runtimeType == other.runtimeType &&
          collectorTan == other.collectorTan &&
          section == other.section &&
          amount == other.amount &&
          tcsCollected == other.tcsCollected;

  @override
  int get hashCode => Object.hash(collectorTan, section, amount, tcsCollected);
}

/// Immutable model for an advance tax / self-assessment payment entry.
@immutable
class TaxPaymentEntry26As {
  const TaxPaymentEntry26As({
    required this.bsrCode,
    required this.challanSerialNumber,
    required this.dateOfDeposit,
    required this.amountPaid,
  });

  final String bsrCode;
  final String challanSerialNumber;
  final DateTime? dateOfDeposit;
  final int amountPaid;

  TaxPaymentEntry26As copyWith({
    String? bsrCode,
    String? challanSerialNumber,
    DateTime? dateOfDeposit,
    int? amountPaid,
  }) {
    return TaxPaymentEntry26As(
      bsrCode: bsrCode ?? this.bsrCode,
      challanSerialNumber: challanSerialNumber ?? this.challanSerialNumber,
      dateOfDeposit: dateOfDeposit ?? this.dateOfDeposit,
      amountPaid: amountPaid ?? this.amountPaid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxPaymentEntry26As &&
          runtimeType == other.runtimeType &&
          bsrCode == other.bsrCode &&
          challanSerialNumber == other.challanSerialNumber &&
          amountPaid == other.amountPaid;

  @override
  int get hashCode => Object.hash(bsrCode, challanSerialNumber, amountPaid);
}

/// Immutable model for a refund entry in Form 26AS (Part D).
@immutable
class RefundEntry26As {
  const RefundEntry26As({
    required this.assessmentYear,
    required this.mode,
    required this.amount,
    required this.dateOfPayment,
  });

  final String assessmentYear;
  final String mode;
  final int amount;
  final DateTime? dateOfPayment;

  RefundEntry26As copyWith({
    String? assessmentYear,
    String? mode,
    int? amount,
    DateTime? dateOfPayment,
  }) {
    return RefundEntry26As(
      assessmentYear: assessmentYear ?? this.assessmentYear,
      mode: mode ?? this.mode,
      amount: amount ?? this.amount,
      dateOfPayment: dateOfPayment ?? this.dateOfPayment,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefundEntry26As &&
          runtimeType == other.runtimeType &&
          assessmentYear == other.assessmentYear &&
          mode == other.mode &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(assessmentYear, mode, amount);
}
