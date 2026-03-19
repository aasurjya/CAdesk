import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';

/// Notes tab for the Client 360 screen.
///
/// Displays the client's notes in a read-only card with an "Edit Notes"
/// button that opens a bottom sheet for editing. Updates are propagated
/// through the [AllClientsNotifier] using immutable [Client.copyWith].
class NotesTab extends ConsumerWidget {
  const NotesTab({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientByIdProvider(clientId));

    if (client == null) {
      return const Center(child: Text('Client not found.'));
    }

    final theme = Theme.of(context);
    final hasNotes = client.notes != null && client.notes!.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Client Notes',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          _showEditNotesSheet(context, ref, client),
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Edit'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Text(
                    hasNotes ? client.notes! : 'No notes added yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasNotes
                          ? AppColors.neutral600
                          : AppColors.neutral400,
                      fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  void _showEditNotesSheet(BuildContext context, WidgetRef ref, Client client) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.md),
        ),
      ),
      builder: (sheetContext) => _EditNotesSheet(
        initialNotes: client.notes ?? '',
        onSave: (newNotes) {
          final updated = client.copyWith(notes: newNotes);
          ref.read(allClientsProvider.notifier).updateClient(updated);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit notes bottom sheet
// ---------------------------------------------------------------------------

class _EditNotesSheet extends StatefulWidget {
  const _EditNotesSheet({required this.initialNotes, required this.onSave});

  final String initialNotes;
  final ValueChanged<String> onSave;

  @override
  State<_EditNotesSheet> createState() => _EditNotesSheetState();
}

class _EditNotesSheetState extends State<_EditNotesSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: bottomInset + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
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
          const SizedBox(height: AppSpacing.md),
          Text(
            'Edit Notes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Add client notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.sm),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppSpacing.xs),
              FilledButton(
                onPressed: () => widget.onSave(_controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
