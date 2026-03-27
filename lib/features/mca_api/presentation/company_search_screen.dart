import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/mca_api/data/providers/mca_api_providers.dart';
import 'package:ca_app/features/mca_api/presentation/widgets/company_result_card.dart';

/// Company search screen: CIN or name search with full company details.
class CompanySearchScreen extends ConsumerStatefulWidget {
  const CompanySearchScreen({super.key});

  @override
  ConsumerState<CompanySearchScreen> createState() =>
      _CompanySearchScreenState();
}

class _CompanySearchScreenState extends ConsumerState<CompanySearchScreen> {
  final _controller = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(mcaCompanySearchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Search',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Search by CIN or company name',
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
            _SearchBanner(),
            const SizedBox(height: 16),
            _CompanyInput(
              controller: _controller,
              validationError: _validationError,
              onSearch: _handleSearch,
            ),
            const SizedBox(height: 16),
            searchResult.when(
              data: (result) {
                if (result == null) return _EmptyState();
                return CompanyResultCard(company: result);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _SearchErrorCard(message: e.toString()),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _validationError = 'Please enter a CIN or company name';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    ref.read(mcaCompanySearchProvider.notifier).search(query);
  }
}

// ---------------------------------------------------------------------------
// Search banner
// ---------------------------------------------------------------------------

class _SearchBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFFFF8F0)],
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
              Icons.corporate_fare_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Lookup',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enter a 21-character CIN or company name to view incorporation details, capital structure, and RoC information.',
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
// Company input
// ---------------------------------------------------------------------------

class _CompanyInput extends StatelessWidget {
  const _CompanyInput({
    required this.controller,
    required this.validationError,
    required this.onSearch,
  });

  final TextEditingController controller;
  final String? validationError;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'CIN or Company Name',
            hintText: 'e.g. L17110MH1973PLC019786',
            errorText: validationError,
            prefixIcon: const Icon(Icons.business_rounded, size: 20),
            suffixIcon: IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onSubmitted: (_) => onSearch(),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text('Search Company'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 12),
          Text(
            'Enter a CIN or company name above',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error card
// ---------------------------------------------------------------------------

class _SearchErrorCard extends StatelessWidget {
  const _SearchErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withAlpha(30)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
