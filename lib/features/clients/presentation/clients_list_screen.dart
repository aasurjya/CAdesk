import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/presentation/client_detail_screen.dart';
import 'package:ca_app/features/clients/presentation/widgets/client_tile.dart';

class ClientsListScreen extends ConsumerStatefulWidget {
  const ClientsListScreen({super.key});

  @override
  ConsumerState<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends ConsumerState<ClientsListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearchVisible = false;

  static const _typeFilters = <ClientType?>[
    null,
    ClientType.individual,
    ClientType.company,
    ClientType.firm,
    ClientType.llp,
  ];

  static const _typeFilterLabels = <String>[
    'All',
    'Individual',
    'Company',
    'Firm',
    'LLP',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).update(value);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).update('');
      }
    });
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  void _launchPhone(String? phone) {
    if (phone == null || phone.isEmpty) return;
    launchUrl(Uri(scheme: 'tel', path: phone));
  }

  void _launchEmail(String? email) {
    if (email == null || email.isEmpty) return;
    launchUrl(Uri(scheme: 'mailto', path: email));
  }

  void _navigateToDetail(BuildContext context, Client client) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientDetailScreen(clientId: client.id),
      ),
    );
  }

  void _showSortMenu(BuildContext context) {
    final currentSort = ref.read(sortOptionProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sort by',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...ClientSortOption.values.map((option) {
                final isSelected = option == currentSort;
                return ListTile(
                  title: Text(option.label),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    ref.read(sortOptionProvider.notifier).update(option);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clients = ref.watch(filteredClientsProvider);
    final selectedType = ref.watch(selectedTypeFilterProvider);
    final selectedStatus = ref.watch(selectedStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? _SearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
              )
            : const Text(
                'Clients',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _StatusSegment(
            selected: selectedStatus,
            onChanged: (status) {
              ref.read(selectedStatusFilterProvider.notifier).update(status);
            },
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _typeFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filterType = _typeFilters[index];
                final isSelected = selectedType == filterType;
                return FilterChip(
                  label: Text(
                    _typeFilterLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    ref
                        .read(selectedTypeFilterProvider.notifier)
                        .update(filterType);
                  },
                  selectedColor: AppColors.primary.withAlpha(30),
                  checkmarkColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${clients.length} client${clients.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: clients.isEmpty
                ? _EmptyState(
                    hasFilters:
                        selectedType != null ||
                        selectedStatus != null ||
                        _searchController.text.isNotEmpty,
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return ClientTile(
                          client: client,
                          onTap: () => _navigateToDetail(context, client),
                          onCall: () => _launchPhone(client.phone),
                          onEmail: () => _launchEmail(client.email),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'clients_list_fab',
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text('Add Client'),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Search name, PAN, phone...',
        border: InputBorder.none,
        filled: false,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class _StatusSegment extends StatelessWidget {
  const _StatusSegment({required this.selected, required this.onChanged});

  final ClientStatus? selected;
  final ValueChanged<ClientStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<ClientStatus?>(
        segments: const [
          ButtonSegment<ClientStatus?>(
            value: null,
            label: Text('All', style: TextStyle(fontSize: 12)),
          ),
          ButtonSegment<ClientStatus?>(
            value: ClientStatus.active,
            label: Text('Active', style: TextStyle(fontSize: 12)),
          ),
          ButtonSegment<ClientStatus?>(
            value: ClientStatus.inactive,
            label: Text('Inactive', style: TextStyle(fontSize: 12)),
          ),
          ButtonSegment<ClientStatus?>(
            value: ClientStatus.prospect,
            label: Text('Prospect', style: TextStyle(fontSize: 12)),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (selection) {
          onChanged(selection.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.people_outline,
            size: 80,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No clients match your filters' : 'No clients yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your search or filters'
                : 'Add your first client to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
