import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/time_tracking/data/providers/time_tracking_providers.dart';

/// Active timer display with start / pause / stop controls.
class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(runningTimerProvider);
    final theme = Theme.of(context);

    if (timer.entryId == null) {
      return _IdleTimerCard(theme: theme);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: timer.isRunning
                        ? AppColors.success
                        : AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timer.isRunning ? 'Timer Running' : 'Timer Paused',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Elapsed time
            Text(
              timer.formattedElapsed,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            // Client + task
            if (timer.clientName != null)
              Text(
                timer.clientName!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (timer.taskDescription != null) ...[
              const SizedBox(height: 2),
              Text(
                timer.taskDescription!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            // Controls
            Row(
              children: [
                // Pause / Resume
                FilledButton.icon(
                  onPressed: () {
                    final notifier =
                        ref.read(runningTimerProvider.notifier);
                    if (timer.isRunning) {
                      notifier.pause();
                    } else {
                      notifier.resume();
                    }
                  },
                  icon: Icon(
                    timer.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  label: Text(timer.isRunning ? 'Pause' : 'Resume'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(51),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                // Stop
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(runningTimerProvider.notifier).stop();
                  },
                  icon: const Icon(Icons.stop_rounded, size: 20),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleTimerCard extends StatelessWidget {
  const _IdleTimerCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 32,
              color: AppColors.neutral400,
            ),
            const SizedBox(width: 12),
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
                    'Tap a time entry to start tracking',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
