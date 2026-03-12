/// An individual clause within Form 3CD (Tax Audit Report under Sec 44AB).
///
/// Each clause has a number, a description from the prescribed form,
/// and a textual response along with any specific disclosures required.
class Form3CDClause {
  const Form3CDClause({
    required this.clauseNumber,
    required this.description,
    required this.response,
    required this.disclosures,
  });

  /// Clause number (1 – 44) as per the prescribed Form 3CD.
  final int clauseNumber;

  /// Standard description/question text for the clause.
  final String description;

  /// Textual response — may be 'Yes', 'No', a method name, an amount string,
  /// or 'N/A' where the clause is not applicable.
  final String response;

  /// Specific line-item disclosures required under the clause.
  /// Empty list if no disclosures are needed.
  final List<String> disclosures;

  /// Whether this clause carries specific disclosures.
  bool get hasDisclosures => disclosures.isNotEmpty;

  Form3CDClause copyWith({
    int? clauseNumber,
    String? description,
    String? response,
    List<String>? disclosures,
  }) {
    return Form3CDClause(
      clauseNumber: clauseNumber ?? this.clauseNumber,
      description: description ?? this.description,
      response: response ?? this.response,
      disclosures: disclosures ?? this.disclosures,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Form3CDClause) return false;
    if (other.clauseNumber != clauseNumber) return false;
    if (other.description != description) return false;
    if (other.response != response) return false;
    if (other.disclosures.length != disclosures.length) return false;
    for (int i = 0; i < disclosures.length; i++) {
      if (other.disclosures[i] != disclosures[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(clauseNumber, description, response, disclosures.length);
}
