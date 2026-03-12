import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/startup/domain/models/cap_table.dart';
import 'package:ca_app/features/startup/domain/models/funding_round.dart';
import 'package:ca_app/features/startup/domain/services/cap_table_service.dart';

void main() {
  group('CapTableService', () {
    late CapTableService service;

    setUp(() {
      service = CapTableService.instance;
    });

    test('singleton returns same instance', () {
      expect(CapTableService.instance, same(CapTableService.instance));
    });

    group('updateCapTable', () {
      test('adds new funding round immutably', () {
        const initial = CapTable(
          companyName: 'Test Startup Pvt Ltd',
          cin: 'U72900MH2020PTC345678',
          rounds: [],
        );
        final newRound = FundingRound(
          roundName: 'Seed',
          date: DateTime(2024, 1, 15),
          preMoneyValuationPaise: 500000000, // Rs 50L
          amountRaisedPaise: 100000000, // Rs 10L
          investors: const [
            InvestorEntry(
              investorName: 'Angel Investor A',
              amountInvestedPaise: 100000000,
              equityPercentage: 16.67,
            ),
          ],
        );
        final updated = service.updateCapTable(initial, newRound);
        expect(updated.rounds.length, 1);
        expect(updated.rounds.first.roundName, 'Seed');
        // Original unchanged
        expect(initial.rounds, isEmpty);
      });

      test('appends to existing rounds', () {
        final existingRound = FundingRound(
          roundName: 'Pre-Seed',
          date: DateTime(2023, 6, 1),
          preMoneyValuationPaise: 200000000,
          amountRaisedPaise: 50000000,
          investors: const [],
        );
        final initial = CapTable(
          companyName: 'Growth Startup',
          cin: 'U72900KA2021PTC567890',
          rounds: [existingRound],
        );
        final seriesA = FundingRound(
          roundName: 'Series A',
          date: DateTime(2024, 3, 1),
          preMoneyValuationPaise: 2000000000,
          amountRaisedPaise: 500000000,
          investors: const [],
        );
        final updated = service.updateCapTable(initial, seriesA);
        expect(updated.rounds.length, 2);
        expect(updated.rounds.last.roundName, 'Series A');
      });
    });

    group('computeDilution', () {
      test('computes dilution percentages for each investor', () {
        final round = FundingRound(
          roundName: 'Seed',
          date: DateTime(2024, 1, 15),
          preMoneyValuationPaise: 500000000,
          amountRaisedPaise: 100000000,
          investors: const [
            InvestorEntry(
              investorName: 'Investor A',
              amountInvestedPaise: 60000000,
              equityPercentage: 10.0,
            ),
            InvestorEntry(
              investorName: 'Investor B',
              amountInvestedPaise: 40000000,
              equityPercentage: 6.67,
            ),
          ],
        );
        final table = CapTable(
          companyName: 'Startup',
          cin: 'U72900MH2020PTC345678',
          rounds: [round],
        );
        final dilution = service.computeDilution(table, round);
        expect(dilution.containsKey('Investor A'), true);
        expect(dilution.containsKey('Investor B'), true);
        expect(dilution['Investor A'], closeTo(10.0, 0.01));
      });

      test('returns empty map for round with no investors', () {
        final round = FundingRound(
          roundName: 'Bootstrap',
          date: DateTime(2024, 1, 1),
          preMoneyValuationPaise: 100000000,
          amountRaisedPaise: 0,
          investors: const [],
        );
        final table = CapTable(
          companyName: 'Solo Startup',
          cin: 'U72900MH2020PTC999999',
          rounds: const [],
        );
        final dilution = service.computeDilution(table, round);
        expect(dilution, isEmpty);
      });
    });
  });

  group('CapTable model', () {
    test('equality and copyWith', () {
      const a = CapTable(
        companyName: 'Test Co',
        cin: 'U72900MH2020PTC345678',
        rounds: [],
      );
      const b = CapTable(
        companyName: 'Test Co',
        cin: 'U72900MH2020PTC345678',
        rounds: [],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final updated = a.copyWith(companyName: 'Updated Co');
      expect(updated.companyName, 'Updated Co');
      expect(a.companyName, 'Test Co');
    });
  });

  group('FundingRound model', () {
    test('equality and copyWith', () {
      final a = FundingRound(
        roundName: 'Seed',
        date: DateTime(2024, 1, 15),
        preMoneyValuationPaise: 500000000,
        amountRaisedPaise: 100000000,
        investors: const [],
      );
      final b = FundingRound(
        roundName: 'Seed',
        date: DateTime(2024, 1, 15),
        preMoneyValuationPaise: 500000000,
        amountRaisedPaise: 100000000,
        investors: const [],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final updated = a.copyWith(roundName: 'Pre-Seed');
      expect(updated.roundName, 'Pre-Seed');
      expect(a.roundName, 'Seed');
    });
  });

  group('InvestorEntry model', () {
    test('equality', () {
      const a = InvestorEntry(
        investorName: 'Fund A',
        amountInvestedPaise: 50000000,
        equityPercentage: 8.33,
      );
      const b = InvestorEntry(
        investorName: 'Fund A',
        amountInvestedPaise: 50000000,
        equityPercentage: 8.33,
      );
      expect(a, equals(b));
    });
  });
}
