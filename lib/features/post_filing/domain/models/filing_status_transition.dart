import 'filing_status.dart';

/// Immutable record of a single state transition in the ITR filing lifecycle.
class FilingStatusTransition {
  const FilingStatusTransition({
    required this.fromState,
    required this.toState,
    required this.transitionedAt,
    required this.reason,
  });

  final FilingState fromState;
  final FilingState toState;
  final DateTime transitionedAt;
  final String reason;

  FilingStatusTransition copyWith({
    FilingState? fromState,
    FilingState? toState,
    DateTime? transitionedAt,
    String? reason,
  }) {
    return FilingStatusTransition(
      fromState: fromState ?? this.fromState,
      toState: toState ?? this.toState,
      transitionedAt: transitionedAt ?? this.transitionedAt,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingStatusTransition &&
        other.fromState == fromState &&
        other.toState == toState &&
        other.transitionedAt == transitionedAt &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(fromState, toState, transitionedAt, reason);
}
