import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/industry_playbooks/data/providers/industry_playbooks_providers.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/vertical_playbook.dart';
import 'package:ca_app/features/industry_playbooks/presentation/widgets/service_bundle_tile.dart';

/// Card widget displaying a single [VerticalPlaybook].
///
/// Tapping the card opens a modal bottom sheet with full playbook details
/// and all associated service bundles.
class PlaybookCard extends ConsumerWidget {
  const PlaybookCard({required this.playbook, super.key});

  final VerticalPlaybook playbook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailSheet(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildMetricsRow(),
              const SizedBox(height: 10),
              _buildMarginBar(),
              const SizedBox(height: 10),
              _buildChecklistChips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(playbook.icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            playbook.vertical
                .split('-')
                .map((w) => w[0].toUpperCase() + w.substring(1))
                .join(' '),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        _MetricChip(
          label: 'Clients',
          value: '${playbook.activeClients}',
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        _MetricChip(
          label: 'Retainer',
          value: '₹${playbook.avgRetainerValue.toStringAsFixed(1)}L',
          color: AppColors.secondary,
        ),
        const SizedBox(width: 8),
        _MetricChip(
          label: 'Win Rate',
          value: '${(playbook.winRate * 100).toStringAsFixed(0)}%',
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildMarginBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Margin',
              style: TextStyle(fontSize: 11, color: AppColors.neutral600),
            ),
            Text(
              '${(playbook.marginPercent * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: playbook.marginPercent,
            minHeight: 6,
            backgroundColor: AppColors.neutral200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistChips() {
    final visibleItems = playbook.complianceChecklist.take(2).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: visibleItems.map((item) {
        return Chip(
          label: Text(
            item,
            style: const TextStyle(fontSize: 10, color: AppColors.primary),
          ),
          backgroundColor: AppColors.primary.withAlpha(20),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref) {
    final bundles = ref.read(bundlesForVerticalProvider(playbook.id));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(playbook.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    playbook.vertical
                        .split('-')
                        .map((w) => w[0].toUpperCase() + w.substring(1))
                        .join(' '),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              playbook.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _SheetSection(
              title: 'Compliance Checklist',
              icon: Icons.checklist_rounded,
              iconColor: AppColors.success,
              children: playbook.complianceChecklist
                  .map(
                    (item) => _BulletItem(text: item, color: AppColors.success),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            _SheetSection(
              title: 'Typical Risks',
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
              children: playbook.typicalRisks
                  .map((r) => _BulletItem(text: r, color: AppColors.warning))
                  .toList(),
            ),
            if (bundles.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Available Service Bundles',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              ...bundles.map((b) => ServiceBundleTile(bundle: b)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
