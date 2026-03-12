import 'package:ca_app/features/post_filing/domain/models/refund_tracker.dart';
import 'package:ca_app/features/post_filing/domain/services/refund_tracking_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Return due date for AY 2024-25 is 31 Jul 2024.
  // Sec 244A: interest runs from 1 April of AY (i.e. 1 Apr 2024 for AY 2024-25)
  // or date of filing, whichever is later.
  final returnDueDate = DateTime(2024, 7, 31);

  RefundTracker makeTracker({
    String pan = 'ABCDE1234F',
    String assessmentYear = '2024-25',
    int refundAmount = 500000, // ₹5000 in paise
    RefundTrackerStatus status = RefundTrackerStatus.notInitiated,
    String refundBankAccount = 'XXXX1234',
    DateTime? issuedDate,
    bool adjustedAgainstDemand = false,
    DateTime? expectedDate,
  }) {
    return RefundTracker(
      pan: pan,
      assessmentYear: assessmentYear,
      refundAmount: refundAmount,
      status: status,
      refundBankAccount: refundBankAccount,
      issuedDate: issuedDate,
      adjustedAgainstDemand: adjustedAgainstDemand,
      expectedDate: expectedDate,
    );
  }

  group('RefundTrackingService.updateRefundStatus', () {
    test('updates status to initiated', () {
      final tracker = makeTracker();
      final update = RefundStatusUpdate(
        newStatus: RefundTrackerStatus.initiated,
      );
      final result = RefundTrackingService.updateRefundStatus(tracker, update);
      expect(result.status, RefundTrackerStatus.initiated);
    });

    test('updates status to issued with issuedDate', () {
      final issueDate = DateTime(2024, 11, 1);
      final tracker = makeTracker(status: RefundTrackerStatus.processing);
      final update = RefundStatusUpdate(
        newStatus: RefundTrackerStatus.issued,
        issuedDate: issueDate,
      );
      final result = RefundTrackingService.updateRefundStatus(tracker, update);
      expect(result.status, RefundTrackerStatus.issued);
      expect(result.issuedDate, issueDate);
    });

    test('updates adjustedAgainstDemand flag', () {
      final tracker = makeTracker(status: RefundTrackerStatus.processing);
      final update = RefundStatusUpdate(
        newStatus: RefundTrackerStatus.adjusted,
        adjustedAgainstDemand: true,
      );
      final result = RefundTrackingService.updateRefundStatus(tracker, update);
      expect(result.adjustedAgainstDemand, isTrue);
      expect(result.status, RefundTrackerStatus.adjusted);
    });

    test('original tracker is not mutated', () {
      final tracker = makeTracker();
      final update = RefundStatusUpdate(
        newStatus: RefundTrackerStatus.initiated,
      );
      RefundTrackingService.updateRefundStatus(tracker, update);
      expect(tracker.status, RefundTrackerStatus.notInitiated);
    });
  });

  group('RefundTrackingService.computeRefundInterest — Sec 244A', () {
    // Sec 244A: 6% p.a. simple interest
    // From: 1 April of AY (2024-04-01) for AY 2024-25
    // Until: date of refund grant
    // Threshold: refund > 10% of tax — we test at 500000 paise (₹5000)
    // 90 days grace from returnDueDate: 31 Jul 2024 + 90 = 29 Oct 2024

    test('returns 0 before 90-day delay period', () {
      final tracker = makeTracker(
        refundAmount: 500000,
        status: RefundTrackerStatus.processing,
      );
      // Today is within 90 days of returnDueDate
      final today = DateTime(2024, 9, 1); // 32 days after due date
      final interest = RefundTrackingService.computeRefundInterest(
        tracker,
        today,
        returnDueDate: returnDueDate,
      );
      expect(interest, 0);
    });

    test('computes 6% pa simple interest after 90-day period', () {
      final tracker = makeTracker(
        refundAmount: 500000, // ₹5000 in paise
        status: RefundTrackerStatus.processing,
      );
      // Interest runs from 1 Apr 2024.
      // Today: 1 Apr 2025 (365 days from 1 Apr 2024)
      // 90-day grace from returnDueDate: returnDueDate is 31 Jul 2024
      // 1 Apr 2024 to 1 Apr 2025 = 365 days
      // 6% pa on 500000 paise = 500000 * 0.06 = 30000 paise per year
      // 365/365 * 30000 = 30000
      final today = DateTime(2025, 4, 1);
      final interest = RefundTrackingService.computeRefundInterest(
        tracker,
        today,
        returnDueDate: returnDueDate,
      );
      // interest = refundAmount * 6% * (days/365)
      // from 1 Apr 2024 to 1 Apr 2025 = 365 days
      // = 500000 * 0.06 * (365/365) = 30000
      expect(interest, 30000);
    });

    test('returns 0 when refund already issued', () {
      final tracker = makeTracker(
        refundAmount: 500000,
        status: RefundTrackerStatus.issued,
        issuedDate: DateTime(2024, 10, 1),
      );
      final today = DateTime(2025, 4, 1);
      final interest = RefundTrackingService.computeRefundInterest(
        tracker,
        today,
        returnDueDate: returnDueDate,
      );
      expect(interest, 0);
    });
  });

  group('RefundTrackingService.isDelayed', () {
    test('returns true when not issued within 90 days of due date', () {
      final tracker = makeTracker(
        status: RefundTrackerStatus.processing,
      );
      final today = returnDueDate.add(const Duration(days: 91));
      expect(
        RefundTrackingService.isDelayed(tracker, today: today, returnDueDate: returnDueDate),
        isTrue,
      );
    });

    test('returns false when issued within 90 days', () {
      final issueDate = returnDueDate.add(const Duration(days: 30));
      final tracker = makeTracker(
        status: RefundTrackerStatus.issued,
        issuedDate: issueDate,
      );
      final today = returnDueDate.add(const Duration(days: 91));
      expect(
        RefundTrackingService.isDelayed(tracker, today: today, returnDueDate: returnDueDate),
        isFalse,
      );
    });

    test('returns false when still within 90 days and not issued', () {
      final tracker = makeTracker(status: RefundTrackerStatus.processing);
      final today = returnDueDate.add(const Duration(days: 45));
      expect(
        RefundTrackingService.isDelayed(tracker, today: today, returnDueDate: returnDueDate),
        isFalse,
      );
    });
  });

  group('RefundTracker equality and copyWith', () {
    test('two identical instances are equal', () {
      final a = makeTracker();
      final b = makeTracker();
      expect(a, equals(b));
    });

    test('copyWith changes only specified field', () {
      final tracker = makeTracker();
      final updated = tracker.copyWith(status: RefundTrackerStatus.initiated);
      expect(updated.status, RefundTrackerStatus.initiated);
      expect(updated.pan, tracker.pan);
    });

    test('hashCode is consistent', () {
      final a = makeTracker();
      final b = makeTracker();
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
