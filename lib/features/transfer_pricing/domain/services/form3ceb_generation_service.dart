import 'package:ca_app/features/transfer_pricing/domain/models/form3ceb.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/international_transaction.dart';

/// Service for generating Form 3CEB (Transfer Pricing Audit Report).
///
/// Form 3CEB is required when:
/// - Aggregate value of international transactions exceeds ₹1 crore
/// - Aggregate value of specified domestic transactions exceeds ₹5 crore
///
/// Filing deadline: October 31 (same as income tax return for corporates
/// with TP audit requirement).
class Form3CEBGenerationService {
  Form3CEBGenerationService._();

  static final Form3CEBGenerationService instance =
      Form3CEBGenerationService._();

  /// Threshold for mandatory Form 3CEB filing: ₹1 crore = 10,000,000,000 paise.
  static const int _mandatoryThresholdPaise = 10000000000;

  /// Generates Form 3CEB from [transactions] and [assessee] data.
  ///
  /// The [totalValueOfTransactionsPaise] is computed as the sum of
  /// all international transaction amounts.
  Form3CEB generateForm3CEB(
    List<InternationalTransaction> transactions,
    AssesseeData assessee,
  ) {
    final total = transactions.fold<int>(0, (sum, t) => sum + t.amountPaise);
    return Form3CEB(
      assesseeDetails: assessee,
      authorizedRepresentative: '',
      internationalTransactions: transactions,
      specifiedDomesticTransactions: const [],
      totalValueOfTransactionsPaise: total,
    );
  }

  /// Whether Form 3CEB filing is mandatory given [totalAmountPaise].
  ///
  /// Mandatory when aggregate international transactions > ₹1 crore.
  bool isMandatory(int totalAmountPaise) {
    return totalAmountPaise > _mandatoryThresholdPaise;
  }
}
