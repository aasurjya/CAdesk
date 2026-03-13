import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/presentation/ca_gpt_chat_screen.dart';
import 'package:ca_app/features/ca_gpt/presentation/notice_drafting_screen.dart';
import 'package:ca_app/features/ca_gpt/presentation/section_lookup_screen.dart';
import 'package:ca_app/features/ca_gpt/presentation/tax_calendar_screen.dart';

/// Home screen for CA GPT / Knowledge Engine feature.
///
/// Uses a [NavigationRail] on wide screens (≥600 dp) and a
/// [BottomNavigationBar] on narrow screens, matching the adaptive pattern
/// used throughout CADesk.
class CaGptHomeScreen extends StatefulWidget {
  const CaGptHomeScreen({super.key});

  @override
  State<CaGptHomeScreen> createState() => _CaGptHomeScreenState();
}

class _CaGptHomeScreenState extends State<CaGptHomeScreen> {
  int _selectedIndex = 0;

  static const _tabs = <_TabItem>[
    _TabItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chat',
    ),
    _TabItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Section Lookup',
    ),
    _TabItem(
      icon: Icons.edit_document,
      activeIcon: Icons.edit_document,
      label: 'Notice Draft',
    ),
    _TabItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Tax Calendar',
    ),
  ];

  static const _screens = <Widget>[
    CaGptChatScreen(),
    SectionLookupScreen(),
    NoticeDraftingScreen(),
    TaxCalendarScreen(),
  ];

  Widget _buildAppBarTitle(ThemeData theme) {
    final labels = [
      'CA GPT Chat',
      'Section Lookup',
      'Notice Drafting',
      'Tax Calendar',
    ];
    final subtitles = [
      'Ask any tax question',
      'Search Income Tax provisions',
      'Generate formal notice replies',
      'Compliance deadline calendar',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labels[_selectedIndex],
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
        Text(
          subtitles[_selectedIndex],
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: _buildAppBarTitle(theme),
            leading: isWide
                ? null
                : null, // AppBar back button handled by GoRouter shell
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          body: isWide
              ? _WideLayout(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => _selectedIndex = i),
                  tabs: _tabs,
                  screens: _screens,
                )
              : _screens[_selectedIndex],
          bottomNavigationBar: isWide
              ? null
              : _BottomNav(
                  selectedIndex: _selectedIndex,
                  onTap: (i) => setState(() => _selectedIndex = i),
                  tabs: _tabs,
                  theme: theme,
                ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Wide layout with NavigationRail
// ---------------------------------------------------------------------------

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.tabs,
    required this.screens,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_TabItem> tabs;
  final List<Widget> screens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          backgroundColor: AppColors.neutral50,
          selectedIconTheme: const IconThemeData(color: AppColors.primary),
          selectedLabelTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedIconTheme: const IconThemeData(color: AppColors.neutral400),
          unselectedLabelTextStyle: const TextStyle(
            color: AppColors.neutral400,
            fontSize: 12,
          ),
          destinations: tabs.map((tab) {
            return NavigationRailDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon),
              label: Text(tab.label),
            );
          }).toList(),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: screens[selectedIndex]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation bar
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.tabs,
    required this.theme,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<_TabItem> tabs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withAlpha(30),
      destinations: tabs.map((tab) {
        return NavigationDestination(
          icon: Icon(tab.icon),
          selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
          label: tab.label,
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab item data class
// ---------------------------------------------------------------------------

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
