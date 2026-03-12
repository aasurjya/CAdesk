import 'package:ca_app/features/transfer_pricing/domain/models/international_transaction.dart';

/// Data about the assessee for Form 3CEB.
class AssesseeData {
  const AssesseeData({
    required this.name,
    required this.pan,
    required this.address,
  });

  final String name;
  final String pan;
  final String address;

  AssesseeData copyWith({String? name, String? pan, String? address}) {
    return AssesseeData(
      name: name ?? this.name,
      pan: pan ?? this.pan,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssesseeData &&
        other.name == name &&
        other.pan == pan &&
        other.address == address;
  }

  @override
  int get hashCode => Object.hash(name, pan, address);
}

/// Immutable model for Form 3CEB (Transfer Pricing Audit Report).
///
/// Mandatory when:
/// - Aggregate value of international transactions exceeds ₹1 crore, or
/// - Aggregate value of specified domestic transactions exceeds ₹5 crore
///
/// Must be filed along with the income tax return (due date: October 31
/// for companies required to file 3CEB).
class Form3CEB {
  const Form3CEB({
    required this.assesseeDetails,
    required this.authorizedRepresentative,
    required this.internationalTransactions,
    required this.specifiedDomesticTransactions,
    required this.totalValueOfTransactionsPaise,
  });

  final AssesseeData assesseeDetails;

  /// Name of the authorized representative (Chartered Accountant).
  final String authorizedRepresentative;

  final List<InternationalTransaction> internationalTransactions;
  final List<InternationalTransaction> specifiedDomesticTransactions;

  /// Total value of all international transactions in paise.
  final int totalValueOfTransactionsPaise;

  Form3CEB copyWith({
    AssesseeData? assesseeDetails,
    String? authorizedRepresentative,
    List<InternationalTransaction>? internationalTransactions,
    List<InternationalTransaction>? specifiedDomesticTransactions,
    int? totalValueOfTransactionsPaise,
  }) {
    return Form3CEB(
      assesseeDetails: assesseeDetails ?? this.assesseeDetails,
      authorizedRepresentative:
          authorizedRepresentative ?? this.authorizedRepresentative,
      internationalTransactions:
          internationalTransactions ?? this.internationalTransactions,
      specifiedDomesticTransactions:
          specifiedDomesticTransactions ?? this.specifiedDomesticTransactions,
      totalValueOfTransactionsPaise:
          totalValueOfTransactionsPaise ?? this.totalValueOfTransactionsPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Form3CEB) return false;
    if (other.assesseeDetails != assesseeDetails) return false;
    if (other.authorizedRepresentative != authorizedRepresentative) {
      return false;
    }
    if (other.totalValueOfTransactionsPaise != totalValueOfTransactionsPaise) {
      return false;
    }
    if (other.internationalTransactions.length !=
        internationalTransactions.length) {
      return false;
    }
    for (var i = 0; i < internationalTransactions.length; i++) {
      if (other.internationalTransactions[i] != internationalTransactions[i]) {
        return false;
      }
    }
    if (other.specifiedDomesticTransactions.length !=
        specifiedDomesticTransactions.length) {
      return false;
    }
    for (var i = 0; i < specifiedDomesticTransactions.length; i++) {
      if (other.specifiedDomesticTransactions[i] !=
          specifiedDomesticTransactions[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    assesseeDetails,
    authorizedRepresentative,
    Object.hashAll(internationalTransactions),
    Object.hashAll(specifiedDomesticTransactions),
    totalValueOfTransactionsPaise,
  );
}
