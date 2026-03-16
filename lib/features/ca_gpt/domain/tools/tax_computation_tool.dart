import 'package:ca_app/features/ca_gpt/domain/tools/agent_tool.dart';

/// Computes and compares tax under old vs new regime.
class TaxComputationTool implements AgentTool {
  const TaxComputationTool();

  @override
  String get name => 'tax_computation';

  @override
  String get description =>
      'Compare tax liability under old regime vs new regime (Section 115BAC) '
      'for a given total income and deductions.';

  @override
  Map<String, dynamic> get parameters => const {
    'type': 'object',
    'properties': {
      'total_income': {'type': 'number', 'description': 'Total income in INR'},
      'deductions_80c': {
        'type': 'number',
        'description': 'Deductions under Section 80C in INR (max 1.5 lakh)',
      },
      'hra_exemption': {
        'type': 'number',
        'description': 'HRA exemption in INR',
      },
    },
    'required': ['total_income'],
  };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final income = (arguments['total_income'] as num?)?.toDouble() ?? 0;
    final deductions80c =
        (arguments['deductions_80c'] as num?)?.toDouble() ?? 0;
    final hra = (arguments['hra_exemption'] as num?)?.toDouble() ?? 0;

    final taxableOld = income - deductions80c.clamp(0, 150000) - hra - 50000;
    final taxableNew = income - 75000; // Standard deduction under new regime

    final oldTax = _computeOldRegime(taxableOld.clamp(0, double.infinity));
    final newTax = _computeNewRegime(taxableNew.clamp(0, double.infinity));

    final buffer = StringBuffer();
    buffer.writeln('Tax Comparison (AY 2026-27):');
    buffer.writeln();
    buffer.writeln('Old Regime:');
    buffer.writeln('  Taxable Income: ₹${taxableOld.toStringAsFixed(0)}');
    buffer.writeln('  Tax: ₹${oldTax.toStringAsFixed(0)}');
    buffer.writeln();
    buffer.writeln('New Regime (115BAC):');
    buffer.writeln('  Taxable Income: ₹${taxableNew.toStringAsFixed(0)}');
    buffer.writeln('  Tax: ₹${newTax.toStringAsFixed(0)}');
    buffer.writeln();
    buffer.writeln(
      oldTax <= newTax
          ? 'Recommendation: Old regime saves ₹${(newTax - oldTax).toStringAsFixed(0)}'
          : 'Recommendation: New regime saves ₹${(oldTax - newTax).toStringAsFixed(0)}',
    );

    return buffer.toString();
  }

  double _computeOldRegime(double taxable) {
    if (taxable <= 250000) return 0;
    if (taxable <= 500000) return (taxable - 250000) * 0.05;
    if (taxable <= 1000000) {
      return 12500 + (taxable - 500000) * 0.20;
    }
    return 112500 + (taxable - 1000000) * 0.30;
  }

  double _computeNewRegime(double taxable) {
    if (taxable <= 400000) return 0;
    if (taxable <= 800000) return (taxable - 400000) * 0.05;
    if (taxable <= 1200000) return 20000 + (taxable - 800000) * 0.10;
    if (taxable <= 1600000) return 60000 + (taxable - 1200000) * 0.15;
    if (taxable <= 2000000) return 120000 + (taxable - 1600000) * 0.20;
    if (taxable <= 2400000) return 200000 + (taxable - 2000000) * 0.25;
    return 300000 + (taxable - 2400000) * 0.30;
  }
}
