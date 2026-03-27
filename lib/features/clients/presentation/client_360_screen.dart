import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/presentation/widgets/client_avatar.dart';

import 'package:ca_app/features/clients/presentation/tabs/overview_tab.dart';
import 'package:ca_app/features/clients/presentation/tabs/compliance_tab.dart';
import 'package:ca_app/features/clients/presentation/tabs/documents_tab.dart';
import 'package:ca_app/features/clients/presentation/tabs/billing_tab.dart';
import 'package:ca_app/features/clients/presentation/tabs/notes_tab.dart';

/// The number of tabs in the Client 360 screen.
const _tabCount = 5;

/// Unified tabbed Client 360 screen that integrates client detail,
/// compliance health, documents, billing, and notes into a single view.
///
/// Tabs:
///  0 - Overview  (contact, services, quick actions, metadata)
///  1 - Compliance (risk score, ITR/GST/TDS status, pending actions)
///  2 - Docs      (document list with type badges)
///  3 - Billing   (outstanding amount, invoices, payment summary)
///  4 - Notes     (read/edit client notes)
class Client360Screen extends ConsumerStatefulWidget {
  const Client360Screen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<Client360Screen> createState() => _Client360ScreenState();
}

class _Client360ScreenState extends ConsumerState<Client360Screen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndDelete(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text(
          'Are you sure you want to delete "${client.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final deleteClient = ref.read(deleteClientProvider(client.id));
      await deleteClient();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${client.name}" has been deleted.')),
      );
      context.pop();
    } catch (e, st) {
      debugPrint('Delete client error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete client. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(clientByIdProvider(widget.clientId));

    if (client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: const Center(child: Text('Client not found')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(client),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(client: client),
          ComplianceTab(clientId: widget.clientId),
          DocumentsTab(clientId: widget.clientId),
          BillingTab(clientId: widget.clientId),
          NotesTab(clientId: widget.clientId),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'client_360_fab',
        onPressed: () => context.push('/clients/${client.id}/edit'),
        child: const Icon(Icons.edit),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Client client) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(client.status);

    return AppBar(
      title: Row(
        children: [
          ClientAvatar(
            initials: client.initials,
            clientType: client.clientType,
            radius: 16,
            fontSize: 10,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      client.pan,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        client.status.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmAndDelete(client);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  'Delete Client',
                  style: TextStyle(color: Colors.red),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.neutral400,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(icon: Icon(Icons.person, size: 18), text: 'Overview'),
          Tab(icon: Icon(Icons.verified_user, size: 18), text: 'Compliance'),
          Tab(icon: Icon(Icons.folder, size: 18), text: 'Docs'),
          Tab(icon: Icon(Icons.receipt, size: 18), text: 'Billing'),
          Tab(icon: Icon(Icons.note, size: 18), text: 'Notes'),
        ],
      ),
    );
  }

  Color _statusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return AppColors.success;
      case ClientStatus.inactive:
        return AppColors.neutral400;
      case ClientStatus.prospect:
        return AppColors.warning;
    }
  }
}
