import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/xbrl_element.dart';

/// List tile for a single [XbrlElement] with type color coding,
/// value display, and validation status.
class XbrlElementTile extends StatelessWidget {
  const XbrlElementTile({
    super.key,
    required this.element,
    this.onTap,
  });

  final XbrlElement element;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = element.elementType.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: element.hasError
              ? AppColors.error.withValues(alpha: 0.35)
              : element.isCompleted
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.neutral200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon with color band
              _TypeIndicator(elementType: element.elementType),
              const SizedBox(width: 12),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label + required indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            element.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (element.isRequired)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'REQ',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Element name (qualified)
                    Text(
                      element.elementName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: typeColor.withValues(alpha: 0.8),
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Value
                    if (element.isCompleted && element.value != null)
                      _ValueDisplay(element: element)
                    else if (!element.isCompleted)
                      Row(
                        children: [
                          Icon(
                            Icons.pending_outlined,
                            size: 13,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Not entered',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),

                    // Validation message
                    if (element.hasError) ...[
                      const SizedBox(height: 6),
                      _ValidationMessage(message: element.validationMessage!),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Completion status icon
              _CompletionIcon(
                isCompleted: element.isCompleted,
                hasError: element.hasError,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _TypeIndicator extends StatelessWidget {
  const _TypeIndicator({required this.elementType});

  final XbrlElementType elementType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: elementType.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            elementType.icon,
            size: 16,
            color: elementType.color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _shortLabel(elementType),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: elementType.color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  String _shortLabel(XbrlElementType type) {
    switch (type) {
      case XbrlElementType.numeric:
        return 'NUM';
      case XbrlElementType.text:
        return 'TXT';
      case XbrlElementType.date:
        return 'DATE';
      case XbrlElementType.textBlock:
        return 'BLOK';
    }
  }
}

class _ValueDisplay extends StatelessWidget {
  const _ValueDisplay({required this.element});

  final XbrlElement element;

  @override
  Widget build(BuildContext context) {
    final value = element.value ?? '';
    final unit = element.unit;

    // Truncate long text blocks
    final displayValue = element.elementType == XbrlElementType.textBlock &&
            value.length > 120
        ? '${value.substring(0, 120)}…'
        : value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neutral900,
              fontFamily: element.elementType == XbrlElementType.numeric
                  ? 'monospace'
                  : null,
            ),
            maxLines: element.elementType == XbrlElementType.textBlock ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (unit != null) ...[
          const SizedBox(width: 6),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  const _ValidationMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.error),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionIcon extends StatelessWidget {
  const _CompletionIcon({
    required this.isCompleted,
    required this.hasError,
  });

  final bool isCompleted;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return const Icon(
        Icons.error_rounded,
        size: 18,
        color: AppColors.error,
      );
    }
    if (isCompleted) {
      return const Icon(
        Icons.check_circle_rounded,
        size: 18,
        color: AppColors.success,
      );
    }
    return const Icon(
      Icons.radio_button_unchecked_rounded,
      size: 18,
      color: AppColors.neutral200,
    );
  }
}
