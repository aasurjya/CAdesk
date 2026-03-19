import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A horizontal scrollable row of [FilterChip]s for selecting a filter value.
///
/// The first item in [items] is treated as the "all" option (selects `null`).
/// Matches the pattern used in documents_screen and clients_list_screen.
class FilterChipRow<T> extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  /// All filter options. The first item represents "All" (null selection).
  final List<T> items;

  /// Currently selected item, or `null` for "All".
  final T? selected;

  /// Builds the display label for each item.
  final String Function(T) labelBuilder;

  /// Called when a chip is tapped. Passes `null` for the "All" chip.
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final item = items[index];
          final isFirst = index == 0;
          final isSelected = isFirst ? selected == null : selected == item;

          return FilterChip(
            label: Text(labelBuilder(item)),
            selected: isSelected,
            selectedColor: AppColors.primary.withAlpha(30),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.neutral600,
            ),
            onSelected: (_) => onSelected(isFirst ? null : item),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
