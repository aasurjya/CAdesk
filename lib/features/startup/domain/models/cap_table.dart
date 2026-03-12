import 'package:ca_app/features/startup/domain/models/funding_round.dart';

/// Immutable cap table (capitalisation table) for a startup company.
///
/// Tracks all funding rounds and the resulting ownership structure.
class CapTable {
  const CapTable({
    required this.companyName,
    required this.cin,
    required this.rounds,
  });

  final String companyName;

  /// Corporate Identification Number (CIN).
  final String cin;

  /// List of funding rounds in chronological order.
  final List<FundingRound> rounds;

  CapTable copyWith({
    String? companyName,
    String? cin,
    List<FundingRound>? rounds,
  }) {
    return CapTable(
      companyName: companyName ?? this.companyName,
      cin: cin ?? this.cin,
      rounds: rounds ?? this.rounds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CapTable) return false;
    if (other.companyName != companyName) return false;
    if (other.cin != cin) return false;
    if (other.rounds.length != rounds.length) return false;
    for (var i = 0; i < rounds.length; i++) {
      if (other.rounds[i] != rounds[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(companyName, cin, Object.hashAll(rounds));
}
