import 'package:ca_app/features/startup/domain/models/cap_table.dart';
import 'package:ca_app/features/startup/domain/models/funding_round.dart';

/// Service for managing startup cap tables and computing equity dilution.
class CapTableService {
  CapTableService._();

  static final CapTableService instance = CapTableService._();

  /// Returns a new [CapTable] with [newRound] appended.
  ///
  /// The original [current] cap table is not modified (immutable pattern).
  CapTable updateCapTable(CapTable current, FundingRound newRound) {
    final updatedRounds = [...current.rounds, newRound];
    return current.copyWith(rounds: updatedRounds);
  }

  /// Computes the equity dilution percentage for each investor in [round].
  ///
  /// Returns a map of investor name → diluted equity percentage.
  /// The percentage is taken directly from [InvestorEntry.equityPercentage]
  /// which represents the post-money diluted stake.
  Map<String, double> computeDilution(CapTable table, FundingRound round) {
    if (round.investors.isEmpty) return const {};

    final result = <String, double>{};
    for (final investor in round.investors) {
      result[investor.investorName] = investor.equityPercentage;
    }
    return Map.unmodifiable(result);
  }
}
