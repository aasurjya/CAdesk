import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Returns the urgency color based on days remaining.
///
/// - Red ([AppColors.error]): overdue or 0 days remaining
/// - Amber ([AppColors.warning]): 1–7 days remaining
/// - Green ([AppColors.success]): more than 7 days remaining
/// - Grey ([AppColors.neutral300]): completed or neutral
Color urgencyColorFromDays(int daysRemaining, {bool isCompleted = false}) {
  if (isCompleted) return AppColors.neutral300;
  if (daysRemaining <= 0) return AppColors.error;
  if (daysRemaining <= 7) return AppColors.warning;
  return AppColors.success;
}

/// A composable wrapper widget that adds a colored left border to any child.
///
/// Use this to apply consistent visual urgency cues across list screens.
/// The left border color communicates urgency at a glance:
/// red = overdue, amber = due soon, green = safe, grey = completed/neutral.
///
/// ```dart
/// UrgencyBorderCard(
///   urgencyColor: urgencyColorFromDays(item.daysRemaining),
///   child: MyCardContent(),
/// )
/// ```
class UrgencyBorderCard extends StatelessWidget {
  const UrgencyBorderCard({
    super.key,
    required this.child,
    required this.urgencyColor,
    this.borderWidth = 4.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
  });

  /// The content to display inside the bordered card.
  final Widget child;

  /// The color of the left border indicating urgency level.
  final Color urgencyColor;

  /// Width of the left border. Defaults to 4.0.
  final double borderWidth;

  /// Border radius for the outer container. Defaults to 12.
  final BorderRadius? borderRadius;

  /// Padding inside the container, around the child.
  final EdgeInsetsGeometry? padding;

  /// Margin outside the container.
  final EdgeInsetsGeometry? margin;

  /// Elevation for the card shadow. When null, no shadow is applied.
  final double? elevation;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    final inner = Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: urgencyColor, width: borderWidth),
        ),
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: ClipRRect(borderRadius: radius, child: inner),
    );

    if (onTap == null) return content;

    return GestureDetector(onTap: onTap, child: content);
  }
}
