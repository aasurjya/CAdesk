import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/xbrl_filing.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

/// Card tile for a single [XbrlFiling] with a completion percentage ring,
/// validation error count, and report type badge.
class XbrlFilingTile extends StatelessWidget {
  const XbrlFilingTile({
    super.key,
    required this.filing,
    this.onTap,
  });

  final XbrlFiling filing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: filing.hasErrors
              ? AppColors.error.withValues(alpha: 0.35)
              : AppColors.neutral200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion ring
              _CompletionRing(percentage: filing.completionPercentage),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company name + report type badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            filing.companyName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ReportTypeBadge(reportType: filing.reportType),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // CIN
                    Text(
                      filing.cin,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                        fontFamily: 'monospace',
                        letterSpacing: 0.4,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // FY + taxonomy + status row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _MetaChip(
                          icon: Icons.calendar_today_rounded,
                          label: 'FY ${filing.financialYear}',
                        ),
                        _MetaChip(
                          icon: Icons.schema_rounded,
                          label: 'Taxonomy ${filing.taxonomyVersion}',
                        ),
                        _StatusPill(status: filing.status),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Tags progress + errors row
                    Row(
                      children: [
                        Text(
                          '${filing.completedTags}/${filing.totalTags} tags',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const Spacer(),
                        if (filing.validationErrors > 0)
                          _ValidationBadge(
                            count: filing.validationErrors,
                            isError: true,
                          ),
                        if (filing.validationErrors > 0 &&
                            filing.validationWarnings > 0)
                          const SizedBox(width: 6),
                        if (filing.validationWarnings > 0)
                          _ValidationBadge(
                            count: filing.validationWarnings,
                            isError: false,
                          ),
                      ],
                    ),

                    // Filed date if available
                    if (filing.filedDate != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Filed ${_dateFmt.format(filing.filedDate!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completion ring (custom painter)
// ---------------------------------------------------------------------------

class _CompletionRing extends StatelessWidget {
  const _CompletionRing({required this.percentage});

  final double percentage;

  Color get _ringColor {
    if (percentage >= 1.0) return AppColors.success;
    if (percentage >= 0.5) return AppColors.primaryVariant;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (percentage * 100).round();

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(56, 56),
            painter: _RingPainter(
              percentage: percentage,
              ringColor: _ringColor,
              trackColor: AppColors.neutral200,
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _ringColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.percentage,
    required this.ringColor,
    required this.trackColor,
  });

  final double percentage;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    const strokeWidth = 5.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percentage != percentage ||
      old.ringColor != ringColor;
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

class _ReportTypeBadge extends StatelessWidget {
  const _ReportTypeBadge({required this.reportType});

  final XbrlReportType reportType;

  @override
  Widget build(BuildContext context) {
    final isConsolidated = reportType == XbrlReportType.consolidated;
    final color = isConsolidated ? AppColors.primary : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        reportType.shortLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final XbrlFilingStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(status.icon, size: 12, color: status.color),
        const SizedBox(width: 3),
        Text(
          status.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: status.color,
          ),
        ),
      ],
    );
  }
}

class _ValidationBadge extends StatelessWidget {
  const _ValidationBadge({required this.count, required this.isError});

  final int count;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.warning;
    final icon = isError ? Icons.error_rounded : Icons.warning_amber_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            '$count ${isError ? 'error${count > 1 ? 's' : ''}' : 'warn${count > 1 ? 's' : ''}'}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.neutral400),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}
