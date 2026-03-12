import 'package:ca_app/features/practice/domain/models/engagement_letter.dart';
import 'package:ca_app/features/practice/domain/models/fee_structure.dart';

/// Immutable client data required for generating an engagement letter.
class ClientData {
  const ClientData({
    required this.clientId,
    required this.name,
    required this.pan,
    required this.address,
  });

  final String clientId;
  final String name;
  final String pan;
  final String address;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientData &&
        other.clientId == clientId &&
        other.name == name &&
        other.pan == pan &&
        other.address == address;
  }

  @override
  int get hashCode => Object.hash(clientId, name, pan, address);
}

/// Immutable CA firm data required for generating letters and invoices.
class CaFirmData {
  const CaFirmData({
    required this.firmName,
    required this.membershipNumber,
    required this.firmRegistrationNumber,
    required this.address,
    required this.signatoryName,
  });

  final String firmName;

  /// ICAI membership number of the signing CA (e.g., '123456').
  final String membershipNumber;

  /// ICAI firm registration number (e.g., '001234N').
  final String firmRegistrationNumber;

  final String address;

  /// Name of the CA who will sign the letter.
  final String signatoryName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaFirmData &&
        other.firmName == firmName &&
        other.membershipNumber == membershipNumber &&
        other.firmRegistrationNumber == firmRegistrationNumber &&
        other.signatoryName == signatoryName;
  }

  @override
  int get hashCode => Object.hash(
    firmName,
    membershipNumber,
    firmRegistrationNumber,
    signatoryName,
  );
}

/// Generates ICAI-compliant engagement letters.
///
/// Stateless singleton — all methods are pure functions of their inputs.
class EngagementLetterService {
  EngagementLetterService._();

  static final EngagementLetterService instance = EngagementLetterService._();

  /// Creates an [EngagementLetter] from client, scope, fee, and firm data.
  ///
  /// - [startDate] defaults to today.
  /// - [endDate] defaults to one year from today.
  EngagementLetter generateLetter(
    ClientData client,
    List<String> scope,
    FeeStructure fees,
    CaFirmData firm,
  ) {
    final now = DateTime.now();
    final start = now;
    final end = DateTime(
      now.year + 1,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    return EngagementLetter(
      letterId: _generateId('letter'),
      clientName: client.name,
      clientPan: client.pan,
      scope: List.unmodifiable(scope),
      feeStructure: fees,
      startDate: start,
      endDate: end,
      signatoryName: firm.signatoryName,
      membershipNumber: firm.membershipNumber,
      firmName: firm.firmName,
      firmRegistrationNumber: firm.firmRegistrationNumber,
    );
  }

  /// Renders a formatted ICAI-compliant engagement letter as plain text.
  ///
  /// Includes:
  /// - Client name and PAN
  /// - Scope of services
  /// - Fee arrangement
  /// - ICAI membership and firm registration numbers
  /// - Client responsibilities clause
  /// - Confidentiality clause
  /// - Limitation of liability clause
  /// - Signatory details
  String generateLetterText(EngagementLetter letter) {
    final feeDescription = _formatFeeDescription(letter.feeStructure);
    final scopeLines = letter.scope
        .asMap()
        .entries
        .map((e) => '  ${e.key + 1}. ${e.value}')
        .join('\n');
    final startStr = _formatDate(letter.startDate);
    final endStr = _formatDate(letter.endDate);

    return '''
${letter.firmName}
ICAI Firm Registration No.: ${letter.firmRegistrationNumber}
${letter.signatoryName} — Membership No.: ${letter.membershipNumber}

ENGAGEMENT LETTER

Date: $startStr

Dear ${letter.clientName},
PAN: ${letter.clientPan}

We are pleased to confirm our engagement for the following professional services for the period $startStr to $endStr.

SCOPE OF SERVICES
$scopeLines

FEE ARRANGEMENT
$feeDescription

CLIENT RESPONSIBILITIES
You are responsible for providing complete, accurate, and timely information and documents required for the above services. We shall rely on the information furnished and shall not independently verify it.

CONFIDENTIALITY
All information shared by you in connection with this engagement shall be treated as strictly confidential and will not be disclosed to any third party except as required by law, professional standards, or with your prior written consent.

LIMITATION OF LIABILITY
Our liability arising from this engagement, whether in contract, tort, or otherwise, shall be limited to the professional fees paid for the specific service that gives rise to the claim. We shall not be liable for any indirect, consequential, or punitive damages.

ICAI COMPLIANCE
This engagement is governed by the Code of Ethics and Standards on Auditing issued by the Institute of Chartered Accountants of India (ICAI).

Please sign and return a copy of this letter to indicate your agreement to the above terms.

Yours faithfully,

${letter.signatoryName}
Membership No.: ${letter.membershipNumber}
${letter.firmName}
''';
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  String _generateId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatFeeDescription(FeeStructure fees) {
    switch (fees.basis) {
      case FeeBasis.fixed:
        final amount = fees.fixedAmount != null
            ? _paiseToRupees(fees.fixedAmount!)
            : 'as agreed';
        return 'Fixed fee of $amount for the engagement.';
      case FeeBasis.hourly:
        final rate = fees.hourlyRate != null
            ? _paiseToRupees(fees.hourlyRate!)
            : 'as agreed';
        return 'Hourly rate of $rate per hour, billed ${fees.billingFrequency.label.toLowerCase()}.';
      case FeeBasis.retainer:
        final amount = fees.retainerAmount != null
            ? _paiseToRupees(fees.retainerAmount!)
            : 'as agreed';
        return 'Retainer of $amount billed ${fees.billingFrequency.label.toLowerCase()}.';
      case FeeBasis.valueAdded:
        return 'Value-added fee to be determined based on outcomes, billed ${fees.billingFrequency.label.toLowerCase()}.';
    }
  }

  String _paiseToRupees(int paise) {
    final rupees = paise ~/ 100;
    final paiseRem = paise % 100;
    if (paiseRem == 0) return '₹$rupees';
    return '₹$rupees.${paiseRem.toString().padLeft(2, '0')}';
  }
}
