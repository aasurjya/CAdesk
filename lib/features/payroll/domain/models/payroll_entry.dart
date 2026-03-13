/// Immutable model representing a single payroll entry for one employee in one month.
///
/// All monetary values are stored as [String] to preserve decimal precision
/// (matching the SQLite TEXT column backing store).
class PayrollEntry {
  const PayrollEntry({
    required this.id,
    required this.clientId,
    required this.employeeId,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.allowances,
    required this.deductions,
    required this.tdsDeducted,
    required this.pfDeducted,
    required this.esiDeducted,
    required this.netSalary,
    required this.status,
  });

  /// Unique identifier for this payroll entry.
  final String id;

  /// The client (employer) this entry belongs to.
  final String clientId;

  /// The employee this entry belongs to.
  final String employeeId;

  /// Calendar month (1–12).
  final int month;

  /// Calendar year (e.g. 2025).
  final int year;

  /// Basic salary component (decimal string, e.g. "25000.00").
  final String basicSalary;

  /// Total allowances (HRA, TA, etc.) as a decimal string.
  final String allowances;

  /// Total voluntary deductions as a decimal string.
  final String deductions;

  /// TDS deducted this month as a decimal string.
  final String tdsDeducted;

  /// Provident Fund deducted this month as a decimal string.
  final String pfDeducted;

  /// ESI deducted this month as a decimal string.
  final String esiDeducted;

  /// Net take-home salary as a decimal string.
  final String netSalary;

  /// Processing status (e.g. 'draft', 'approved', 'paid').
  final String status;

  PayrollEntry copyWith({
    String? id,
    String? clientId,
    String? employeeId,
    int? month,
    int? year,
    String? basicSalary,
    String? allowances,
    String? deductions,
    String? tdsDeducted,
    String? pfDeducted,
    String? esiDeducted,
    String? netSalary,
    String? status,
  }) {
    return PayrollEntry(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      employeeId: employeeId ?? this.employeeId,
      month: month ?? this.month,
      year: year ?? this.year,
      basicSalary: basicSalary ?? this.basicSalary,
      allowances: allowances ?? this.allowances,
      deductions: deductions ?? this.deductions,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      pfDeducted: pfDeducted ?? this.pfDeducted,
      esiDeducted: esiDeducted ?? this.esiDeducted,
      netSalary: netSalary ?? this.netSalary,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PayrollEntry &&
        other.id == id &&
        other.clientId == clientId &&
        other.employeeId == employeeId &&
        other.month == month &&
        other.year == year &&
        other.basicSalary == basicSalary &&
        other.allowances == allowances &&
        other.deductions == deductions &&
        other.tdsDeducted == tdsDeducted &&
        other.pfDeducted == pfDeducted &&
        other.esiDeducted == esiDeducted &&
        other.netSalary == netSalary &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
        id,
        clientId,
        employeeId,
        month,
        year,
        basicSalary,
        allowances,
        deductions,
        tdsDeducted,
        pfDeducted,
        esiDeducted,
        netSalary,
        status,
      );

  @override
  String toString() =>
      'PayrollEntry(id: $id, employee: $employeeId, $month/$year, '
      'net: $netSalary, status: $status)';
}
