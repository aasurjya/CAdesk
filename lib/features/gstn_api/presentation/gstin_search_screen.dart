import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/gstn_api/data/providers/gstn_api_providers.dart';
import 'package:ca_app/features/gstn_api/presentation/widgets/gstin_result_card.dart';

/// GSTIN validation and search screen with format validation.
class GstinSearchScreen extends ConsumerStatefulWidget {
  const GstinSearchScreen({super.key});

  @override
  ConsumerState<GstinSearchScreen> createState() => _GstinSearchScreenState();
}

class _GstinSearchScreenState extends ConsumerState<GstinSearchScreen> {
  final _controller = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(gstinSearchResultProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GSTIN Search',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Verify any GST registration',
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
            _GstinInput(
              controller: _controller,
              validationError: _validationError,
              onSearch: _handleSearch,
            ),
            const SizedBox(height: 16),
            searchResult.when(
              data: (result) {
                if (result == null) {
                  return _EmptyState();
                }
                return GstinResultCard(result: result);
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
    final gstin = _controller.text.trim().toUpperCase();
    final error = _validateGstin(gstin);

    setState(() {
      _validationError = error;
    });

    if (error != null) return;

    ref.read(gstinSearchResultProvider.notifier).search(gstin);
  }

  String? _validateGstin(String gstin) {
    if (gstin.isEmpty) return 'Please enter a GSTIN';
    if (gstin.length != 15) return 'GSTIN must be exactly 15 characters';

    // Basic GSTIN pattern: 2-digit state + 10-char PAN + 1-digit entity + Z + check
    final pattern = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9Z][A-Z][0-9A-Z]$',
    );
    if (!pattern.hasMatch(gstin)) {
      return 'Invalid GSTIN format';
    }

    return null;
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
              color: AppColors.secondary.withAlpha(18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GSTIN Verification',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enter a 15-character GSTIN to verify registration details, status, and filing frequency.',
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
// GSTIN input
// ---------------------------------------------------------------------------

class _GstinInput extends StatelessWidget {
  const _GstinInput({
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
          maxLength: 15,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'GSTIN',
            hintText: 'e.g. 27AADCR0000A1Z5',
            errorText: validationError,
            prefixIcon: const Icon(Icons.pin_rounded, size: 20),
            suffixIcon: IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterText: '',
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
          label: const Text('Verify GSTIN'),
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
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.neutral300),
          const SizedBox(height: 12),
          Text(
            'Enter a GSTIN above to search',
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
