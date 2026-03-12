import '../models/filing_status.dart';
import '../models/filing_status_transition.dart';

/// Events that drive the ITR filing state machine.
enum ItrFilingEvent {
  submitFiling,
  generateItrV,
  eVerify,
  cpcProcessed,
  refundInitiated,
  demandRaised,
  defectiveNotice,
  respond143_1,
}

/// Stateless service that manages the ITR filing lifecycle state machine.
///
/// All methods are pure functions — they return new [FilingStatus] instances
/// and never mutate the input.
///
/// State machine:
/// ```
/// draft → submitted → eVerificationPending → eVerified
///       → processing → processed
///       → defective | intimationIssued | refundInitiated | demandRaised
/// ```
class ItrStatusTracker {
  ItrStatusTracker._();

  static final instance = ItrStatusTracker._();

  // ---------------------------------------------------------------------------
  // Allowed transitions: Map<current state, Map<event, next state>>
  // ---------------------------------------------------------------------------
  static const _transitions =
      <FilingState, Map<ItrFilingEvent, FilingState>>{
    FilingState.draft: {
      ItrFilingEvent.submitFiling: FilingState.submitted,
    },
    FilingState.submitted: {
      ItrFilingEvent.generateItrV: FilingState.eVerificationPending,
    },
    FilingState.eVerificationPending: {
      ItrFilingEvent.eVerify: FilingState.eVerified,
    },
    FilingState.eVerified: {
      ItrFilingEvent.cpcProcessed: FilingState.processing,
    },
    FilingState.processing: {
      ItrFilingEvent.cpcProcessed: FilingState.processed,
      ItrFilingEvent.defectiveNotice: FilingState.defective,
    },
    FilingState.processed: {
      ItrFilingEvent.refundInitiated: FilingState.refundInitiated,
      ItrFilingEvent.demandRaised: FilingState.demandRaised,
      ItrFilingEvent.respond143_1: FilingState.intimationIssued,
    },
  };

  // ---------------------------------------------------------------------------
  // Terminal states — no further transitions expected.
  // ---------------------------------------------------------------------------
  static const _terminalStates = {
    FilingState.refundInitiated,
    FilingState.demandRaised,
    FilingState.defective,
    FilingState.intimationIssued,
  };

  /// Applies [event] to [current] and returns a new [FilingStatus] with the
  /// updated state and an appended transition record.
  ///
  /// If the event is not valid for the current state, the original [current]
  /// is returned unchanged (no-op, no exception).
  static FilingStatus transitionState(
    FilingStatus current,
    ItrFilingEvent event, {
    String reason = '',
    DateTime? transitionedAt,
  }) {
    final allowed = _transitions[current.currentState];
    if (allowed == null) return current;

    final nextState = allowed[event];
    if (nextState == null) return current;

    final transition = FilingStatusTransition(
      fromState: current.currentState,
      toState: nextState,
      transitionedAt: transitionedAt ?? DateTime.now(),
      reason: reason,
    );

    return current.copyWith(
      currentState: nextState,
      history: [...current.history, transition],
    );
  }

  /// Returns the expected refund date, estimated as 45 days after the
  /// [FilingStatus.submittedAt] date (which serves as the e-verification date
  /// for [FilingState.eVerified] statuses).
  ///
  /// In practice, CPC typically processes refunds within 30–45 days of
  /// e-verification.
  static DateTime computeExpectedRefundDate(FilingStatus status) {
    return status.submittedAt.add(const Duration(days: 45));
  }

  /// Returns `true` if the filing is in an active (non-terminal) processing
  /// state and the expected refund window of 45 days has elapsed.
  static bool isOverdue(FilingStatus status) {
    if (_terminalStates.contains(status.currentState)) return false;
    if (status.currentState == FilingState.draft ||
        status.currentState == FilingState.submitted) {
      return false;
    }
    final expectedDate = computeExpectedRefundDate(status);
    return DateTime.now().isAfter(expectedDate);
  }
}
