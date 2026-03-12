import 'package:ca_app/features/post_filing/domain/models/gst_filing_status.dart';
import 'package:ca_app/features/post_filing/domain/services/gst_status_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dueDate = DateTime(2025, 4, 20); // e.g. GSTR-3B due for March 2025

  GstFilingStatus makeStatus({
    GstReturnType returnType = GstReturnType.gstr3b,
    GstFilingState state = GstFilingState.notFiled,
    DateTime? filedAt,
    String? arn,
    int? lateFee,
    String period = '032025',
  }) {
    return GstFilingStatus(
      gstin: '29AABCU9603R1ZX',
      returnType: returnType,
      period: period,
      status: state,
      filedAt: filedAt,
      arn: arn,
      lateFee: lateFee,
    );
  }

  group('GstStatusTracker.transitionGstState', () {
    test('saveDraft transitions NOT_FILED → SAVED', () {
      final status = makeStatus(state: GstFilingState.notFiled);
      final result = GstStatusTracker.transitionGstState(
        status,
        GstFilingEvent.saveDraft,
      );
      expect(result.status, GstFilingState.saved);
    });

    test('submit transitions SAVED → SUBMITTED', () {
      final status = makeStatus(state: GstFilingState.saved);
      final result = GstStatusTracker.transitionGstState(
        status,
        GstFilingEvent.submit,
      );
      expect(result.status, GstFilingState.submitted);
    });

    test('file transitions SUBMITTED → FILED', () {
      final now = DateTime(2025, 4, 18);
      final status = makeStatus(state: GstFilingState.submitted);
      final result = GstStatusTracker.transitionGstState(
        status,
        GstFilingEvent.file,
        filedAt: now,
        arn: 'AA290325123456',
      );
      expect(result.status, GstFilingState.filed);
      expect(result.filedAt, now);
      expect(result.arn, 'AA290325123456');
    });

    test('gstinProcess transitions FILED → PROCESSED', () {
      final status = makeStatus(state: GstFilingState.filed);
      final result = GstStatusTracker.transitionGstState(
        status,
        GstFilingEvent.gstinProcess,
      );
      expect(result.status, GstFilingState.processed);
    });

    test('reject transitions SUBMITTED → REJECTED', () {
      final status = makeStatus(state: GstFilingState.submitted);
      final result = GstStatusTracker.transitionGstState(
        status,
        GstFilingEvent.reject,
      );
      expect(result.status, GstFilingState.rejected);
    });

    test('invalid transition returns status unchanged', () {
      final status = makeStatus(state: GstFilingState.processed);
      final result = GstStatusTracker.transitionGstState(
        status,
        GstFilingEvent.saveDraft,
      );
      expect(result.status, GstFilingState.processed);
    });

    test('original status is not mutated', () {
      final status = makeStatus(state: GstFilingState.notFiled);
      GstStatusTracker.transitionGstState(status, GstFilingEvent.saveDraft);
      expect(status.status, GstFilingState.notFiled);
    });
  });

  group('GstStatusTracker.computeLateFee — GSTR-3B with tax liability', () {
    // Due date: 20 Apr 2025. Filed/today: 25 Apr 2025 → 5 days late
    // ₹50/day → 5 * 5000 = 25000 paise
    test('5 days late at ₹50/day = 25000 paise', () {
      final today = DateTime(2025, 4, 25);
      final status = makeStatus(
        returnType: GstReturnType.gstr3b,
        state: GstFilingState.notFiled,
        period: '032025',
      );
      final fee = GstStatusTracker.computeLateFee(status, today, dueDate: dueDate);
      expect(fee, 25000); // 5 * 5000 paise
    });

    test('late fee capped at ₹10,000 = 1000000 paise for GSTR-3B', () {
      // 200 days at ₹50/day hits the ₹10,000 cap; use 300 days to confirm cap.
      // dueDate = 20 Apr 2025; +300 days = 15 Feb 2026
      final today = DateTime(2026, 2, 15);
      final status = makeStatus(
        returnType: GstReturnType.gstr3b,
        state: GstFilingState.notFiled,
        period: '032025',
      );
      final fee = GstStatusTracker.computeLateFee(status, today, dueDate: dueDate);
      expect(fee, 1000000); // max ₹10,000 = 1000000 paise
    });

    test('not late returns 0', () {
      final today = DateTime(2025, 4, 19); // before due date
      final status = makeStatus(
        returnType: GstReturnType.gstr3b,
        state: GstFilingState.notFiled,
        period: '032025',
      );
      final fee = GstStatusTracker.computeLateFee(status, today, dueDate: dueDate);
      expect(fee, 0);
    });
  });

  group('GstStatusTracker.computeLateFee — nil return GSTR-3B', () {
    // ₹20/day for nil returns → 2000 paise/day
    test('5 days late nil return = 10000 paise', () {
      final today = DateTime(2025, 4, 25);
      final status = makeStatus(
        returnType: GstReturnType.gstr3b,
        state: GstFilingState.notFiled,
        period: '032025',
      );
      final fee = GstStatusTracker.computeLateFee(
        status,
        today,
        dueDate: dueDate,
        isNilReturn: true,
      );
      expect(fee, 10000); // 5 * 2000 paise
    });

    test('nil return late fee also capped at 1000000 paise', () {
      // 500 days at ₹20/day hits the ₹10,000 cap; use 600 days to confirm cap.
      // dueDate = 20 Apr 2025; +600 days = 10 Dec 2026
      final today = DateTime(2026, 12, 10);
      final status = makeStatus(
        returnType: GstReturnType.gstr3b,
        state: GstFilingState.notFiled,
        period: '032025',
      );
      final fee = GstStatusTracker.computeLateFee(
        status,
        today,
        dueDate: dueDate,
        isNilReturn: true,
      );
      expect(fee, 1000000);
    });
  });

  group('GstStatusTracker.computeLateFee — GSTR-1', () {
    // ₹50/day max ₹10,000
    test('3 days late GSTR-1 at ₹50/day = 15000 paise', () {
      final today = DateTime(2025, 4, 13); // 3 days after 10 Apr due date
      final gstr1Due = DateTime(2025, 4, 10);
      final status = makeStatus(
        returnType: GstReturnType.gstr1,
        state: GstFilingState.notFiled,
        period: '032025',
      );
      final fee = GstStatusTracker.computeLateFee(
        status,
        today,
        dueDate: gstr1Due,
      );
      expect(fee, 15000); // 3 * 5000 paise
    });
  });

  group('GstStatusTracker.isLate', () {
    test('returns true when not filed past due date', () {
      final status = makeStatus(state: GstFilingState.notFiled);
      final result = GstStatusTracker.isLate(
        status,
        today: DateTime(2025, 4, 25),
        dueDate: dueDate,
      );
      expect(result, isTrue);
    });

    test('returns false when filed on due date', () {
      final status = makeStatus(
        state: GstFilingState.filed,
        filedAt: dueDate,
      );
      final result = GstStatusTracker.isLate(
        status,
        today: DateTime(2025, 4, 25),
        dueDate: dueDate,
      );
      expect(result, isFalse);
    });

    test('returns false when filed before due date', () {
      final status = makeStatus(
        state: GstFilingState.filed,
        filedAt: DateTime(2025, 4, 15),
      );
      final result = GstStatusTracker.isLate(
        status,
        today: DateTime(2025, 4, 25),
        dueDate: dueDate,
      );
      expect(result, isFalse);
    });
  });

  group('GstFilingStatus equality and copyWith', () {
    test('two identical instances are equal', () {
      final a = makeStatus();
      final b = makeStatus();
      expect(a, equals(b));
    });

    test('copyWith changes only specified field', () {
      final status = makeStatus();
      final updated = status.copyWith(status: GstFilingState.saved);
      expect(updated.status, GstFilingState.saved);
      expect(updated.gstin, status.gstin);
    });

    test('hashCode is consistent', () {
      final a = makeStatus();
      final b = makeStatus();
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
