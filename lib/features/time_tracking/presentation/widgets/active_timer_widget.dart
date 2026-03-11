import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/time_tracking/data/providers/time_tracking_providers.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';
import 'package:ca_app/features/time_tracking/presentation/widgets/start_timer_sheet.dart';

/// Prominent timer card — always visible at the top of the time-tracking screen.
///
/// States:
///   - Idle   → "Start Timer" button that opens [StartTimerSheet]
///   - Running → shows HH:MM:SS, billable amount, [Pause] [Stop & Save]
///   - Paused  → same display, [Resume] [Stop & Save]
class ActiveTimerWidget extends ConsumerStatefulWidget {
  const ActiveTimerWidget({super.key});

  @override
  ConsumerState<ActiveTimerWidget> createState() => _ActiveTimerWidgetState();
}

class _ActiveTimerWidgetState extends ConsumerState<ActiveTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(activeTimerProvider);
    final theme = Theme.of(context);

    final bool isIdle = timer.startedAt == null && timer.elapsedSeconds == 0;

    if (isIdle) {
      return _IdleCard(theme: theme);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecordingIndicator(
              isRunning: timer.isRunning,
              pulseAnimation: _pulseAnimation,
              theme: theme,
            ),
            const SizedBox(height: 10),
            // HH:MM:SS display
            Text(
              timer.formattedTime,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            // Client + task
            if (timer.clientName.isNotEmpty)
              Text(
                timer.clientName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (timer.taskDescription.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                timer.taskDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            // Billable running total
            Row(
              children: [
                Text(
                  _formatInr(timer.billableAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '@ ${_formatInr(timer.billingRate)}/hr',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Controls
            _TimerControls(timer: timer),
          ],
        ),
      ),
    );
  }

  static String _formatInr(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

// ---------------------------------------------------------------------------
// Recording indicator row
// ---------------------------------------------------------------------------

class _RecordingIndicator extends StatelessWidget {
  const _RecordingIndicator({
    required this.isRunning,
    required this.pulseAnimation,
    required this.theme,
  });

  final bool isRunning;
  final Animation<double> pulseAnimation;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isRunning)
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, _) {
              return Opacity(
                opacity: pulseAnimation.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          isRunning ? '● RECORDING' : '⏸ PAUSED',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Timer controls
// ---------------------------------------------------------------------------

class _TimerControls extends ConsumerWidget {
  const _TimerControls({required this.timer});

  final ActiveTimerState timer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Pause / Resume
        FilledButton.icon(
          onPressed: () {
            final notifier = ref.read(activeTimerProvider.notifier);
            if (timer.isRunning) {
              notifier.pause();
            } else {
              notifier.resume();
            }
          },
          icon: Icon(
            timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 20,
          ),
          label: Text(timer.isRunning ? 'Pause' : 'Resume'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white.withAlpha(51),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        // Stop & Save
        OutlinedButton.icon(
          onPressed: () => _stopAndSave(context, ref, timer),
          icon: const Icon(Icons.stop_rounded, size: 20),
          label: const Text('Stop & Save'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  void _stopAndSave(
    BuildContext context,
    WidgetRef ref,
    ActiveTimerState timerState,
  ) {
    final seconds = timerState.elapsedSeconds;
    final durationMinutes = (seconds / 60).ceil();
    final billedAmount = timerState.billableAmount;

    final entry = TimeEntry(
      id: 'te-${DateTime.now().millisecondsSinceEpoch}',
      staffId: 'staff-me',
      staffName: 'Me',
      clientId: 'timer-client',
      clientName: timerState.clientName,
      taskDescription: timerState.taskDescription,
      startTime: timerState.startedAt ?? DateTime.now(),
      endTime: DateTime.now(),
      durationMinutes: durationMinutes,
      isBillable: timerState.billingRate > 0,
      hourlyRate: timerState.billingRate,
      billedAmount: billedAmount,
      status: TimeEntryStatus.completed,
    );

    ref.read(timeEntriesProvider.notifier).addEntry(entry);
    ref.read(activeTimerProvider.notifier).stop();

    if (context.mounted) {
      final formatted = billedAmount >= 1000
          ? '₹${(billedAmount / 1000).toStringAsFixed(1)}K'
          : '₹${billedAmount.toStringAsFixed(0)}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved $formatted for ${timerState.clientName}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Idle card
// ---------------------------------------------------------------------------

class _IdleCard extends StatelessWidget {
  const _IdleCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, size: 36, color: AppColors.neutral400),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Timer Running',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Track billable hours in real time',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _openStartSheet(context),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Start'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStartSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const StartTimerSheet(),
    );
  }
}
