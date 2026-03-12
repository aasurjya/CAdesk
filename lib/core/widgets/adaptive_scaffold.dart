import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

enum _LayoutMode { phone, tablet, desktop }

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_NavDestination>[
    _NavDestination(
      icon: Icons.upload_file_outlined,
      selectedIcon: Icons.upload_file,
      label: 'Filing',
    ),
    _NavDestination(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: 'Clients',
    ),
    _NavDestination(
      icon: Icons.today_outlined,
      selectedIcon: Icons.today,
      label: 'Today',
    ),
    _NavDestination(
      icon: Icons.folder_copy_outlined,
      selectedIcon: Icons.folder_copy,
      label: 'Docs',
    ),
    _NavDestination(
      icon: Icons.more_horiz_outlined,
      selectedIcon: Icons.more_horiz,
      label: 'More',
    ),
  ];

  _LayoutMode _layoutMode(double width) {
    if (width >= 1200) return _LayoutMode.desktop;
    if (width >= 600) return _LayoutMode.tablet;
    return _LayoutMode.phone;
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mode = _layoutMode(width);

    return switch (mode) {
      _LayoutMode.phone => _buildPhoneLayout(),
      _LayoutMode.tablet => _buildRailLayout(extended: false),
      _LayoutMode.desktop => _buildRailLayout(extended: true),
    };
  }

  Widget _buildPhoneLayout() {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.neutral100)),
        ),
        child: NavigationBar(
          height: 72,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            for (final dest in _destinations)
              NavigationDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: dest.label,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRailLayout({required bool extended}) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Row(
        children: [
          Container(
            width: extended ? 264 : 92,
            margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.neutral100),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: NavigationRail(
              extended: extended,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: Colors.transparent,
              leading: extended
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'CADesk',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Practice OS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 12),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
              destinations: [
                for (final dest in _destinations)
                  NavigationRailDestination(
                    icon: Icon(dest.icon),
                    selectedIcon: Icon(dest.selectedIcon),
                    label: Text(dest.label),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
