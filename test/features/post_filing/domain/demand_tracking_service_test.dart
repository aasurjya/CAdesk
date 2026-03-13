import 'package:ca_app/features/post_filing/domain/models/demand_tracker.dart';
import 'package:ca_app/features/post_filing/domain/services/demand_tracking_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final baseDate = DateTime(2025, 1, 1);

  DemandTracker makeTracker({
    String pan = 'ABCDE1234F',
    String assessmentYear = '2024-25',
    String demandId = 'DEM-001',
    String section = '143(1)',
    int demandAmount = 1000000, // ₹10,000 in paise
    int outstandingAmount = 1000000,
    DemandTrackerStatus status = DemandTrackerStatus.raised,
    DateTime? dueDate,
    bool interestAccruing = true,
  }) {
    return DemandTracker(
      pan: pan,
      assessmentYear: assessmentYear,
      demandId: demandId,
      section: section,
      demandAmount: demandAmount,
      outstandingAmount: outstandingAmount,
      status: status,
      dueDate: dueDate ?? baseDate,
      interestAccruing: interestAccruing,
    );
  }

  group('DemandTrackingService.updateDemandStatus', () {
    test('updates status to partiallyPaid with reduced outstanding', () {
      final tracker = makeTracker();
      final update = DemandStatusUpdate(
        newStatus: DemandTrackerStatus.partiallyPaid,
        newOutstandingAmount: 500000,
      );
      final result = DemandTrackingService.updateDemandStatus(tracker, update);
      expect(result.status, DemandTrackerStatus.partiallyPaid);
      expect(result.outstandingAmount, 500000);
    });

    test('updates status to fullPaid with zero outstanding', () {
      final tracker = makeTracker();
      final update = DemandStatusUpdate(
        newStatus: DemandTrackerStatus.fullPaid,
        newOutstandingAmount: 0,
      );
      final result = DemandTrackingService.updateDemandStatus(tracker, update);
      expect(result.status, DemandTrackerStatus.fullPaid);
      expect(result.outstandingAmount, 0);
    });

    test('updates to stayGranted stops interest accruing', () {
      final tracker = makeTracker();
      final update = DemandStatusUpdate(
        newStatus: DemandTrackerStatus.stayGranted,
        interestAccruing: false,
      );
      final result = DemandTrackingService.updateDemandStatus(tracker, update);
      expect(result.status, DemandTrackerStatus.stayGranted);
      expect(result.interestAccruing, isFalse);
    });

    test('original tracker is not mutated', () {
      final tracker = makeTracker();
      final update = DemandStatusUpdate(
        newStatus: DemandTrackerStatus.fullPaid,
        newOutstandingAmount: 0,
      );
      DemandTrackingService.updateDemandStatus(tracker, update);
      expect(tracker.status, DemandTrackerStatus.raised);
      expect(tracker.outstandingAmount, 1000000);
    });
  });

  group('DemandTrackingService.computeAccruedInterest', () {
    // 1% per month on outstanding amount
    // outstandingAmount = 1000000 paise (₹10,000)
    // dueDate = 1 Jan 2025
    // today = 1 Mar 2025 → 2 months
    // interest = 1000000 * 0.01 * 2 = 20000 paise

    test('2 months overdue = 2% of outstanding', () {
      final tracker = makeTracker(
        outstandingAmount: 1000000,
        dueDate: DateTime(2025, 1, 1),
        interestAccruing: true,
      );
      final today = DateTime(2025, 3, 1);
      final interest = DemandTrackingService.computeAccruedInterest(
        tracker,
        today,
      );
      expect(interest, 20000); // 1000000 * 1% * 2 months
    });

    test('returns 0 when not yet past due date', () {
      final tracker = makeTracker(
        outstandingAmount: 1000000,
        dueDate: DateTime(2025, 3, 1),
        interestAccruing: true,
      );
      final today = DateTime(2025, 2, 1);
      final interest = DemandTrackingService.computeAccruedInterest(
        tracker,
        today,
      );
      expect(interest, 0);
    });

    test('returns 0 when interestAccruing is false', () {
      final tracker = makeTracker(
        outstandingAmount: 1000000,
        dueDate: DateTime(2025, 1, 1),
        interestAccruing: false,
      );
      final today = DateTime(2025, 6, 1);
      final interest = DemandTrackingService.computeAccruedInterest(
        tracker,
        today,
      );
      expect(interest, 0);
    });

    test('returns 0 when demand is fully paid', () {
      final tracker = makeTracker(
        outstandingAmount: 0,
        dueDate: DateTime(2025, 1, 1),
        status: DemandTrackerStatus.fullPaid,
        interestAccruing: false,
      );
      final today = DateTime(2025, 6, 1);
      final interest = DemandTrackingService.computeAccruedInterest(
        tracker,
        today,
      );
      expect(interest, 0);
    });

    test('partial month rounds down to completed months', () {
      final tracker = makeTracker(
        outstandingAmount: 1000000,
        dueDate: DateTime(2025, 1, 1),
        interestAccruing: true,
      );
      // 1 Jan 2025 to 15 Mar 2025 → 2 complete months
      final today = DateTime(2025, 3, 15);
      final interest = DemandTrackingService.computeAccruedInterest(
        tracker,
        today,
      );
      expect(interest, 20000); // 2 complete months only
    });
  });

  group('DemandTrackingService.computeTotalOutstanding', () {
    test('sums all outstanding amounts', () {
      final demands = [
        makeTracker(outstandingAmount: 500000),
        makeTracker(demandId: 'DEM-002', outstandingAmount: 300000),
        makeTracker(demandId: 'DEM-003', outstandingAmount: 200000),
      ];
      final total = DemandTrackingService.computeTotalOutstanding(demands);
      expect(total, 1000000);
    });

    test('returns 0 for empty list', () {
      expect(DemandTrackingService.computeTotalOutstanding([]), 0);
    });

    test('excludes fully paid demands (outstandingAmount = 0)', () {
      final demands = [
        makeTracker(outstandingAmount: 500000),
        makeTracker(
          demandId: 'DEM-002',
          outstandingAmount: 0,
          status: DemandTrackerStatus.fullPaid,
        ),
      ];
      final total = DemandTrackingService.computeTotalOutstanding(demands);
      expect(total, 500000);
    });
  });

  group('DemandTracker equality and copyWith', () {
    test('two identical instances are equal', () {
      final a = makeTracker();
      final b = makeTracker();
      expect(a, equals(b));
    });

    test('copyWith changes only specified field', () {
      final tracker = makeTracker();
      final updated = tracker.copyWith(status: DemandTrackerStatus.inAppeal);
      expect(updated.status, DemandTrackerStatus.inAppeal);
      expect(updated.pan, tracker.pan);
      expect(updated.demandAmount, tracker.demandAmount);
    });

    test('hashCode is consistent', () {
      final a = makeTracker();
      final b = makeTracker();
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
