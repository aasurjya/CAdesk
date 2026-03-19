import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum DocumentType { form26as, ais, tis, form16, gstr2b }

extension DocumentTypeX on DocumentType {
  String get label => switch (this) {
    DocumentType.form26as => 'Form 26AS',
    DocumentType.ais => 'AIS',
    DocumentType.tis => 'TIS',
    DocumentType.form16 => 'Form 16',
    DocumentType.gstr2b => 'GSTR-2B',
  };

  IconData get icon => switch (this) {
    DocumentType.form26as => Icons.description_rounded,
    DocumentType.ais => Icons.fact_check_rounded,
    DocumentType.tis => Icons.summarize_rounded,
    DocumentType.form16 => Icons.article_rounded,
    DocumentType.gstr2b => Icons.receipt_long_rounded,
  };
}

enum FieldMatch { matched, mismatch, missing }

extension FieldMatchX on FieldMatch {
  Color get color => switch (this) {
    FieldMatch.matched => AppColors.success,
    FieldMatch.mismatch => AppColors.error,
    FieldMatch.missing => AppColors.warning,
  };

  String get label => switch (this) {
    FieldMatch.matched => 'Matched',
    FieldMatch.mismatch => 'Mismatch',
    FieldMatch.missing => 'Missing',
  };
}

class ParsedField {
  const ParsedField({
    required this.fieldName,
    required this.originalValue,
    required this.parsedValue,
    required this.match,
  });

  final String fieldName;
  final String originalValue;
  final String parsedValue;
  final FieldMatch match;
}

class ParseResult {
  const ParseResult({
    required this.id,
    required this.documentType,
    required this.clientName,
    required this.pan,
    required this.parsedAt,
    required this.fields,
    required this.confidence,
  });

  final String id;
  final DocumentType documentType;
  final String clientName;
  final String pan;
  final DateTime parsedAt;
  final List<ParsedField> fields;
  final double confidence;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _parseResultProvider = Provider.family<ParseResult, String>((
  ref,
  resultId,
) {
  return ParseResult(
    id: resultId,
    documentType: DocumentType.form26as,
    clientName: 'Rajesh Kumar',
    pan: 'ABCPK1234D',
    parsedAt: DateTime.now().subtract(const Duration(hours: 2)),
    confidence: 0.94,
    fields: const [
      ParsedField(
        fieldName: 'TDS - Salary (192)',
        originalValue: '2,45,000',
        parsedValue: '2,45,000',
        match: FieldMatch.matched,
      ),
      ParsedField(
        fieldName: 'TDS - Interest (194A)',
        originalValue: '12,500',
        parsedValue: '12,500',
        match: FieldMatch.matched,
      ),
      ParsedField(
        fieldName: 'TDS - Prof. Fees (194J)',
        originalValue: '35,000',
        parsedValue: '38,000',
        match: FieldMatch.mismatch,
      ),
      ParsedField(
        fieldName: 'TDS - Contract (194C)',
        originalValue: '8,200',
        parsedValue: '8,200',
        match: FieldMatch.matched,
      ),
      ParsedField(
        fieldName: 'Advance Tax - Q1',
        originalValue: '50,000',
        parsedValue: '50,000',
        match: FieldMatch.matched,
      ),
      ParsedField(
        fieldName: 'Advance Tax - Q2',
        originalValue: '',
        parsedValue: '—',
        match: FieldMatch.missing,
      ),
      ParsedField(
        fieldName: 'Self Assessment Tax',
        originalValue: '22,000',
        parsedValue: '22,000',
        match: FieldMatch.matched,
      ),
      ParsedField(
        fieldName: 'Refund Received',
        originalValue: '15,400',
        parsedValue: '15,400',
        match: FieldMatch.matched,
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ParserResultScreen extends ConsumerWidget {
  const ParserResultScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(_parseResultProvider(resultId));
    final theme = Theme.of(context);

    final matchedCount = result.fields
        .where((f) => f.match == FieldMatch.matched)
        .length;
    final mismatchCount = result.fields
        .where((f) => f.match == FieldMatch.mismatch)
        .length;
    final missingCount = result.fields
        .where((f) => f.match == FieldMatch.missing)
        .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parse Result',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              '${result.documentType.label} - ${result.clientName}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () {},
            tooltip: 'Export',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Confidence + summary
          Row(
            children: [
              _StatCard(
                label: 'Matched',
                value: '$matchedCount',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Mismatch',
                value: '$mismatchCount',
                icon: Icons.warning_amber_rounded,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Missing',
                value: '$missingCount',
                icon: Icons.help_outline_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Confidence',
                value: '${(result.confidence * 100).toStringAsFixed(0)}%',
                icon: Icons.analytics_outlined,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Document info card
          _InfoCard(result: result),
          const SizedBox(height: 16),

          // Field comparison table
          _SectionHeader(
            title: 'Field Comparison',
            icon: Icons.compare_arrows_rounded,
          ),
          const SizedBox(height: 10),
          ...result.fields.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FieldComparisonCard(field: f),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info card
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.result});

  final ParseResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(label: 'Document', value: result.documentType.label),
            const Divider(height: 16),
            _InfoRow(label: 'Client', value: result.clientName),
            const Divider(height: 16),
            _InfoRow(label: 'PAN', value: result.pan),
            const Divider(height: 16),
            _InfoRow(label: 'Parsed At', value: _formatDate(result.parsedAt)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Field comparison card
// ---------------------------------------------------------------------------

class _FieldComparisonCard extends StatelessWidget {
  const _FieldComparisonCard({required this.field});

  final ParsedField field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchColor = field.match.color;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: matchColor, width: 3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    field.fieldName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: matchColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    field.match.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: matchColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Original',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        field.originalValue.isEmpty ? '—' : field.originalValue,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.neutral300,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parsed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        field.parsedValue,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: field.match == FieldMatch.mismatch
                              ? AppColors.error
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
