import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ai_automation/data/providers/ai_automation_providers.dart';
import 'package:ca_app/features/ai_automation/data/providers/ai_simulation_providers.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/anomaly_alert.dart';

/// Full-screen investor demo sheet that auto-runs all 3 AI simulations.
void showLiveDemoSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LiveDemoSheet(),
  );
}

class _LiveDemoSheet extends ConsumerStatefulWidget {
  const _LiveDemoSheet();

  @override
  ConsumerState<_LiveDemoSheet> createState() => _LiveDemoSheetState();
}

class _LiveDemoSheetState extends ConsumerState<_LiveDemoSheet> {
  final List<Timer> _timers = [];
  bool _started = false;

  // ── OCR fields ──────────────────────────────────────────────────────────

  static const _ocrFields = [
    MapEntry('Document type', 'Form 16 — Part A & B'),
    MapEntry('Employer', 'Infosys Ltd'),
    MapEntry('Employee PAN', 'BGHPS9876K'),
    MapEntry('Gross salary', '₹32,40,000'),
    MapEntry('Tax deducted (TDS)', '₹4,68,200'),
    MapEntry('Section 80C', '₹1,50,000'),
  ];

  // ── Anomaly typewriter text ──────────────────────────────────────────────

  static const _anomalyDesc =
      'Suspicious cash deposit of ₹3.5L detected in Pradeep Industries on '
      '8 Mar — 6× above the 6-month pattern average. Possible round-trip '
      'transaction or undisclosed income. Recommend immediate client query.';

  void _startAll() {
    if (_started) return;
    _started = true;

    _runOcr();
    _runRecon();
    _runAnomaly();
  }

  // ── OCR simulation ───────────────────────────────────────────────────────

  void _runOcr() {
    final n = ref.read(scanSimProvider.notifier);
    n.start();

    _at(1200, () => n.advance(ScanSimStep.detecting));
    _at(2200, () => n.advance(ScanSimStep.extracting));
    for (int i = 0; i < _ocrFields.length; i++) {
      _at(2700 + i * 420, () => n.showFields(i + 1));
    }
    final extractDone = 2700 + _ocrFields.length * 420 + 200;
    _at(extractDone, () => n.advance(ScanSimStep.validating));
    _at(extractDone + 800, () {
      n.complete(0.974);
      _pushScan();
    });
  }

  void _pushScan() {
    final scans = ref.read(allScanResultsProvider);
    final newScan = AiScanResult(
      id: 'scan-demo-${DateTime.now().millisecondsSinceEpoch}',
      documentName: 'Arjun_Kapoor_Form16_2026.pdf',
      documentType: DocumentType.form16,
      extractedData: {for (final e in _ocrFields) e.key: e.value},
      confidence: 0.974,
      scannedAt: DateTime.now(),
      status: ScanStatus.completed,
      clientName: 'Arjun Kapoor',
    );
    ref.read(allScanResultsProvider.notifier).update([newScan, ...scans]);
  }

  // ── Reconciliation simulation ────────────────────────────────────────────

  void _runRecon() {
    final n = ref.read(reconSimProvider.notifier);
    n.start();

    const step = 83;
    int tick = 0;
    _timers.add(
      Timer.periodic(const Duration(milliseconds: 180), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        tick++;
        final next = (tick * step).clamp(0, 1247);
        n.setMatched(next);
        if (next >= 1247) {
          n.complete();
          t.cancel();
        }
      }),
    );
  }

  // ── Anomaly simulation ───────────────────────────────────────────────────

  void _runAnomaly() {
    final n = ref.read(anomalySimProvider.notifier);
    n.start();

    int tick = 0;
    _timers.add(
      Timer.periodic(const Duration(milliseconds: 125), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        tick++;
        final next = (tick * 142).clamp(0, 2847);
        n.setScanned(next);
        if (next >= 2847) {
          t.cancel();
          n.startTypewriting();
          _typeAnomaly();
        }
      }),
    );
  }

  void _typeAnomaly() {
    int chars = 0;
    _timers.add(
      Timer.periodic(const Duration(milliseconds: 22), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        chars = (chars + 2).clamp(0, _anomalyDesc.length);
        ref.read(anomalySimProvider.notifier).typeChar(chars);
        if (chars >= _anomalyDesc.length) {
          t.cancel();
          Future.delayed(const Duration(milliseconds: 600), () {
            if (!mounted) return;
            ref.read(anomalySimProvider.notifier).complete();
            _pushAnomaly();
          });
        }
      }),
    );
  }

  void _pushAnomaly() {
    final alerts = ref.read(allAnomalyAlertsProvider);
    final a = AnomalyAlert(
      id: 'anomaly-demo-${DateTime.now().millisecondsSinceEpoch}',
      clientId: 'client-demo',
      clientName: 'Pradeep Industries',
      transactionId: 'txn-demo-9901',
      alertType: AlertType.unusualAmount,
      severity: AlertSeverity.critical,
      description: _anomalyDesc,
      detectedAt: DateTime.now(),
      isResolved: false,
      amountInr: 350000,
    );
    ref.read(allAnomalyAlertsProvider.notifier).update([a, ...alerts]);
  }

  void _resetAll() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _started = false;
    ref.read(scanSimProvider.notifier).reset();
    ref.read(reconSimProvider.notifier).reset();
    ref.read(anomalySimProvider.notifier).reset();
  }

  void _at(int ms, VoidCallback fn) {
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted) fn();
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    // Auto-start after a brief pause so the sheet finishes animating in
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startAll();
    });
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
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ───────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CADesk AI — Live Demo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        'All 3 AI engines running simultaneously',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                _ReplayButton(
                  onReplay: () {
                    _resetAll();
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      _startAll,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // ── Three panels ─────────────────────────────────────────────────
          const Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  _OcrPanel(fields: _ocrFields),
                  SizedBox(height: 12),
                  _ReconPanel(),
                  SizedBox(height: 12),
                  _AnomalyPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Replay button ─────────────────────────────────────────────────────────────

class _ReplayButton extends StatelessWidget {
  const _ReplayButton({required this.onReplay});

  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onReplay,
      icon: const Icon(Icons.replay_rounded, size: 16),
      label: const Text('Replay'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Panel base ────────────────────────────────────────────────────────────────

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
    required this.isDone,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? color.withAlpha(80) : AppColors.neutral100,
          width: isDone ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(isDone ? 20 : 0),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _PulsingDot(color: color),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ── Pulsing "live" dot ───────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Live',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── OCR panel ─────────────────────────────────────────────────────────────────

class _OcrPanel extends ConsumerWidget {
  const _OcrPanel({required this.fields});

  final List<MapEntry<String, String>> fields;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sim = ref.watch(scanSimProvider);
    final theme = Theme.of(context);

    return _Panel(
      title: 'AI Document OCR',
      subtitle: 'Extracting Form 16 fields in real-time',
      icon: Icons.document_scanner_rounded,
      color: AppColors.primary,
      isDone: sim.isDone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OcrStep(
            'Uploading document',
            isDone: sim.step.index > ScanSimStep.uploading.index,
            isActive: sim.step == ScanSimStep.uploading,
          ),
          _OcrStep(
            'Detecting document type (AI classifier)',
            isDone: sim.step.index > ScanSimStep.detecting.index,
            isActive: sim.step == ScanSimStep.detecting,
          ),
          _OcrStep(
            'Extracting fields',
            isDone: sim.step.index > ScanSimStep.extracting.index,
            isActive: sim.step == ScanSimStep.extracting,
          ),

          if (sim.visibleFieldCount > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neutral100),
              ),
              child: Column(
                children: [
                  for (
                    int i = 0;
                    i < sim.visibleFieldCount && i < fields.length;
                    i++
                  )
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              fields[i].key,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              fields[i].value,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
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

          _OcrStep(
            'Validating with confidence model',
            isDone: sim.isDone,
            isActive: sim.step == ScanSimStep.validating,
          ),

          if (sim.isDone) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(sim.confidence * 100).toStringAsFixed(1)}% accuracy · 6 fields extracted',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OcrStep extends StatelessWidget {
  const _OcrStep(this.label, {required this.isDone, required this.isActive});

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

// ── Reconciliation panel ──────────────────────────────────────────────────────

class _ReconPanel extends ConsumerWidget {
  const _ReconPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sim = ref.watch(reconSimProvider);
    final theme = Theme.of(context);

    return _Panel(
      title: 'AI Bank Reconciliation',
      subtitle: '1,247 transactions matched automatically',
      icon: Icons.account_balance_rounded,
      color: AppColors.secondary,
      isDone: sim.isDone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Matching transactions...',
                style: theme.textTheme.bodySmall?.copyWith(
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

          if (sim.matched > 80) ...[
            const SizedBox(height: 14),
            _ReconRow(
              Icons.check_circle_rounded,
              AppColors.success,
              'Auto-matched by AI',
              sim.autoMatchedCount,
              sim.total,
            ),
            const SizedBox(height: 6),
            _ReconRow(
              Icons.edit_rounded,
              AppColors.warning,
              'Manual review',
              sim.manualCount,
              sim.total,
            ),
            const SizedBox(height: 6),
            _ReconRow(
              Icons.help_outline_rounded,
              AppColors.neutral400,
              'Unmatched',
              sim.unmatchedCount,
              sim.total,
            ),
          ],

          if (sim.isDone) ...[
            const SizedBox(height: 12),
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
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI saved ~8.4 hours of manual matching',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReconRow extends StatelessWidget {
  const _ReconRow(this.icon, this.color, this.label, this.value, this.total);

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
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
        ),
        Text(
          '$value  ($pct%)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

// ── Anomaly panel ─────────────────────────────────────────────────────────────

class _AnomalyPanel extends ConsumerWidget {
  const _AnomalyPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sim = ref.watch(anomalySimProvider);
    final theme = Theme.of(context);

    return _Panel(
      title: 'AI Anomaly Detection',
      subtitle: 'Scanning 2,847 transactions for irregularities',
      icon: Icons.warning_amber_rounded,
      color: AppColors.accent,
      isDone: sim.isDone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scanning transactions...',
                style: theme.textTheme.bodySmall?.copyWith(
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

          if (sim.step == AnomalySimStep.typewriting ||
              sim.step == AnomalySimStep.complete) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828).withAlpha(10),
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
                        size: 16,
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
                    const _BlinkCursor(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlinkCursor extends StatefulWidget {
  const _BlinkCursor();

  @override
  State<_BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<_BlinkCursor>
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
          fontWeight: FontWeight.w700,
          color: Color(0xFFC62828),
        ),
      ),
    );
  }
}
