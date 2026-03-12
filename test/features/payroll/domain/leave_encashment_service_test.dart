import 'package:ca_app/features/payroll/domain/services/leave_encashment_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LeaveEncashmentService', () {
    group('compute', () {
      test('returns 0 for 0 pending leaves', () {
        expect(
          LeaveEncashmentService.compute(
            basicPerDayPaise: 100000,
            pendingLeaves: 0,
          ),
          0,
        );
      });

      test('computes correctly for 10 pending leaves', () {
        // basicPerDay = ₹1000 (100000 paise), leaves = 10
        // Encashment = 100000 * 10 = 1000000 paise
        expect(
          LeaveEncashmentService.compute(
            basicPerDayPaise: 100000,
            pendingLeaves: 10,
          ),
          1000000,
        );
      });

      test('caps at 30 days at retirement', () {
        // pendingLeaves = 50, but max encashable is 30 at retirement
        expect(
          LeaveEncashmentService.compute(
            basicPerDayPaise: 100000,
            pendingLeaves: 50,
            isRetirement: true,
          ),
          3000000, // 30 * 100000
        );
      });

      test(
        'does not cap at 30 days when not at retirement with < 30 leaves',
        () {
          expect(
            LeaveEncashmentService.compute(
              basicPerDayPaise: 100000,
              pendingLeaves: 25,
            ),
            2500000, // 25 * 100000
          );
        },
      );

      test('computes for exactly 30 leaves without cap issue', () {
        expect(
          LeaveEncashmentService.compute(
            basicPerDayPaise: 150000,
            pendingLeaves: 30,
          ),
          4500000, // 30 * 150000
        );
      });

      test('returns 0 for negative pending leaves', () {
        expect(
          LeaveEncashmentService.compute(
            basicPerDayPaise: 100000,
            pendingLeaves: -5,
          ),
          0,
        );
      });

      test('returns 0 for 0 basic per day', () {
        expect(
          LeaveEncashmentService.compute(
            basicPerDayPaise: 0,
            pendingLeaves: 10,
          ),
          0,
        );
      });

      test('computes daily rate from monthly basic correctly', () {
        // Monthly basic = ₹30,000 (3000000 paise)
        // Daily = 3000000 / 26 = 115384 paise
        final dailyRate = LeaveEncashmentService.dailyRateFromMonthly(3000000);
        expect(dailyRate, 115384);
      });
    });

    group('maxRetirementDays', () {
      test('constant is 30', () {
        expect(LeaveEncashmentService.maxRetirementEncashableDays, 30);
      });
    });
  });
}
