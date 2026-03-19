import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/global_search_overlay.dart';

/// Reusable search icon button for AppBar `actions`.
///
/// Opens the global search overlay when tapped. Drop this into any
/// screen's AppBar actions list:
/// ```dart
/// AppBar(
///   actions: const [SearchAction()],
/// )
/// ```
class SearchAction extends StatelessWidget {
  const SearchAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('global_search_action'),
      icon: const Icon(Icons.search),
      color: AppColors.neutral600,
      tooltip: 'Search',
      onPressed: () => showGlobalSearchOverlay(context),
    );
  }
}
