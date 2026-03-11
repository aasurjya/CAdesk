import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ai_automation/data/providers/ai_automation_providers.dart';
import 'package:ca_app/features/ai_automation/data/providers/ai_simulation_providers.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/anomaly_alert.dart';

// ── Shared helpers ───────────────────────────────────────────────────────────

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.child, required this.accentColor});

  final Widget child;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor.withAlpha(14), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withAlpha(60)),
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: isDone
                ? const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.success,
                  )
                : isActive
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: AppColors.neutral300,
                  ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive || isDone
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: isDone
                  ? AppColors.success
                  : isActive
                  ? AppColors.neutral900
                  : AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── OCR Scan Demo Card ───────────────────────────────────────────────────────

class AiScanDemoCard extends ConsumerStatefulWidget {
  const AiScanDemoCard({super.key});

  @override
  ConsumerState<AiScanDemoCard> createState() => _AiScanDemoCardState();
}

class _AiScanDemoCardState extends ConsumerState<AiScanDemoCard> {
  static const _mockFields = [
    MapEntry('Document type', 'Form 16 — Part A & B'),
    MapEntry('Employer', 'Infosys Ltd'),
    MapEntry('Employee PAN', 'BGHPS9876K'),
    MapEntry('Gross salary', '₹32,40,000'),
    MapEntry('Tax deducted (TDS)', '₹4,68,200'),
    MapEntry('Section 80C', '₹1,50,000'),
  ];

  final List<Timer> _timers = [];

  void _runSimulation() {
    final notifier = ref.read(scanSimProvider.notifier);
    notifier.start();

    _timers.add(
      Timer(const Duration(milliseconds: 1200), () {
        notifier.advance(ScanSimStep.detecting);
      }),
    );
    _timers.add(
      Timer(const Duration(milliseconds: 2200), () {
        notifier.advance(ScanSimStep.extracting);
      }),
    );
    for (int i = 0; i < _mockFields.length; i++) {
      _timers.add(
        Timer(Duration(milliseconds: 2700 + i * 420), () {
          notifier.showFields(i + 1);
        }),
      );
    }
    _timers.add(
      Timer(Duration(milliseconds: 2700 + _mockFields.length * 420 + 200), () {
        notifier.advance(ScanSimStep.validating);
      }),
    );
    _timers.add(
      Timer(Duration(milliseconds: 2700 + _mockFields.length * 420 + 1000), () {
        notifier.complete(0.974);
        // Push new scan into the list
        final scans = ref.read(allScanResultsProvider);
        final newScan = AiScanResult(
          id: 'scan-demo-${DateTime.now().millisecondsSinceEpoch}',
          documentName: 'Arjun_Kapoor_Form16_2026.pdf',
          documentType: DocumentType.form16,
          extractedData: {for (final e in _mockFields) e.key: e.value},
          confidence: 0.974,
          scannedAt: DateTime.now(),
          status: ScanStatus.completed,
          clientName: 'Arjun Kapoor',
        );
        ref.read(allScanResultsProvider.notifier).update([newScan, ...scans]);
      }),
    );
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(scanSimProvider);
    final theme = Theme.of(context);

    return _DemoCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI OCR Demo',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Live document extraction simulation',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              if (sim.isDone)
                TextButton(
                  onPressed: () {
                    for (final t in _timers) {
                      t.cancel();
                    }
                    _timers.clear();
                    ref.read(scanSimProvider.notifier).reset();
                  },
                  child: const Text('Reset'),
                ),
            ],
          ),

          if (sim.isIdle) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _runSimulation,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Run AI Scan Demo'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          if (sim.isRunning || sim.isDone) ...[
            const SizedBox(height: 16),
            _StepRow(
              label: 'Uploading document...',
              isDone: sim.step.index > ScanSimStep.uploading.index,
              isActive: sim.step == ScanSimStep.uploading,
            ),
            _StepRow(
              label: 'Detecting document type (AI classifier)...',
              isDone: sim.step.index > ScanSimStep.detecting.index,
              isActive: sim.step == ScanSimStep.detecting,
            ),
            _StepRow(
              label: 'Extracting fields with AI OCR...',
              isDone: sim.step.index > ScanSimStep.extracting.index,
              isActive: sim.step == ScanSimStep.extracting,
            ),

            if (sim.step.index >= ScanSimStep.extracting.index &&
                sim.visibleFieldCount > 0) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(left: 28),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral100),
                ),
                child: Column(
                  children: [
                    for (
                      int i = 0;
                      i < sim.visibleFieldCount && i < _mockFields.length;
                      i++
                    )
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                _mockFields[i].key,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _mockFields[i].value,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${(97 - i).clamp(90, 99)}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],

            _StepRow(
              label: 'Validating with confidence model...',
              isDone: sim.isDone,
              isActive: sim.step == ScanSimStep.validating,
            ),

            if (sim.isDone) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Extraction complete — ${(sim.confidence * 100).toStringAsFixed(1)}% accuracy',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Added to scan queue · Scroll up to see result',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Bank Reconciliation Demo Card ────────────────────────────────────────────

class AiReconDemoCard extends ConsumerStatefulWidget {
  const AiReconDemoCard({super.key});

  @override
  ConsumerState<AiReconDemoCard> createState() => _AiReconDemoCardState();
}

class _AiReconDemoCardState extends ConsumerState<AiReconDemoCard> {
  Timer? _ticker;

  void _runSimulation() {
    final notifier = ref.read(reconSimProvider.notifier);
    notifier.start();

    const stepSize = 83; // ~15 ticks to reach 1247
    _ticker = Timer.periodic(const Duration(milliseconds: 180), (t) {
      final sim = ref.read(reconSimProvider);
      if (!mounted) {
        t.cancel();
        return;
      }
      final next = (sim.matched + stepSize).clamp(0, sim.total);
      if (next >= sim.total) {
        notifier.complete();
        t.cancel();
      } else {
        notifier.setMatched(next);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(reconSimProvider);
    final theme = Theme.of(context);

    return _DemoCard(
      accentColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 20,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Reconciliation Demo',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'Watch AI match 1,247 transactions live',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              if (sim.isDone)
                TextButton(
                  onPressed: () {
                    _ticker?.cancel();
                    ref.read(reconSimProvider.notifier).reset();
                  },
                  child: const Text('Reset'),
                ),
            ],
          ),

          if (sim.isIdle) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _runSimulation,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Start AI Reconciliation Demo'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          if (sim.isRunning || sim.isDone) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Matching transactions...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  '${sim.matched} / ${sim.total}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: sim.progress,
                backgroundColor: AppColors.neutral100,
                color: AppColors.secondary,
                minHeight: 8,
              ),
            ),

            if (sim.matched > 100) ...[
              const SizedBox(height: 16),
              _ReconStatRow(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                label: 'Auto-matched by AI',
                value: sim.autoMatchedCount,
                total: sim.total,
              ),
              const SizedBox(height: 6),
              _ReconStatRow(
                icon: Icons.edit_rounded,
                color: AppColors.warning,
                label: 'Manual review needed',
                value: sim.manualCount,
                total: sim.total,
              ),
              const SizedBox(height: 6),
              _ReconStatRow(
                icon: Icons.help_outline_rounded,
                color: AppColors.neutral400,
                label: 'Unmatched',
                value: sim.unmatchedCount,
                total: sim.total,
              ),
            ],

            if (sim.isDone) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.savings_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI saved ~8.4 hours of manual matching work',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ReconStatRow extends StatelessWidget {
  const _ReconStatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total * 100).toStringAsFixed(0) : '0';
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
        ),
        Text(
          '$value  ($pct%)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ── Anomaly Detection Demo Card ──────────────────────────────────────────────

class AiAnomalyDemoCard extends ConsumerStatefulWidget {
  const AiAnomalyDemoCard({super.key});

  @override
  ConsumerState<AiAnomalyDemoCard> createState() => _AiAnomalyDemoCardState();
}

class _AiAnomalyDemoCardState extends ConsumerState<AiAnomalyDemoCard> {
  final List<Timer> _timers = [];

  void _runSimulation() {
    final notifier = ref.read(anomalySimProvider.notifier);
    notifier.start();

    // Scan counter: 0 → 2847 over ~2.5 seconds, step ~142 every 125ms
    const scanStep = 142;
    int tick = 0;
    _timers.add(
      Timer.periodic(const Duration(milliseconds: 125), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        tick++;
        final next = (tick * scanStep).clamp(0, 2847);
        ref.read(anomalySimProvider.notifier).setScanned(next);
        if (next >= 2847) {
          t.cancel();
          _startTypewriting();
        }
      }),
    );
  }

  void _startTypewriting() {
    final notifier = ref.read(anomalySimProvider.notifier);
    notifier.startTypewriting();

    final full = ref.read(anomalySimProvider).description;
    int chars = 0;
    _timers.add(
      Timer.periodic(const Duration(milliseconds: 22), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        chars = (chars + 2).clamp(0, full.length);
        notifier.typeChar(chars);
        if (chars >= full.length) {
          t.cancel();
          Future.delayed(const Duration(milliseconds: 600), () {
            if (!mounted) return;
            notifier.complete();
            _addAnomalyToList();
          });
        }
      }),
    );
  }

  void _addAnomalyToList() {
    final alerts = ref.read(allAnomalyAlertsProvider);
    final newAlert = AnomalyAlert(
      id: 'anomaly-demo-${DateTime.now().millisecondsSinceEpoch}',
      clientId: 'client-demo',
      clientName: 'Pradeep Industries',
      transactionId: 'txn-demo-9901',
      alertType: AlertType.unusualAmount,
      severity: AlertSeverity.critical,
      description:
          'Suspicious cash deposit of ₹3.5L detected on 8 Mar — 6× above '
          'the 6-month pattern average. Possible round-trip transaction or '
          'undisclosed income. Recommend immediate client query.',
      detectedAt: DateTime.now(),
      isResolved: false,
      amountInr: 350000,
    );
    ref.read(allAnomalyAlertsProvider.notifier).update([newAlert, ...alerts]);
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(anomalySimProvider);
    final theme = Theme.of(context);

    return _DemoCard(
      accentColor: AppColors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Anomaly Scan Demo',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      'AI scans 2,847 transactions for irregularities',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              if (sim.isDone)
                TextButton(
                  onPressed: () {
                    for (final t in _timers) {
                      t.cancel();
                    }
                    _timers.clear();
                    ref.read(anomalySimProvider.notifier).reset();
                  },
                  child: const Text('Reset'),
                ),
            ],
          ),

          if (sim.isIdle) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _runSimulation,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Run AI Anomaly Scan Demo'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          if (sim.step == AnomalySimStep.scanning) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scanning transactions...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  '${sim.scannedCount} / ${sim.total}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: sim.progress,
                backgroundColor: AppColors.neutral100,
                color: AppColors.accent,
                minHeight: 8,
              ),
            ),
          ],

          if (sim.step == AnomalySimStep.typewriting ||
              sim.step == AnomalySimStep.complete) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828).withAlpha(12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFC62828).withAlpha(60),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFC62828),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'CRITICAL anomaly detected!',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sim.visibleText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral900,
                      height: 1.5,
                    ),
                  ),
                  if (sim.step == AnomalySimStep.typewriting)
                    const _BlinkingCursor(),
                ],
              ),
            ),

            if (sim.isDone) ...[
              const SizedBox(height: 10),
              Text(
                'Alert added to queue · Scroll up to review',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: const Text(
        '▋',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFFC62828),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
