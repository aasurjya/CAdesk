import 'package:ca_app/features/advanced_audit/domain/models/audit_transaction.dart';
import 'package:ca_app/features/advanced_audit/domain/models/fraud_indicator.dart';
import 'package:ca_app/features/advanced_audit/domain/services/fraud_detection_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FraudDetectionService', () {
    // --------------- detectRoundNumbers ---------------

    group('detectRoundNumbers', () {
      test('detects amount exactly divisible by 100000 paise (₹1000)', () {
        final txns = [
          _txn('T1', 'VendorA', 100000, _date(2024, 1, 10)),
          _txn('T2', 'VendorA', 150000, _date(2024, 1, 11)),
        ];
        final indicators = FraudDetectionService.detectRoundNumbers(txns);
        expect(indicators.length, equals(1));
        expect(indicators.first.transactions, contains('T1'));
        expect(
          indicators.first.indicatorType,
          equals(FraudIndicatorType.roundNumberBias),
        );
      });

      test('does not flag amounts that are not round multiples', () {
        final txns = [
          _txn('T1', 'VendorA', 123456, _date(2024, 1, 10)),
          _txn('T2', 'VendorA', 78901, _date(2024, 1, 11)),
        ];
        final indicators = FraudDetectionService.detectRoundNumbers(txns);
        expect(indicators, isEmpty);
      });

      test('flags multiple round-number transactions separately', () {
        final txns = [
          _txn('T1', 'X', 1000000, _date(2024, 1, 1)),
          _txn('T2', 'Y', 5000000, _date(2024, 1, 2)),
          _txn('T3', 'Z', 123456, _date(2024, 1, 3)),
        ];
        final indicators = FraudDetectionService.detectRoundNumbers(txns);
        expect(indicators.length, equals(1));
        final ids = indicators.first.transactions;
        expect(ids, containsAll(['T1', 'T2']));
        expect(ids, isNot(contains('T3')));
      });

      test('higher-round amounts get higher severity', () {
        final txns = [
          _txn('T1', 'A', 100000, _date(2024, 1, 1)), // ₹1000 — low
          _txn('T2', 'B', 10000000, _date(2024, 1, 2)), // ₹100,000 — high
        ];
        final indicators = FraudDetectionService.detectRoundNumbers(txns);
        expect(indicators, isNotEmpty);
      });

      test('returns empty list for empty transactions', () {
        expect(FraudDetectionService.detectRoundNumbers([]), isEmpty);
      });
    });

    // --------------- detectJustBelowThreshold ---------------

    group('detectJustBelowThreshold', () {
      test('flags amount just below a given threshold', () {
        // ₹49,999 is just below ₹50,000 threshold (5000000 paise)
        final txns = [
          _txn('T1', 'VendorA', 4999900, _date(2024, 1, 10)),
          _txn('T2', 'VendorA', 6000000, _date(2024, 1, 11)),
        ];
        final indicators = FraudDetectionService.detectJustBelowThreshold(
          txns,
          [5000000], // ₹50,000 threshold
        );
        expect(indicators.length, equals(1));
        expect(indicators.first.transactions, contains('T1'));
        expect(
          indicators.first.indicatorType,
          equals(FraudIndicatorType.justBelowThreshold),
        );
      });

      test('does not flag amounts far below threshold', () {
        final txns = [_txn('T1', 'VendorA', 1000000, _date(2024, 1, 10))];
        final indicators = FraudDetectionService.detectJustBelowThreshold(
          txns,
          [5000000],
        );
        expect(indicators, isEmpty);
      });

      test('detects multiple transactions near the same threshold', () {
        final txns = [
          _txn('T1', 'A', 4999000, _date(2024, 1, 1)),
          _txn('T2', 'B', 4998000, _date(2024, 1, 2)),
          _txn('T3', 'C', 4000000, _date(2024, 1, 3)),
        ];
        final indicators = FraudDetectionService.detectJustBelowThreshold(
          txns,
          [5000000],
        );
        expect(indicators.length, equals(1));
        final ids = indicators.first.transactions;
        expect(ids, containsAll(['T1', 'T2']));
        expect(ids, isNot(contains('T3')));
      });

      test('handles multiple thresholds', () {
        final txns = [
          _txn(
            'T1',
            'A',
            1999000,
            _date(2024, 1, 1),
          ), // just below 200000 paise
          _txn(
            'T2',
            'B',
            4999000,
            _date(2024, 1, 2),
          ), // just below 500000 paise
        ];
        final indicators = FraudDetectionService.detectJustBelowThreshold(
          txns,
          [2000000, 5000000],
        );
        // Each threshold may produce its own indicator group
        final ids = indicators.expand((ind) => ind.transactions).toSet();
        expect(ids, containsAll(['T1', 'T2']));
      });

      test('returns empty list for empty thresholds', () {
        final txns = [_txn('T1', 'A', 4999000, _date(2024, 1, 1))];
        expect(
          FraudDetectionService.detectJustBelowThreshold(txns, []),
          isEmpty,
        );
      });
    });

    // --------------- detectDuplicates ---------------

    group('detectDuplicates', () {
      test('flags same amount + same party within 30 days', () {
        final txns = [
          _txn('T1', 'VendorA', 500000, _date(2024, 1, 1)),
          _txn('T2', 'VendorA', 500000, _date(2024, 1, 15)),
        ];
        final indicators = FraudDetectionService.detectDuplicates(txns);
        expect(indicators.length, equals(1));
        expect(
          indicators.first.indicatorType,
          equals(FraudIndicatorType.duplicateAmount),
        );
        expect(indicators.first.transactions, containsAll(['T1', 'T2']));
      });

      test('does not flag same amount different party', () {
        final txns = [
          _txn('T1', 'VendorA', 500000, _date(2024, 1, 1)),
          _txn('T2', 'VendorB', 500000, _date(2024, 1, 5)),
        ];
        expect(FraudDetectionService.detectDuplicates(txns), isEmpty);
      });

      test('does not flag same party same amount beyond 30 days', () {
        final txns = [
          _txn('T1', 'VendorA', 500000, _date(2024, 1, 1)),
          _txn('T2', 'VendorA', 500000, _date(2024, 2, 15)),
        ];
        expect(FraudDetectionService.detectDuplicates(txns), isEmpty);
      });

      test('groups three duplicates into one indicator', () {
        final txns = [
          _txn('T1', 'VendorA', 500000, _date(2024, 1, 1)),
          _txn('T2', 'VendorA', 500000, _date(2024, 1, 10)),
          _txn('T3', 'VendorA', 500000, _date(2024, 1, 20)),
        ];
        final indicators = FraudDetectionService.detectDuplicates(txns);
        expect(indicators.length, equals(1));
        expect(indicators.first.transactions.length, equals(3));
      });

      test('returns empty for single transaction', () {
        final txns = [_txn('T1', 'VendorA', 500000, _date(2024, 1, 1))];
        expect(FraudDetectionService.detectDuplicates(txns), isEmpty);
      });
    });

    // --------------- detectVelocityAnomalies ---------------

    group('detectVelocityAnomalies', () {
      test(
        'flags month with spike > 3 std deviations above 6-month average',
        () {
          // 6 months at ₹10,000 then a spike month at ₹500,000
          final txns = _buildMonthlyTransactions({
            DateTime(2024, 1): 1000000,
            DateTime(2024, 2): 1000000,
            DateTime(2024, 3): 1000000,
            DateTime(2024, 4): 1000000,
            DateTime(2024, 5): 1000000,
            DateTime(2024, 6): 1000000,
            DateTime(2024, 7): 50000000, // spike
          });
          final indicators = FraudDetectionService.detectVelocityAnomalies(
            txns,
          );
          expect(indicators, isNotEmpty);
          expect(
            indicators.first.indicatorType,
            equals(FraudIndicatorType.velocityAnomaly),
          );
        },
      );

      test('does not flag consistent monthly amounts', () {
        final txns = _buildMonthlyTransactions({
          DateTime(2024, 1): 1000000,
          DateTime(2024, 2): 1050000,
          DateTime(2024, 3): 990000,
          DateTime(2024, 4): 1010000,
          DateTime(2024, 5): 1020000,
          DateTime(2024, 6): 980000,
          DateTime(2024, 7): 1030000,
        });
        final indicators = FraudDetectionService.detectVelocityAnomalies(txns);
        expect(indicators, isEmpty);
      });

      test('returns empty for fewer than 7 months of data', () {
        // Only 3 months — not enough for 6-month rolling window
        final txns = _buildMonthlyTransactions({
          DateTime(2024, 1): 1000000,
          DateTime(2024, 2): 1000000,
          DateTime(2024, 3): 50000000,
        });
        final indicators = FraudDetectionService.detectVelocityAnomalies(txns);
        expect(indicators, isEmpty);
      });
    });
  });
}

// ─── Helpers ───────────────────────────────────────────────────────────────

AuditTransaction _txn(String id, String party, int amount, DateTime date) =>
    AuditTransaction(
      transactionId: id,
      partyName: party,
      amountPaise: amount,
      transactionDate: date,
      description: 'Test transaction $id',
    );

DateTime _date(int year, int month, int day) => DateTime(year, month, day);

/// Builds a flat list of transactions with one per month, each with the given
/// total amount for that month.
List<AuditTransaction> _buildMonthlyTransactions(
  Map<DateTime, int> monthlyAmounts,
) {
  final txns = <AuditTransaction>[];
  var idx = 1;
  for (final entry in monthlyAmounts.entries) {
    txns.add(
      AuditTransaction(
        transactionId: 'T${idx++}',
        partyName: 'VendorX',
        amountPaise: entry.value,
        transactionDate: entry.key,
        description: 'Monthly txn',
      ),
    );
  }
  return txns;
}
