import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── OCR Scan Simulation ──────────────────────────────────────────────────────

enum ScanSimStep {
  idle,
  uploading,
  detecting,
  extracting,
  validating,
  complete,
}

class ScanSimState {
  const ScanSimState({
    this.step = ScanSimStep.idle,
    this.visibleFieldCount = 0,
    this.confidence = 0.0,
  });

  final ScanSimStep step;
  final int visibleFieldCount;
  final double confidence;

  bool get isIdle => step == ScanSimStep.idle;
  bool get isRunning =>
      step != ScanSimStep.idle && step != ScanSimStep.complete;
  bool get isDone => step == ScanSimStep.complete;

  ScanSimState copyWith({
    ScanSimStep? step,
    int? visibleFieldCount,
    double? confidence,
  }) => ScanSimState(
    step: step ?? this.step,
    visibleFieldCount: visibleFieldCount ?? this.visibleFieldCount,
    confidence: confidence ?? this.confidence,
  );
}

final scanSimProvider = NotifierProvider<ScanSimNotifier, ScanSimState>(
  ScanSimNotifier.new,
);

class ScanSimNotifier extends Notifier<ScanSimState> {
  @override
  ScanSimState build() => const ScanSimState();

  void start() => state = const ScanSimState(
    step: ScanSimStep.uploading,
    visibleFieldCount: 0,
  );

  void advance(ScanSimStep to) => state = state.copyWith(step: to);

  void showFields(int count) =>
      state = state.copyWith(visibleFieldCount: count);

  void complete(double confidence) => state = state.copyWith(
    step: ScanSimStep.complete,
    confidence: confidence,
  );

  void reset() => state = const ScanSimState();
}

// ── Bank Reconciliation Simulation ──────────────────────────────────────────

enum ReconSimStep { idle, running, complete }

class ReconSimState {
  const ReconSimState({
    this.step = ReconSimStep.idle,
    this.matched = 0,
    this.total = 1247,
  });

  final ReconSimStep step;
  final int matched;
  final int total;

  bool get isIdle => step == ReconSimStep.idle;
  bool get isRunning => step == ReconSimStep.running;
  bool get isDone => step == ReconSimStep.complete;
  double get progress => total > 0 ? matched / total : 0;

  int get autoMatchedCount => (matched * 0.87).round();
  int get manualCount => (matched * 0.10).round();
  int get unmatchedCount =>
      (matched - autoMatchedCount - manualCount).clamp(0, matched);

  ReconSimState copyWith({ReconSimStep? step, int? matched}) => ReconSimState(
    step: step ?? this.step,
    matched: matched ?? this.matched,
    total: total,
  );
}

final reconSimProvider = NotifierProvider<ReconSimNotifier, ReconSimState>(
  ReconSimNotifier.new,
);

class ReconSimNotifier extends Notifier<ReconSimState> {
  @override
  ReconSimState build() => const ReconSimState();

  void start() =>
      state = const ReconSimState(step: ReconSimStep.running, matched: 0);

  void setMatched(int count) => state = state.copyWith(matched: count);

  void complete() =>
      state = state.copyWith(step: ReconSimStep.complete, matched: state.total);

  void reset() => state = const ReconSimState();
}

// ── Anomaly Scan Simulation ──────────────────────────────────────────────────

enum AnomalySimStep { idle, scanning, typewriting, complete }

class AnomalySimState {
  const AnomalySimState({
    this.step = AnomalySimStep.idle,
    this.scannedCount = 0,
    this.total = 2847,
    this.description = '',
    this.visibleChars = 0,
  });

  final AnomalySimStep step;
  final int scannedCount;
  final int total;
  final String description;
  final int visibleChars;

  bool get isIdle => step == AnomalySimStep.idle;
  bool get isRunning =>
      step == AnomalySimStep.scanning || step == AnomalySimStep.typewriting;
  bool get isDone => step == AnomalySimStep.complete;
  double get progress => total > 0 ? scannedCount / total : 0;

  String get visibleText =>
      description.substring(0, visibleChars.clamp(0, description.length));

  AnomalySimState copyWith({
    AnomalySimStep? step,
    int? scannedCount,
    String? description,
    int? visibleChars,
  }) => AnomalySimState(
    step: step ?? this.step,
    scannedCount: scannedCount ?? this.scannedCount,
    total: total,
    description: description ?? this.description,
    visibleChars: visibleChars ?? this.visibleChars,
  );
}

final anomalySimProvider =
    NotifierProvider<AnomalySimNotifier, AnomalySimState>(
      AnomalySimNotifier.new,
    );

class AnomalySimNotifier extends Notifier<AnomalySimState> {
  static const _detectedDescription =
      'Suspicious cash deposit of ₹3.5L detected in Pradeep Industries on '
      '8 Mar — 6× above the 6-month pattern average. Possible round-trip '
      'transaction or undisclosed income. Recommend immediate client query.';

  @override
  AnomalySimState build() => const AnomalySimState();

  void start() => state = const AnomalySimState(
    step: AnomalySimStep.scanning,
    scannedCount: 0,
  );

  void setScanned(int count) => state = state.copyWith(scannedCount: count);

  void startTypewriting() => state = state.copyWith(
    step: AnomalySimStep.typewriting,
    description: _detectedDescription,
    visibleChars: 0,
  );

  void typeChar(int chars) => state = state.copyWith(visibleChars: chars);

  void complete() => state = state.copyWith(step: AnomalySimStep.complete);

  void reset() => state = const AnomalySimState();
}
