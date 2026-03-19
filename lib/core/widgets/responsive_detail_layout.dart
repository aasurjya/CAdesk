import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Adaptive master-detail layout.
///
/// On narrow screens (< [breakpoint]), shows only [listPane].
/// On wider screens, shows a side-by-side layout with [listPane] (flex: 2)
/// and [detailPane] (flex: 3) separated by a vertical divider.
class ResponsiveDetailLayout extends StatelessWidget {
  const ResponsiveDetailLayout({
    super.key,
    required this.listPane,
    required this.detailPane,
    this.breakpoint = 900,
  });

  final Widget listPane;
  final Widget detailPane;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < breakpoint) {
      return listPane;
    }

    return Row(
      children: [
        Expanded(flex: 2, child: listPane),
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: AppColors.neutral200,
        ),
        Expanded(flex: 3, child: detailPane),
      ],
    );
  }
}
