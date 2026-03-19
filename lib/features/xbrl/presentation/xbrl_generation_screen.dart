import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../domain/models/xbrl_filing.dart';

// ---------------------------------------------------------------------------
// Document type for XBRL generation
// ---------------------------------------------------------------------------

enum _XbrlDocType {
  balanceSheet('Balance Sheet', Icons.account_balance_rounded),
  profitAndLoss('Profit & Loss', Icons.trending_up_rounded),
  cashFlow('Cash Flow Statement', Icons.water_drop_rounded),
  notes('Notes to Accounts', Icons.note_rounded),
  directors('Directors Report', Icons.people_rounded);

  const _XbrlDocType(this.label, this.icon);

  final String label;
  final IconData icon;
}

// ---------------------------------------------------------------------------
// XBRL element mapping row model
// ---------------------------------------------------------------------------

class _ElementMapping {
  const _ElementMapping({
    required this.taxonomyElement,
    required this.dataField,
    required this.value,
    required this.isMapped,
  });

  final String taxonomyElement;
  final String dataField;
  final String value;
  final bool isMapped;
}

/// XBRL taxonomy instance generation screen.
///
/// Route: `/xbrl/generate`
class XbrlGenerationScreen extends ConsumerStatefulWidget {
  const XbrlGenerationScreen({super.key});

  @override
  ConsumerState<XbrlGenerationScreen> createState() =>
      _XbrlGenerationScreenState();
}

class _XbrlGenerationScreenState extends ConsumerState<XbrlGenerationScreen> {
  _XbrlDocType _selectedDocType = _XbrlDocType.balanceSheet;
  XbrlReportType _reportType = XbrlReportType.standalone;
  String _financialYear = '2024-25';
  bool _validating = false;
  bool _generating = false;
  bool _generated = false;
  int _validationErrors = 0;
  int _validationWarnings = 0;

  List<_ElementMapping> get _mockMappings =>
      _getMappingsForDocType(_selectedDocType);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Generate XBRL Instance',
          style: TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration section
            const _SectionHeader(title: 'Configuration'),
            const SizedBox(height: 12),
            _ConfigCard(
              reportType: _reportType,
              financialYear: _financialYear,
              onReportTypeChanged: (v) => setState(() => _reportType = v),
              onFYChanged: (v) => setState(() => _financialYear = v),
            ),
            const SizedBox(height: 20),

            // Document type selector
            const _SectionHeader(title: 'Document Type'),
            const SizedBox(height: 12),
            _DocTypeSelector(
              selected: _selectedDocType,
              onChanged: (v) => setState(() => _selectedDocType = v),
            ),
            const SizedBox(height: 20),

            // Element mapping
            const _SectionHeader(title: 'Taxonomy Element Mapping'),
            const SizedBox(height: 12),
            _ElementMappingTable(mappings: _mockMappings),
            const SizedBox(height: 20),

            // Validation
            if (_validating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Validating against taxonomy rules...'),
                    ],
                  ),
                ),
              )
            else if (_validationErrors > 0 || _validationWarnings > 0) ...[
              _ValidationResultCard(
                errors: _validationErrors,
                warnings: _validationWarnings,
              ),
              const SizedBox(height: 16),
            ],

            // Generated file
            if (_generated) ...[
              _GeneratedFileCard(
                docType: _selectedDocType,
                reportType: _reportType,
                financialYear: _financialYear,
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            if (!_generated) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _validating ? null : _runValidation,
                      icon: const Icon(Icons.rule_rounded, size: 18),
                      label: const Text('Validate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryVariant,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _generating ? null : _generateXbrl,
                      icon: _generating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.code_rounded, size: 18),
                      label: Text(
                        _generating ? 'Generating...' : 'Generate XBRL',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('XBRL file downloaded successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download XBRL File'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _runValidation() async {
    setState(() => _validating = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _validating = false;
      _validationErrors = 0;
      _validationWarnings = 2;
    });
  }

  Future<void> _generateXbrl() async {
    setState(() => _generating = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _generating = false;
      _generated = true;
    });
  }

  List<_ElementMapping> _getMappingsForDocType(_XbrlDocType docType) {
    switch (docType) {
      case _XbrlDocType.balanceSheet:
        return const [
          _ElementMapping(
            taxonomyElement: 'ShareCapital',
            dataField: 'Share Capital',
            value: '50,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'ReservesAndSurplus',
            dataField: 'Reserves & Surplus',
            value: '1,25,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'LongTermBorrowings',
            dataField: 'Long-term Borrowings',
            value: '75,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'TradePayables',
            dataField: 'Trade Payables',
            value: '18,50,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'FixedAssets',
            dataField: 'Property, Plant & Equipment',
            value: '1,40,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'Inventories',
            dataField: 'Inventories',
            value: '22,00,000',
            isMapped: false,
          ),
          _ElementMapping(
            taxonomyElement: 'TradeReceivables',
            dataField: 'Trade Receivables',
            value: '15,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'CashAndEquivalents',
            dataField: 'Cash & Bank',
            value: '8,50,000',
            isMapped: true,
          ),
        ];
      case _XbrlDocType.profitAndLoss:
        return const [
          _ElementMapping(
            taxonomyElement: 'Revenue',
            dataField: 'Revenue from Operations',
            value: '5,00,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'OtherIncome',
            dataField: 'Other Income',
            value: '12,50,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'CostOfMaterials',
            dataField: 'Material Cost',
            value: '2,80,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'EmployeeBenefit',
            dataField: 'Employee Expenses',
            value: '45,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'Depreciation',
            dataField: 'Depreciation',
            value: '18,00,000',
            isMapped: false,
          ),
          _ElementMapping(
            taxonomyElement: 'ProfitBeforeTax',
            dataField: 'PBT',
            value: '69,50,000',
            isMapped: true,
          ),
        ];
      default:
        return const [
          _ElementMapping(
            taxonomyElement: 'CashFromOperations',
            dataField: 'Operating Cash Flow',
            value: '45,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'CashFromInvesting',
            dataField: 'Investing Cash Flow',
            value: '-22,00,000',
            isMapped: true,
          ),
          _ElementMapping(
            taxonomyElement: 'CashFromFinancing',
            dataField: 'Financing Cash Flow',
            value: '-10,00,000',
            isMapped: false,
          ),
        ];
    }
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Config card
// ---------------------------------------------------------------------------

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.reportType,
    required this.financialYear,
    required this.onReportTypeChanged,
    required this.onFYChanged,
  });

  final XbrlReportType reportType;
  final String financialYear;
  final ValueChanged<XbrlReportType> onReportTypeChanged;
  final ValueChanged<String> onFYChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: financialYear,
              decoration: const InputDecoration(
                labelText: 'Financial Year',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: '2024-25', child: Text('2024-25')),
                DropdownMenuItem(value: '2023-24', child: Text('2023-24')),
              ],
              onChanged: (v) {
                if (v != null) onFYChanged(v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: XbrlReportType.values.map((t) {
                final isSelected = reportType == t;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: t == XbrlReportType.standalone ? 8 : 0,
                    ),
                    child: ChoiceChip(
                      label: Text(t.label),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      onSelected: (_) => onReportTypeChanged(t),
                      labelStyle: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document type selector
// ---------------------------------------------------------------------------

class _DocTypeSelector extends StatelessWidget {
  const _DocTypeSelector({required this.selected, required this.onChanged});

  final _XbrlDocType selected;
  final ValueChanged<_XbrlDocType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _XbrlDocType.values.map((docType) {
          final isSelected = docType == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(
                docType.icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.neutral400,
              ),
              label: Text(docType.label),
              selected: isSelected,
              selectedColor: AppColors.primary.withValues(alpha: 0.12),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.neutral600,
              ),
              onSelected: (_) => onChanged(docType),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Element mapping table
// ---------------------------------------------------------------------------

class _ElementMappingTable extends StatelessWidget {
  const _ElementMappingTable({required this.mappings});

  final List<_ElementMapping> mappings;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 24),
                Expanded(
                  child: Text(
                    'XBRL Element',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Financial Data',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Value',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          ...mappings.map((m) => _MappingRow(mapping: m)),
        ],
      ),
    );
  }
}

class _MappingRow extends StatelessWidget {
  const _MappingRow({required this.mapping});

  final _ElementMapping mapping;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        children: [
          Icon(
            mapping.isMapped ? Icons.link_rounded : Icons.link_off_rounded,
            size: 16,
            color: mapping.isMapped ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mapping.taxonomyElement,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: mapping.isMapped
                    ? AppColors.neutral900
                    : AppColors.warning,
              ),
            ),
          ),
          Expanded(
            child: Text(
              mapping.dataField,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              mapping.value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Validation result card
// ---------------------------------------------------------------------------

class _ValidationResultCard extends StatelessWidget {
  const _ValidationResultCard({required this.errors, required this.warnings});

  final int errors;
  final int warnings;

  @override
  Widget build(BuildContext context) {
    final hasErrors = errors > 0;
    final color = hasErrors ? AppColors.error : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            hasErrors ? Icons.error_rounded : Icons.warning_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasErrors
                      ? '$errors Errors, $warnings Warnings'
                      : '$warnings Warnings',
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
                Text(
                  hasErrors
                      ? 'Fix errors before generating the XBRL file'
                      : 'Warnings are advisory. You can proceed with generation.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generated file card
// ---------------------------------------------------------------------------

class _GeneratedFileCard extends StatelessWidget {
  const _GeneratedFileCard({
    required this.docType,
    required this.reportType,
    required this.financialYear,
  });

  final _XbrlDocType docType;
  final XbrlReportType reportType;
  final String financialYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 32,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'XBRL Instance Generated',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${docType.label} - ${reportType.label} ($financialYear)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  'xbrl_${reportType.shortLabel.toLowerCase()}_$financialYear.xml',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
