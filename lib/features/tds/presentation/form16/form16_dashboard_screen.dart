import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/data/providers/form16_providers.dart';
import 'package:ca_app/features/tds/presentation/form16/widgets/form16_status_tile.dart';

/// Main Form 16 / 16A dashboard with tab bar, summary cards, and list.
class Form16DashboardScreen extends ConsumerWidget {
  const Form16DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Form 16 / 16A',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                'TDS certificates for salary & non-salary',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [_FYSelector()],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.neutral400,
            indicatorColor: AppColors.primary,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'Form 16 (Salary)'),
              Tab(text: 'Form 16A (Non-Salary)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_Form16SalaryTab(), _Form16ANonSalaryTab()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/tds/form16/bulk'),
          icon: const Icon(Icons.bolt_rounded),
          label: const Text('Generate Bulk'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FY selector dropdown
// ---------------------------------------------------------------------------

class _FYSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fy = ref.watch(form16FinancialYearProvider);
    final fys = ref.watch(form16AvailableFYsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: fy,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            items: fys.map((y) {
              return DropdownMenuItem(value: y, child: Text('FY $y'));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(form16FinancialYearProvider.notifier).update(value);
              }
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form 16 (Salary) tab
// ---------------------------------------------------------------------------

class _Form16SalaryTab extends ConsumerWidget {
  const _Form16SalaryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allForms = ref.watch(form16ListProvider);

    // For the mock: first 3 are generated, rest pending
    final generated = allForms.length >= 3 ? 3 : allForms.length;
    final pending = allForms.length - generated;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCards(
            totalEmployees: allForms.length,
            generated: generated,
            pending: pending,
          ),
          const SizedBox(height: 16),
          ...allForms.asMap().entries.map((entry) {
            final index = entry.key;
            final form = entry.value;
            final status = index < 3
                ? Form16Status.generated
                : Form16Status.pending;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Form16StatusTile(
                form16: form,
                status: status,
                onTap: () {
                  ref.read(selectedForm16Provider.notifier).select(form);
                  context.push('/tds/form16/view', extra: form);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form 16A (Non-Salary) tab — placeholder
// ---------------------------------------------------------------------------

class _Form16ANonSalaryTab extends StatelessWidget {
  const _Form16ANonSalaryTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 12),
          Text(
            'Form 16A Coming Soon',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Non-salary TDS certificates will appear here.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary cards
// ---------------------------------------------------------------------------

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.totalEmployees,
    required this.generated,
    required this.pending,
  });

  final int totalEmployees;
  final int generated;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.people_rounded,
                  label: 'Total Employees',
                  value: '$totalEmployees',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Generated',
                  value: '$generated',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.pending_rounded,
                  label: 'Pending',
                  value: '$pending',
                  color: AppColors.warning,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.people_rounded,
                label: 'Employees',
                value: '$totalEmployees',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_circle_rounded,
                label: 'Generated',
                value: '$generated',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.pending_rounded,
                label: 'Pending',
                value: '$pending',
                color: AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
