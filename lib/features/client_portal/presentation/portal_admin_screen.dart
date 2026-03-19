import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _PortalClient {
  const _PortalClient({
    required this.id,
    required this.name,
    required this.pan,
    required this.isPortalEnabled,
    required this.sharedDocuments,
    required this.pendingQueries,
    required this.lastAccessed,
  });

  final String id;
  final String name;
  final String pan;
  final bool isPortalEnabled;
  final int sharedDocuments;
  final int pendingQueries;
  final String lastAccessed;
}

class _DocumentRequest {
  const _DocumentRequest({
    required this.clientName,
    required this.documentType,
    required this.requestedDate,
    required this.status,
  });

  final String clientName;
  final String documentType;
  final String requestedDate;
  final String status;
}

class _ClientQuery {
  const _ClientQuery({
    required this.clientName,
    required this.subject,
    required this.date,
    required this.isResolved,
  });

  final String clientName;
  final String subject;
  final String date;
  final bool isResolved;
}

const _mockClients = [
  _PortalClient(
    id: '1',
    name: 'Rajesh Sharma',
    pan: 'ABCPS1234K',
    isPortalEnabled: true,
    sharedDocuments: 12,
    pendingQueries: 2,
    lastAccessed: '15 Mar 2026',
  ),
  _PortalClient(
    id: '2',
    name: 'Priya Patel',
    pan: 'BCDPP5678L',
    isPortalEnabled: true,
    sharedDocuments: 8,
    pendingQueries: 0,
    lastAccessed: '14 Mar 2026',
  ),
  _PortalClient(
    id: '3',
    name: 'Arjun Enterprises',
    pan: 'AABCA9012M',
    isPortalEnabled: false,
    sharedDocuments: 3,
    pendingQueries: 1,
    lastAccessed: 'Never',
  ),
  _PortalClient(
    id: '4',
    name: 'Meera Textiles LLP',
    pan: 'AAFMT3456N',
    isPortalEnabled: true,
    sharedDocuments: 22,
    pendingQueries: 0,
    lastAccessed: '12 Mar 2026',
  ),
];

const _mockDocRequests = [
  _DocumentRequest(
    clientName: 'Rajesh Sharma',
    documentType: 'Form 16',
    requestedDate: '10 Mar 2026',
    status: 'Pending',
  ),
  _DocumentRequest(
    clientName: 'Rajesh Sharma',
    documentType: 'Bank Statement',
    requestedDate: '08 Mar 2026',
    status: 'Uploaded',
  ),
  _DocumentRequest(
    clientName: 'Arjun Enterprises',
    documentType: 'Balance Sheet',
    requestedDate: '05 Mar 2026',
    status: 'Pending',
  ),
];

const _mockQueries = [
  _ClientQuery(
    clientName: 'Rajesh Sharma',
    subject: 'When will my ITR be filed?',
    date: '14 Mar 2026',
    isResolved: false,
  ),
  _ClientQuery(
    clientName: 'Rajesh Sharma',
    subject: 'Need updated computation sheet',
    date: '12 Mar 2026',
    isResolved: false,
  ),
  _ClientQuery(
    clientName: 'Arjun Enterprises',
    subject: 'GST refund status query',
    date: '10 Mar 2026',
    isResolved: false,
  ),
  _ClientQuery(
    clientName: 'Meera Textiles LLP',
    subject: 'Invoice discrepancy',
    date: '08 Mar 2026',
    isResolved: true,
  ),
];

/// Admin view for managing client portal access, shared documents,
/// pending queries, and document requests.
class PortalAdminScreen extends ConsumerStatefulWidget {
  const PortalAdminScreen({super.key});

  @override
  ConsumerState<PortalAdminScreen> createState() => _PortalAdminScreenState();
}

class _PortalAdminScreenState extends ConsumerState<PortalAdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingQueries = _mockQueries.where((q) => !q.isResolved).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portal Admin',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Manage client portal access and requests',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Clients'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Queries'),
                  if (pendingQueries > 0) ...[
                    const SizedBox(width: 6),
                    _Badge(count: pendingQueries),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Doc Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_ClientAccessTab(), _QueriesTab(), _DocRequestsTab()],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Client access tab
// ---------------------------------------------------------------------------

class _ClientAccessTab extends StatelessWidget {
  const _ClientAccessTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: _mockClients.length,
      itemBuilder: (context, index) {
        final client = _mockClients[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withAlpha(20),
                      child: Text(
                        client.name.split(' ').map((w) => w[0]).take(2).join(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            client.pan,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: client.isPortalEnabled,
                      activeTrackColor: AppColors.success,
                      onChanged: (_) {},
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.folder_shared_outlined,
                      label: '${client.sharedDocuments} docs',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.help_outline_rounded,
                      label: '${client.pendingQueries} queries',
                      isHighlighted: client.pendingQueries > 0,
                    ),
                    const Spacer(),
                    Text(
                      'Last: ${client.lastAccessed}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Queries tab
// ---------------------------------------------------------------------------

class _QueriesTab extends StatelessWidget {
  const _QueriesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: _mockQueries.length,
      itemBuilder: (context, index) {
        final query = _mockQueries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: query.isResolved
                  ? AppColors.success.withAlpha(20)
                  : AppColors.warning.withAlpha(20),
              child: Icon(
                query.isResolved
                    ? Icons.check_circle_outline
                    : Icons.help_outline_rounded,
                color: query.isResolved ? AppColors.success : AppColors.warning,
                size: 20,
              ),
            ),
            title: Text(
              query.subject,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${query.clientName} \u2022 ${query.date}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            trailing: query.isResolved
                ? const Text(
                    'Resolved',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(70, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Reply', style: TextStyle(fontSize: 12)),
                  ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Document requests tab
// ---------------------------------------------------------------------------

class _DocRequestsTab extends StatelessWidget {
  const _DocRequestsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: _mockDocRequests.length,
      itemBuilder: (context, index) {
        final req = _mockDocRequests[index];
        final isPending = req.status == 'Pending';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: isPending
                  ? AppColors.warning.withAlpha(20)
                  : AppColors.success.withAlpha(20),
              child: Icon(
                isPending ? Icons.upload_file : Icons.check_circle_outline,
                color: isPending ? AppColors.warning : AppColors.success,
                size: 20,
              ),
            ),
            title: Text(
              req.documentType,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${req.clientName} \u2022 ${req.requestedDate}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPending
                    ? AppColors.warning.withAlpha(20)
                    : AppColors.success.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                req.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPending ? AppColors.warning : AppColors.success,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final color = isHighlighted ? AppColors.warning : AppColors.neutral400;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
