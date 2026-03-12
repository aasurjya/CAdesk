/// Classification of a pay component — whether it adds to or reduces pay.
enum PayComponentType {
  /// An earning component that adds to gross pay (e.g. Basic, HRA).
  earning,

  /// A deduction component that reduces net pay (e.g. PF, ESI, TDS).
  deduction,
}

/// A single line item on a payslip — either an earning or a deduction.
///
/// All monetary values are stored in paise (1/100th of a rupee).
class PayComponent {
  const PayComponent({
    required this.name,
    required this.type,
    required this.amountPaise,
    required this.isTaxable,
  });

  /// Display name shown on the payslip (e.g. 'Basic Salary', 'PF Employee').
  final String name;

  /// Whether this component is an earning or a deduction.
  final PayComponentType type;

  /// Amount in paise. Always a non-negative value; the [type] determines
  /// whether it adds or subtracts from pay.
  final int amountPaise;

  /// Whether this component is included in taxable income under the
  /// Income Tax Act. Used for Form 16 / TDS computation.
  final bool isTaxable;

  PayComponent copyWith({
    String? name,
    PayComponentType? type,
    int? amountPaise,
    bool? isTaxable,
  }) {
    return PayComponent(
      name: name ?? this.name,
      type: type ?? this.type,
      amountPaise: amountPaise ?? this.amountPaise,
      isTaxable: isTaxable ?? this.isTaxable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PayComponent &&
        other.name == name &&
        other.type == type &&
        other.amountPaise == amountPaise &&
        other.isTaxable == isTaxable;
  }

  @override
  int get hashCode => Object.hash(name, type, amountPaise, isTaxable);

  @override
  String toString() =>
      'PayComponent(name: $name, type: $type, '
      'amount: $amountPaise paise, taxable: $isTaxable)';
}
