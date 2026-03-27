import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A reusable [DraggableScrollableSheet] scaffold with a drag handle,
/// rounded top corners, and Material background.
///
/// Matches the pattern from filing_detail_sheet and other bottom sheets.
class DetailBottomSheet extends StatelessWidget {
  const DetailBottomSheet({
    super.key,
    required this.child,
    this.initialChildSize = 0.6,
    this.maxChildSize = 0.92,
  });

  final Widget child;
  final double initialChildSize;
  final double maxChildSize;

  /// Shows this sheet as a modal bottom sheet and returns a [Future] that
  /// resolves when the sheet is dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double initialChildSize = 0.6,
    double maxChildSize = 0.92,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetailBottomSheet(
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: 0.3,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _DragHandle(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
