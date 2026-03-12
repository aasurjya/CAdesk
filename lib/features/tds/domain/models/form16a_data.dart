import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';
import 'package:flutter/foundation.dart';

/// A single transaction within a Form 16A certificate.
@immutable
class Form16ATransaction {
  const Form16ATransaction({
    required this.dateOfPayment,
    required this.dateOfDeduction,
    required this.amountPaid,
    required this.tdsDeducted,
    required this.tdsDeposited,
    this.challanNumber,
    this.bsrCode,
    this.dateOfDeposit,
  });

  final DateTime dateOfPayment;
  final DateTime dateOfDeduction;
  final double amountPaid;
  final double tdsDeducted;
  final double tdsDeposited;
  final String? challanNumber;
  final String? bsrCode;
  final DateTime? dateOfDeposit;

  Form16ATransaction copyWith({
    DateTime? dateOfPayment,
    DateTime? dateOfDeduction,
    double? amountPaid,
    double? tdsDeducted,
    double? tdsDeposited,
    String? challanNumber,
    String? bsrCode,
    DateTime? dateOfDeposit,
  }) {
    return Form16ATransaction(
      dateOfPayment: dateOfPayment ?? this.dateOfPayment,
      dateOfDeduction: dateOfDeduction ?? this.dateOfDeduction,
      amountPaid: amountPaid ?? this.amountPaid,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      tdsDeposited: tdsDeposited ?? this.tdsDeposited,
      challanNumber: challanNumber ?? this.challanNumber,
      bsrCode: bsrCode ?? this.bsrCode,
      dateOfDeposit: dateOfDeposit ?? this.dateOfDeposit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16ATransaction &&
          runtimeType == other.runtimeType &&
          dateOfPayment == other.dateOfPayment &&
          dateOfDeduction == other.dateOfDeduction &&
          amountPaid == other.amountPaid &&
          tdsDeducted == other.tdsDeducted &&
          tdsDeposited == other.tdsDeposited &&
          challanNumber == other.challanNumber &&
          bsrCode == other.bsrCode &&
          dateOfDeposit == other.dateOfDeposit;

  @override
  int get hashCode => Object.hash(
    dateOfPayment,
    dateOfDeduction,
    amountPaid,
    tdsDeducted,
    tdsDeposited,
    challanNumber,
    bsrCode,
    dateOfDeposit,
  );

  @override
  String toString() =>
      'Form16ATransaction(paid: $amountPaid, '
      'deducted: $tdsDeducted, deposited: $tdsDeposited)';
}

/// Form 16A — TDS certificate for non-salary income.
@immutable
class Form16AData {
  const Form16AData({
    required this.certificateNumber,
    required this.deductorTan,
    required this.deductorPan,
    required this.deductorName,
    required this.deductorAddress,
    required this.deducteePan,
    required this.deducteeName,
    required this.deducteeAddress,
    required this.assessmentYear,
    required this.quarter,
    required this.section,
    required this.transactions,
  });

  final String certificateNumber;
  final String deductorTan;
  final String deductorPan;
  final String deductorName;
  final TdsAddress deductorAddress;
  final String deducteePan;
  final String deducteeName;
  final TdsAddress deducteeAddress;
  final String assessmentYear;
  final TdsQuarter quarter;
  final String section;
  final List<Form16ATransaction> transactions;

  double get totalAmountPaid =>
      transactions.fold(0.0, (sum, t) => sum + t.amountPaid);

  double get totalTdsDeducted =>
      transactions.fold(0.0, (sum, t) => sum + t.tdsDeducted);

  double get totalTdsDeposited =>
      transactions.fold(0.0, (sum, t) => sum + t.tdsDeposited);

  Form16AData copyWith({
    String? certificateNumber,
    String? deductorTan,
    String? deductorPan,
    String? deductorName,
    TdsAddress? deductorAddress,
    String? deducteePan,
    String? deducteeName,
    TdsAddress? deducteeAddress,
    String? assessmentYear,
    TdsQuarter? quarter,
    String? section,
    List<Form16ATransaction>? transactions,
  }) {
    return Form16AData(
      certificateNumber: certificateNumber ?? this.certificateNumber,
      deductorTan: deductorTan ?? this.deductorTan,
      deductorPan: deductorPan ?? this.deductorPan,
      deductorName: deductorName ?? this.deductorName,
      deductorAddress: deductorAddress ?? this.deductorAddress,
      deducteePan: deducteePan ?? this.deducteePan,
      deducteeName: deducteeName ?? this.deducteeName,
      deducteeAddress: deducteeAddress ?? this.deducteeAddress,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      quarter: quarter ?? this.quarter,
      section: section ?? this.section,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16AData &&
          runtimeType == other.runtimeType &&
          certificateNumber == other.certificateNumber;

  @override
  int get hashCode => certificateNumber.hashCode;

  @override
  String toString() =>
      'Form16AData(cert: $certificateNumber, '
      'section: $section, deductee: $deducteeName)';
}
