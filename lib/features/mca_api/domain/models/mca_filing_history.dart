import 'package:ca_app/features/mca_api/domain/models/mca_filing_record.dart';

/// Immutable collection of all MCA filings for a company.
class McaFilingHistory {
<<<<<<< HEAD
  const McaFilingHistory({
    required this.cin,
    required this.filings,
  });
=======
  const McaFilingHistory({required this.cin, required this.filings});
>>>>>>> worktree-agent-a23e0ce3

  /// CIN of the company whose filings are listed.
  final String cin;

  final List<McaFilingRecord> filings;

  /// Returns the date of the most recently filed form,
  /// or null if [filings] is empty.
  DateTime? get lastFiledDate {
    if (filings.isEmpty) return null;
<<<<<<< HEAD
    return filings
        .map((f) => f.filedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  McaFilingHistory copyWith({
    String? cin,
    List<McaFilingRecord>? filings,
  }) {
=======
    return filings.map((f) => f.filedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  McaFilingHistory copyWith({String? cin, List<McaFilingRecord>? filings}) {
>>>>>>> worktree-agent-a23e0ce3
    return McaFilingHistory(
      cin: cin ?? this.cin,
      filings: filings ?? this.filings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McaFilingHistory && other.cin == cin;
  }

  @override
  int get hashCode => cin.hashCode;
}
