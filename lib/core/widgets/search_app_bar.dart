import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A searchable [AppBar] that toggles between a title view and a
/// search text field.
///
/// Matches the pattern from clients_list_screen and income_tax_screen.
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.searchController,
    required this.onSearchChanged,
    this.isSearchVisible = false,
    this.onSearchToggle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool isSearchVisible;
  final VoidCallback? onSearchToggle;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: isSearchVisible ? _buildSearchField() : _buildTitle(theme),
      centerTitle: false,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.neutral900,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        if (onSearchToggle != null)
          IconButton(
            icon: Icon(
              isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: onSearchToggle,
          ),
        ...?actions,
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    if (subtitle == null) {
      return Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.neutral900,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
        Text(
          subtitle!,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: const TextStyle(color: AppColors.neutral400, fontSize: 14),
        border: InputBorder.none,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.neutral400,
          size: 20,
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  searchController.clear();
                  onSearchChanged('');
                },
              )
            : null,
      ),
    );
  }
}
