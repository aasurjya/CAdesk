import 'package:ca_app/features/post_filing/domain/models/filing_status.dart';
import 'package:ca_app/features/post_filing/domain/models/filing_status_transition.dart';
import 'package:ca_app/features/post_filing/domain/services/itr_status_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2025, 7, 1);

  FilingStatus makeStatus({
    FilingState state = FilingState.draft,
    String filingId = 'f-001',
    String pan = 'ABCDE1234F',
    DateTime? submittedAt,
    String? acknowledgementNumber,
    List<FilingStatusTransition>? history,
  }) {
    return FilingStatus(
      filingId: filingId,
      filingType: FilingType.itr,
      pan: pan,
      period: '2024-25',
      submittedAt: submittedAt ?? baseDate,
      currentState: state,
      acknowledgementNumber: acknowledgementNumber,
      history: history ?? const [],
    );
  }

  group('ItrStatusTracker.transitionState', () {
    test('submitFiling transitions DRAFT → SUBMITTED', () {
      final status = makeStatus(state: FilingState.draft);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.submitFiling,
      );
      expect(result.currentState, FilingState.submitted);
      expect(result.history, hasLength(1));
      expect(result.history.first.fromState, FilingState.draft);
      expect(result.history.first.toState, FilingState.submitted);
    });

    test('generateItrV transitions SUBMITTED → E_VERIFICATION_PENDING', () {
      final status = makeStatus(state: FilingState.submitted);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.generateItrV,
      );
      expect(result.currentState, FilingState.eVerificationPending);
    });

    test('eVerify transitions E_VERIFICATION_PENDING → E_VERIFIED', () {
      final status = makeStatus(state: FilingState.eVerificationPending);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.eVerify,
      );
      expect(result.currentState, FilingState.eVerified);
    });

    test('cpcProcessed transitions E_VERIFIED → PROCESSING', () {
      final status = makeStatus(state: FilingState.eVerified);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.cpcProcessed,
      );
      expect(result.currentState, FilingState.processing);
    });

    test('cpcProcessed transitions PROCESSING → PROCESSED', () {
      final status = makeStatus(state: FilingState.processing);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.cpcProcessed,
      );
      expect(result.currentState, FilingState.processed);
    });

    test('refundInitiated transitions PROCESSED → REFUND_INITIATED', () {
      final status = makeStatus(state: FilingState.processed);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.refundInitiated,
      );
      expect(result.currentState, FilingState.refundInitiated);
    });

    test('demandRaised transitions PROCESSED → DEMAND_RAISED', () {
      final status = makeStatus(state: FilingState.processed);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.demandRaised,
      );
      expect(result.currentState, FilingState.demandRaised);
    });

    test('defectiveNotice transitions PROCESSING → DEFECTIVE', () {
      final status = makeStatus(state: FilingState.processing);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.defectiveNotice,
      );
      expect(result.currentState, FilingState.defective);
    });

    test('respond143_1 transitions PROCESSED → INTIMATION_ISSUED', () {
      final status = makeStatus(state: FilingState.processed);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.respond143_1,
      );
      expect(result.currentState, FilingState.intimationIssued);
    });

    test('invalid transition returns status unchanged', () {
      final status = makeStatus(state: FilingState.draft);
      final result = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.eVerify,
      );
      expect(result.currentState, FilingState.draft);
      expect(result.history, isEmpty);
    });

    test('history accumulates across multiple transitions', () {
      var status = makeStatus(state: FilingState.draft);
      status = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.submitFiling,
      );
      status = ItrStatusTracker.transitionState(
        status,
        ItrFilingEvent.generateItrV,
      );
      expect(status.history, hasLength(2));
      expect(status.history[0].fromState, FilingState.draft);
      expect(status.history[1].fromState, FilingState.submitted);
    });

    test('original status is not mutated', () {
      final status = makeStatus(state: FilingState.draft);
      ItrStatusTracker.transitionState(status, ItrFilingEvent.submitFiling);
      expect(status.currentState, FilingState.draft);
    });
  });

  group('ItrStatusTracker.computeExpectedRefundDate', () {
    test('returns 45 days after eVerified date when status is eVerified', () {
      final verifiedDate = DateTime(2025, 4, 1);
      final status = makeStatus(
        state: FilingState.eVerified,
        submittedAt: verifiedDate,
      );
      final expected = ItrStatusTracker.computeExpectedRefundDate(status);
      expect(expected, verifiedDate.add(const Duration(days: 45)));
    });

    test('returns 45 days after submittedAt for non-eVerified states', () {
      final status = makeStatus(
        state: FilingState.processing,
        submittedAt: DateTime(2025, 3, 1),
      );
      final expected = ItrStatusTracker.computeExpectedRefundDate(status);
      expect(expected, DateTime(2025, 3, 1).add(const Duration(days: 45)));
    });
  });

  group('ItrStatusTracker.isOverdue', () {
    test('returns false when refund not yet initiated and within 45 days', () {
      final status = makeStatus(
        state: FilingState.eVerified,
        submittedAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(ItrStatusTracker.isOverdue(status), isFalse);
    });

    test('returns true when processing exceeded 45 days from submittedAt', () {
      final status = makeStatus(
        state: FilingState.processing,
        submittedAt: DateTime.now().subtract(const Duration(days: 60)),
      );
      expect(ItrStatusTracker.isOverdue(status), isTrue);
    });

    test('returns false for terminal states (refundInitiated)', () {
      final status = makeStatus(
        state: FilingState.refundInitiated,
        submittedAt: DateTime.now().subtract(const Duration(days: 100)),
      );
      expect(ItrStatusTracker.isOverdue(status), isFalse);
    });

    test('returns false for terminal states (demandRaised)', () {
      final status = makeStatus(
        state: FilingState.demandRaised,
        submittedAt: DateTime.now().subtract(const Duration(days: 100)),
      );
      expect(ItrStatusTracker.isOverdue(status), isFalse);
    });
  });

  group('FilingStatus equality and copyWith', () {
    test('two identical instances are equal', () {
      final a = makeStatus();
      final b = makeStatus();
      expect(a, equals(b));
    });

    test('copyWith changes only specified field', () {
      final status = makeStatus();
      final updated = status.copyWith(currentState: FilingState.submitted);
      expect(updated.currentState, FilingState.submitted);
      expect(updated.filingId, status.filingId);
    });

    test('hashCode is consistent', () {
      final a = makeStatus();
      final b = makeStatus();
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('FilingStatusTransition equality and copyWith', () {
    test('two identical instances are equal', () {
      final a = FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: baseDate,
        reason: 'Filed online',
      );
      final b = FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: baseDate,
        reason: 'Filed online',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes only specified field', () {
      final t = FilingStatusTransition(
        fromState: FilingState.draft,
        toState: FilingState.submitted,
        transitionedAt: baseDate,
        reason: 'Filed',
      );
      final updated = t.copyWith(reason: 'Updated reason');
      expect(updated.reason, 'Updated reason');
      expect(updated.fromState, t.fromState);
    });
  });
}
