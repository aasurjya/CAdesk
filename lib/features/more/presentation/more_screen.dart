import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/auth/auth_state.dart';
import 'package:ca_app/core/auth/supabase_auth_provider.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';
import 'package:ca_app/core/widgets/search_action.dart';
import 'package:ca_app/features/more/presentation/more_menu_data.dart';

const _kSearchBorderRadius = 16.0;
const _kCardBorderRadius = 20.0;

// ---------------------------------------------------------------------------
// MoreScreen
// ---------------------------------------------------------------------------

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  bool _isGridView = true;
  bool _isSigningOut = false;
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = filterMenuItems(kMoreMenuItems, _searchQuery);
    final groups = groupMenuItemsByCategory(filtered);
    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          const SearchAction(),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'List view' : 'Grid view',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _ProfileCard(theme: theme),
          _buildSearchBar(),
          const SizedBox(height: AppSpacing.xs),
          if (groups.isEmpty)
            _buildEmptySearch(theme)
          else
            for (final group in groups)
              _CategorySection(
                group: group,
                isGridView: _isGridView,
                initiallyExpanded: isSearching,
              ),
          _buildFooter(theme),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Search bar
  // -----------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search modules...',
          prefixIcon: const Icon(Icons.search, color: AppColors.neutral400),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.neutral400),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_kSearchBorderRadius),
            borderSide: const BorderSide(color: AppColors.neutral100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_kSearchBorderRadius),
            borderSide: const BorderSide(color: AppColors.neutral100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_kSearchBorderRadius),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Empty search state
  // -----------------------------------------------------------------------

  Widget _buildEmptySearch(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.neutral400),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No modules found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Footer
  // -----------------------------------------------------------------------

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: OutlinedButton.icon(
            onPressed: _isSigningOut ? null : _signOut,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout, color: AppColors.error),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            'CADesk v0.1.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Sign out
  // -----------------------------------------------------------------------

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authProvider.notifier).signOut();
    } catch (e, st) {
      debugPrint('Sign out error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign out failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// _CategorySection — one collapsible group
// ---------------------------------------------------------------------------

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.group,
    required this.isGridView,
    required this.initiallyExpanded,
  });

  final MoreCategoryGroup group;
  final bool isGridView;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCardBorderRadius),
          side: const BorderSide(color: AppColors.neutral100),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          key: PageStorageKey<String>(group.name),
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Text(
                  '${group.items.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            if (isGridView) _buildSectionGrid(context) else _buildSectionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 600 ? 4 : 3;
    final availableWidth =
        screenWidth -
        (AppSpacing.sm * 2) -
        (AppSpacing.xs * (crossAxisCount - 1));
    final tileWidth = availableWidth / crossAxisCount;
    final tileHeight = tileWidth / 0.95; // match original aspect ratio

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final item in group.items)
            SizedBox(
              width: tileWidth,
              height: tileHeight,
              child: _GridCard(item: item),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionList() {
    return Column(
      children: [
        for (int i = 0; i < group.items.length; i++) ...[
          _MenuTile(item: group.items[i]),
          if (i < group.items.length - 1) const Divider(height: 1, indent: 72),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _ProfileCard
// ---------------------------------------------------------------------------

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).asData?.value;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final displayName =
        (user?.userMetadata?['display_name'] as String?)?.trim() ??
        user?.email?.split('@').first ??
        'CA Professional';
    final email = user?.email ?? '';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCardBorderRadius),
          side: const BorderSide(color: AppColors.neutral100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'CA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MenuTile — list-view item
// ---------------------------------------------------------------------------

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final MoreMenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withAlpha(26),
        child: Icon(item.icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        item.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        item.subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.neutral400),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.neutral400),
      onTap: () {
        if (item.route != null) {
          context.push(item.route!);
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _GridCard — grid-view item
// ---------------------------------------------------------------------------

class _GridCard extends StatelessWidget {
  const _GridCard({required this.item});

  final MoreMenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
        side: const BorderSide(color: AppColors.neutral100),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (item.route != null) {
            context.push(item.route!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withAlpha(26),
                child: Icon(item.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
