import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/mca_api/data/providers/mca_api_providers.dart';
import 'package:ca_app/features/mca_api/presentation/widgets/company_result_card.dart';

/// MCA API dashboard: company search, director DIN lookup, filing status.
class McaApiScreen extends ConsumerWidget {
  const McaApiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyResult = ref.watch(mcaCompanySearchProvider);
    final directorResult = ref.watch(mcaDirectorSearchProvider);
    final filingHistory = ref.watch(mcaFilingHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MCA API',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Ministry of Corporate Affairs',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: DecoratedBox(
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
            _McaBanner(),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'CIN / Company Search',
              icon: Icons.business_rounded,
            ),
            const SizedBox(height: 10),
            _CompanyQuickSearch(onSearch: () => context.go('/mca-api/search')),
            const SizedBox(height: 8),
            companyResult.when(
              data: (result) {
                if (result == null) return const SizedBox.shrink();
                return CompanyResultCard(company: result);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Director DIN Lookup',
              icon: Icons.person_search_rounded,
            ),
            const SizedBox(height: 10),
            _DirectorLookupCard(directorResult: directorResult, ref: ref),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Filing History',
              icon: Icons.history_rounded,
            ),
            const SizedBox(height: 10),
            _FilingHistoryCard(filingHistory: filingHistory, ref: ref),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Annual Return Compliance',
              icon: Icons.verified_rounded,
            ),
            const SizedBox(height: 10),
            _ComplianceCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banner
// ---------------------------------------------------------------------------

class _McaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MCA Portal Integration',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Look up company details, director information, and filing compliance status.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Company quick search
// ---------------------------------------------------------------------------

class _CompanyQuickSearch extends StatelessWidget {
  const _CompanyQuickSearch({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onSearch,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.neutral400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Search by CIN or company name...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Director lookup card
// ---------------------------------------------------------------------------

class _DirectorLookupCard extends ConsumerStatefulWidget {
  const _DirectorLookupCard({required this.directorResult, required this.ref});

  final AsyncValue directorResult;
  final WidgetRef ref;

  @override
  ConsumerState<_DirectorLookupCard> createState() =>
      _DirectorLookupCardState();
}

class _DirectorLookupCardState extends ConsumerState<_DirectorLookupCard> {
  final _dinController = TextEditingController();

  @override
  void dispose() {
    _dinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final directorResult = ref.watch(mcaDirectorSearchProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _dinController,
              maxLength: 8,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Director DIN',
                hintText: '8-digit DIN',
                counterText: '',
                prefixIcon: const Icon(Icons.badge_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(mcaDirectorSearchProvider.notifier)
                    .search(_dinController.text.trim());
              },
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Lookup Director'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
            const SizedBox(height: 12),
            directorResult.when(
              data: (result) {
                if (result == null) {
                  return Text(
                    'Enter a DIN to look up director details',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  );
                }
                return _DirectorResultView(director: result);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectorResultView extends StatelessWidget {
  const _DirectorResultView({required this.director});

  final dynamic director;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          director.directorName as String,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        _InfoLine(label: 'DIN', value: director.din as String),
        _InfoLine(label: 'Nationality', value: director.nationality as String),
        _InfoLine(
          label: 'Status',
          value: (director.status.name as String).toUpperCase(),
        ),
        _InfoLine(
          label: 'Companies',
          value: '${(director.associatedCompanies as List).length} associated',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Filing history card
// ---------------------------------------------------------------------------

class _FilingHistoryCard extends StatelessWidget {
  const _FilingHistoryCard({required this.filingHistory, required this.ref});

  final AsyncValue filingHistory;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'View filing history for a company by CIN',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            filingHistory.when(
              data: (result) {
                if (result == null) {
                  return OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(mcaFilingHistoryProvider.notifier)
                          .fetch('L17110MH1973PLC019786');
                    },
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('Load Filing History'),
                  );
                }
                return _FilingHistoryList(history: result);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilingHistoryList extends StatelessWidget {
  const _FilingHistoryList({required this.history});

  final dynamic history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filings = history.filings as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${filings.length} filings found',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        ...filings.map((f) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    f.formType as String,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    f.documentDescription as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  f.status as String,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Compliance card
// ---------------------------------------------------------------------------

class _ComplianceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Annual Return Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _ComplianceRow(form: 'MGT-7', status: 'Filed', isFiled: true),
            _ComplianceRow(form: 'AOC-4', status: 'Filed', isFiled: true),
            _ComplianceRow(
              form: 'DIR-3 KYC',
              status: 'Pending',
              isFiled: false,
            ),
            _ComplianceRow(form: 'ADT-1', status: 'Filed', isFiled: true),
          ],
        ),
      ),
    );
  }
}

class _ComplianceRow extends StatelessWidget {
  const _ComplianceRow({
    required this.form,
    required this.status,
    required this.isFiled,
  });

  final String form;
  final String status;
  final bool isFiled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isFiled ? AppColors.success : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isFiled ? Icons.check_rounded : Icons.schedule_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              form,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
