import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/auth/supabase_auth_provider.dart';
import 'package:ca_app/core/theme/app_colors.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  bool _isGridView = true;
  bool _isSigningOut = false;

  static const _menuItems = <_MenuItem>[
    // Quick Access
    _MenuItem(
      icon: Icons.dashboard_outlined,
      title: 'Dashboard',
      subtitle: 'Overview & KPIs',
      route: '/dashboard',
    ),
    _MenuItem(
      icon: Icons.task_alt_outlined,
      title: 'Tasks',
      subtitle: 'Task management',
      route: '/tasks',
    ),
    _MenuItem(
      icon: Icons.verified_user_outlined,
      title: 'Compliance Calendar',
      subtitle: 'Statutory deadlines & calendar',
      route: '/compliance',
    ),
    // Core Filing Modules
    _MenuItem(
      icon: Icons.account_balance_outlined,
      title: 'Income Tax',
      subtitle: 'ITR filing & tracking',
      route: '/income-tax',
    ),
    _MenuItem(
      icon: Icons.receipt_outlined,
      title: 'GST',
      subtitle: 'Returns & compliance',
      route: '/gst',
    ),
    _MenuItem(
      icon: Icons.percent_outlined,
      title: 'TDS/TCS',
      subtitle: 'Deduction & collection',
      route: '/tds',
    ),
    _MenuItem(
      icon: Icons.auto_awesome_outlined,
      title: 'TDS.AI',
      subtitle: 'AI-assisted extraction, sectioning & return prep',
      route: '/roadmap/4',
    ),
    _MenuItem(
      icon: Icons.corporate_fare_outlined,
      title: 'MCA / ROC Compliance',
      subtitle: 'Company filings, Directors Act 2013',
      route: '/mca',
    ),
    _MenuItem(
      icon: Icons.qr_code_scanner_outlined,
      title: 'E-Invoicing',
      subtitle: 'IRP API, 30-day/3-day window & bulk generation',
      route: '/einvoicing',
    ),
    // Other Modules
    _MenuItem(
      icon: Icons.data_object_outlined,
      title: 'XBRL Filing',
      subtitle: 'XBRL tagging & MCA submission',
      route: '/xbrl',
    ),
    _MenuItem(
      icon: Icons.balance_outlined,
      title: 'Accounts & Balance Sheet',
      subtitle: 'Financials, P&L, depreciation',
      route: '/accounts',
    ),
    _MenuItem(
      icon: Icons.show_chart_outlined,
      title: 'CMA / Financial Projections',
      subtitle: 'CMA data, loan calc, EMI & DSCR',
      route: '/cma',
    ),
    _MenuItem(
      icon: Icons.people_outline,
      title: 'Payroll',
      subtitle: 'Salary, PF/ESI challans & TDS',
      route: '/payroll',
    ),
    _MenuItem(
      icon: Icons.policy_outlined,
      title: 'Assessment Orders',
      subtitle: 'Verify 143(1)/143(3), interest checks',
      route: '/assessment',
    ),
    _MenuItem(
      icon: Icons.folder_copy_outlined,
      title: 'Documents',
      subtitle: 'Client documents, cloud access & sharing',
      route: '/documents',
    ),
    _MenuItem(
      icon: Icons.cloud_outlined,
      title: 'Cloud & Remote Access',
      subtitle: 'Cloud app, backup health & remote controls',
      route: '/roadmap/13',
    ),
    _MenuItem(
      icon: Icons.receipt_long_outlined,
      title: 'Billing',
      subtitle: 'GST invoicing, payments & receivables',
      route: '/billing',
    ),
    // Modern Practice
    _MenuItem(
      icon: Icons.language_outlined,
      title: 'Client Portal',
      subtitle: 'Messages, documents & queries',
      route: '/client-portal',
    ),
    _MenuItem(
      icon: Icons.smart_toy_outlined,
      title: 'AI & Automation',
      subtitle: 'OCR, reconciliation & anomalies',
      route: '/ai-automation',
    ),
    _MenuItem(
      icon: Icons.insights_outlined,
      title: 'Analytics',
      subtitle: 'KPIs, revenue & receivables',
      route: '/analytics',
    ),
    _MenuItem(
      icon: Icons.timer_outlined,
      title: 'Time Tracking',
      subtitle: 'Billable hours & billing',
      route: '/time-tracking',
    ),
    _MenuItem(
      icon: Icons.business_outlined,
      title: 'Firm Operations',
      subtitle: 'Staff, KPIs & knowledge base',
      route: '/firm-operations',
    ),
    _MenuItem(
      icon: Icons.person_add_outlined,
      title: 'Onboarding & KYC',
      subtitle: 'Client verification & checklists',
      route: '/onboarding',
    ),
    // Specialized Compliance
    _MenuItem(
      icon: Icons.currency_exchange_outlined,
      title: 'FEMA & RBI',
      subtitle: 'Foreign exchange compliance',
      route: '/fema',
    ),
    _MenuItem(
      icon: Icons.trending_up_outlined,
      title: 'SEBI',
      subtitle: 'Capital market disclosures',
      route: '/sebi',
    ),
    _MenuItem(
      icon: Icons.swap_horiz_outlined,
      title: 'Transfer Pricing',
      subtitle: 'TP studies & Form 3CEB',
      route: '/transfer-pricing',
    ),
    _MenuItem(
      icon: Icons.currency_bitcoin_outlined,
      title: 'Crypto / VDA',
      subtitle: 'Virtual digital asset tax',
      route: '/crypto-vda',
    ),
    _MenuItem(
      icon: Icons.rocket_launch_outlined,
      title: 'Startups',
      subtitle: 'DPIIT, 80-IAC & compliance',
      route: '/startup-compliance',
    ),
    _MenuItem(
      icon: Icons.handshake_outlined,
      title: 'LLP Compliance',
      subtitle: 'Form 11, Form 8 & penalties',
      route: '/llp-compliance',
    ),
    _MenuItem(
      icon: Icons.factory_outlined,
      title: 'MSME',
      subtitle: '45-day payments & 43B(h)',
      route: '/msme',
    ),
    _MenuItem(
      icon: Icons.verified_user_outlined,
      title: 'Advanced Audits',
      subtitle: 'Statutory, internal & forensic',
      route: '/advanced-audit',
    ),
    _MenuItem(
      icon: Icons.gavel_outlined,
      title: 'Faceless Assessment',
      subtitle: 'E-proceedings & ITR-U',
      route: '/faceless-assessment',
    ),
    _MenuItem(
      icon: Icons.balance_outlined,
      title: 'Notice Resolution Center',
      subtitle: 'Notice triage, replies & appeals',
      route: '/notice-resolution',
    ),
    _MenuItem(
      icon: Icons.key_outlined,
      title: 'DSC & Credential Vault',
      subtitle: 'DSC expiry, masked access & consent',
      route: '/dsc-vault',
    ),
    _MenuItem(
      icon: Icons.event_repeat_outlined,
      title: 'Renewal & Expiry Control',
      subtitle: 'Renewals, retainers & SLA countdowns',
      route: '/renewal-expiry',
    ),
    _MenuItem(
      icon: Icons.currency_rupee_outlined,
      title: 'Fee Leakage & Scope Control',
      subtitle: 'Scope creep, disputes & recovery',
      route: '/fee-leakage',
    ),
    _MenuItem(
      icon: Icons.menu_book_outlined,
      title: 'Knowledge Engine',
      subtitle: 'Precedents, drafting memory & SOPs',
      route: '/knowledge-engine',
    ),
    _MenuItem(
      icon: Icons.lightbulb_outline,
      title: 'Tax Advisory Opportunities',
      subtitle: 'Upsell signals, scoring & proposals',
      route: '/tax-advisory',
    ),
    _MenuItem(
      icon: Icons.campaign_outlined,
      title: 'Lead Funnel & Campaigns',
      subtitle: 'Lead intake, campaigns & ROI',
      route: '/lead-funnel',
    ),
    _MenuItem(
      icon: Icons.public_outlined,
      title: 'NRI & Cross-Border Tax Desk',
      subtitle: 'DTAA, FTC & foreign asset workflows',
      route: '/nri-tax',
    ),
    _MenuItem(
      icon: Icons.business_center_outlined,
      title: 'SME Tax CFO Retainers',
      subtitle: 'Forecasting, board packs & advisory',
      route: '/sme-cfo',
    ),
    _MenuItem(
      icon: Icons.domain_add_outlined,
      title: 'Industry Vertical Playbooks',
      subtitle: 'Sector playbooks & bundled services',
      route: '/industry-playbooks',
    ),
    // AI-First & Future-Ready
    _MenuItem(
      icon: Icons.eco_outlined,
      title: 'ESG Reporting',
      subtitle: 'BRSR, carbon tax & SEBI sustainability',
      route: '/esg-reporting',
    ),
    _MenuItem(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Virtual CFO Platform',
      subtitle: 'MIS dashboards, scenario planning & board packs',
      route: '/virtual-cfo',
    ),
    _MenuItem(
      icon: Icons.document_scanner_outlined,
      title: 'Intelligent Document Processing',
      subtitle: 'AI OCR for Form 16, 26AS & bank statements',
      route: '/idp',
    ),
    _MenuItem(
      icon: Icons.notifications_active_outlined,
      title: 'Regulatory Intelligence',
      subtitle: 'Daily circular digest & client-impact analysis',
      route: '/regulatory-intelligence',
    ),
    _MenuItem(
      icon: Icons.leaderboard_outlined,
      title: 'Practice Benchmarking',
      subtitle: 'Peer comparison, pricing & growth scoring',
      route: '/practice-benchmarking',
    ),
    // General
    _MenuItem(
      icon: Icons.monitor_heart_outlined,
      title: 'Staff Monitoring',
      subtitle: 'Activity logs, restrictions & alerts',
      route: '/staff-monitoring',
    ),
    _MenuItem(
      icon: Icons.settings_outlined,
      title: 'Settings',
      subtitle: 'App preferences and account',
      route: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
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
      body: _isGridView ? _buildGridView(theme) : _buildListView(theme),
    );
  }

  Widget _buildListView(ThemeData theme) {
    return ListView(
      children: [
        _ProfileCard(theme: theme),
        const SizedBox(height: 8),
        for (int i = 0; i < _menuItems.length; i++) ...[
          _MenuTile(item: _menuItems[i]),
          if (i < _menuItems.length - 1) const Divider(height: 1, indent: 72),
        ],
        _buildFooter(theme),
      ],
    );
  }

  Widget _buildGridView(ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 600 ? 4 : 3;

    return ListView(
      children: [
        _ProfileCard(theme: theme),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
          ),
          itemCount: _menuItems.length,
          itemBuilder: (context, index) {
            final item = _menuItems[index];
            return _GridCard(item: item);
          },
        ),
        _buildFooter(theme),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'CADesk v0.1.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authProvider.notifier).signOut();
      // Router's auth redirect will navigate to /login automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                child: const Text(
                  'CA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CA Professional',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ca@example.com',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
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

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _MenuItem item;

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

class _GridCard extends StatelessWidget {
  const _GridCard({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (item.route != null) {
            context.push(item.route!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withAlpha(26),
                child: Icon(item.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 8),
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

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
}
