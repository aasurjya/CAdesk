import 'package:flutter/foundation.dart';

/// Immutable model for a single advance tax installment.
///
/// Advance tax is payable in four installments during the financial year
/// as per Section 211 of the Income Tax Act.
class AdvanceTaxInstallment {
  const AdvanceTaxInstallment({
    required this.quarterLabel,
    required this.dueDate,
    required this.cumulativePercent,
    required this.amountDue,
    required this.amountPaid,
    this.challanNumber,
  });

  /// Label for the installment quarter (e.g. 'Q1 — 15 Jun').
  final String quarterLabel;

  /// Due date for this installment.
  final DateTime dueDate;

  /// Cumulative percentage of estimated tax due by this date.
  final int cumulativePercent;

  /// Amount due for this installment.
  final double amountDue;

  /// Amount actually paid for this installment.
  final double amountPaid;

  /// Challan number if payment has been made.
  final String? challanNumber;

  /// Shortfall amount (negative means excess paid).
  double get shortfall => amountDue - amountPaid;

  /// Whether this installment has been fully paid.
  bool get isPaid => amountPaid >= amountDue;

  AdvanceTaxInstallment copyWith({
    String? quarterLabel,
    DateTime? dueDate,
    int? cumulativePercent,
    double? amountDue,
    double? amountPaid,
    String? challanNumber,
  }) {
    return AdvanceTaxInstallment(
      quarterLabel: quarterLabel ?? this.quarterLabel,
      dueDate: dueDate ?? this.dueDate,
      cumulativePercent: cumulativePercent ?? this.cumulativePercent,
      amountDue: amountDue ?? this.amountDue,
      amountPaid: amountPaid ?? this.amountPaid,
      challanNumber: challanNumber ?? this.challanNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdvanceTaxInstallment &&
        other.quarterLabel == quarterLabel &&
        other.dueDate == dueDate &&
        other.cumulativePercent == cumulativePercent &&
        other.amountDue == amountDue &&
        other.amountPaid == amountPaid &&
        other.challanNumber == challanNumber;
  }

  @override
  int get hashCode => Object.hash(
    quarterLabel,
    dueDate,
    cumulativePercent,
    amountDue,
    amountPaid,
    challanNumber,
  );
}

/// Immutable model for the full advance tax schedule for a financial year.
///
/// Contains the estimated total tax and four quarterly installments
/// as per Section 211:
/// - Q1 (15 Jun): 15% cumulative
/// - Q2 (15 Sep): 45% cumulative
/// - Q3 (15 Dec): 75% cumulative
/// - Q4 (15 Mar): 100% cumulative
class AdvanceTaxSchedule {
  const AdvanceTaxSchedule({
    required this.estimatedTax,
    required this.installments,
  });

  /// Creates the standard 4-installment schedule for a financial year.
  ///
  /// [estimatedTax] is the total estimated tax liability for the year.
  /// [fy] is the financial year start (e.g. 2025 for FY 2025-26).
  /// All installments are initialized with zero amount paid.
  factory AdvanceTaxSchedule.forFY(double estimatedTax, int fy) {
    final installments = [
      AdvanceTaxInstallment(
        quarterLabel: 'Q1 — 15 Jun',
        dueDate: DateTime(fy, 6, 15),
        cumulativePercent: 15,
        amountDue: estimatedTax * 0.15,
        amountPaid: 0,
      ),
      AdvanceTaxInstallment(
        quarterLabel: 'Q2 — 15 Sep',
        dueDate: DateTime(fy, 9, 15),
        cumulativePercent: 45,
        amountDue: estimatedTax * 0.30,
        amountPaid: 0,
      ),
      AdvanceTaxInstallment(
        quarterLabel: 'Q3 — 15 Dec',
        dueDate: DateTime(fy, 12, 15),
        cumulativePercent: 75,
        amountDue: estimatedTax * 0.30,
        amountPaid: 0,
      ),
      AdvanceTaxInstallment(
        quarterLabel: 'Q4 — 15 Mar',
        dueDate: DateTime(fy + 1, 3, 15),
        cumulativePercent: 100,
        amountDue: estimatedTax * 0.25,
        amountPaid: 0,
      ),
    ];

    return AdvanceTaxSchedule(
      estimatedTax: estimatedTax,
      installments: installments,
    );
  }

  /// Total estimated tax liability for the financial year.
  final double estimatedTax;

  /// The four quarterly installments.
  final List<AdvanceTaxInstallment> installments;

  /// Total amount paid across all installments.
  double get totalPaid =>
      installments.fold(0.0, (sum, i) => sum + i.amountPaid);

  /// Total shortfall across all installments.
  double get totalShortfall => estimatedTax - totalPaid;

  AdvanceTaxSchedule copyWith({
    double? estimatedTax,
    List<AdvanceTaxInstallment>? installments,
  }) {
    return AdvanceTaxSchedule(
      estimatedTax: estimatedTax ?? this.estimatedTax,
      installments: installments ?? this.installments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdvanceTaxSchedule &&
        other.estimatedTax == estimatedTax &&
        listEquals(other.installments, installments);
  }

  @override
  int get hashCode => Object.hash(estimatedTax, Object.hashAll(installments));
}
