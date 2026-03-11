import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_retainer.dart';

/// A card tile displaying the key details of a single CFO retainer engagement.
class CfoRetainerTile extends StatelessWidget {
  const CfoRetainerTile({super.key, required this.retainer});

  final CfoRetainer retainer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final daysLeft = retainer.nextReviewDaysLeft;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: client name + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health score ring
                  _HealthRing(score: retainer.healthScore),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          retainer.clientName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          retainer.industry,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  _RetainerStatusBadge(status: retainer.status),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.neutral200),
              const SizedBox(height: 10),

              // Row 2: fee + annual value
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    retainer.formattedFee,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '· ₹${(retainer.annualValue / 100000).toStringAsFixed(1)}L/yr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.person_outline_rounded,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    retainer.assignedPartner,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Row 3: next review + deliverables count
              Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 13,
                    color: daysLeft < 0
                        ? AppColors.error
                        : daysLeft <= 14
                        ? AppColors.warning
                        : AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Review: ${dateFormat.format(retainer.nextReviewDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: daysLeft < 0
                          ? AppColors.error
                          : daysLeft <= 14
                          ? AppColors.warning
                          : AppColors.neutral400,
                      fontWeight: daysLeft < 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.checklist_rounded,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${retainer.deliverables.length} deliverable'
                    '${retainer.deliverables.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Health score ring
// ---------------------------------------------------------------------------

class _HealthRing extends StatelessWidget {
  const _HealthRing({required this.score});

  final int score;

  Color get _ringColor {
    if (score > 70) return AppColors.success;
    if (score > 45) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(44, 44),
            painter: _RingPainter(
              progress: score / 100,
              color: _ringColor,
              trackColor: AppColors.neutral200,
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 11,
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
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 4.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _RetainerStatusBadge extends StatelessWidget {
  const _RetainerStatusBadge({required this.status});

  final CfoRetainerStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
