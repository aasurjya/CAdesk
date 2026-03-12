import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';

/// Stateless parser that converts raw TRACES API JSON responses into
/// typed domain models.
///
/// All methods throw [ArgumentError] when the JSON contains an unrecognised
/// status code or an unrecognised enum string, making error-handling explicit.
///
/// **JSON structures mirror the real TRACES API response format.**
///
/// Example PAN response:
/// ```json
/// {"status": "1", "response": {"pan": "ABCDE1234F", "name": "John Doe",
///   "aadhaarLinked": true, "status": "E"}}
/// ```
class TracesResponseParser {
  const TracesResponseParser();

  // ── PAN Verification ────────────────────────────────────────────────────

  /// Parse a TRACES PAN verification response JSON into a
  /// [TracesPanVerification].
  ///
  /// TRACES status codes:
  /// - "E" → [PanStatus.valid]   (active)
  /// - "I" → [PanStatus.invalid]
  /// - "X" → [PanStatus.deleted]
  /// - "A" → [PanStatus.inactive] (Aadhaar not linked)
  ///
  /// Throws [ArgumentError] for unrecognised status codes.
  TracesPanVerification parsePanVerificationResponse(
    Map<String, dynamic> json,
  ) {
    final response = json['response'] as Map<String, dynamic>;

    final pan = response['pan'] as String;
    final name = response['name'] as String;
    final aadhaarLinked = response['aadhaarLinked'] as bool;
    final statusCode = response['status'] as String;
    final dateOfBirth = response['dateOfBirth'] as String?;

    final status = _parsePanStatus(statusCode);

    return TracesPanVerification(
      pan: pan,
      name: name,
      status: status,
      aadhaarLinked: aadhaarLinked,
      dateOfBirth: dateOfBirth,
      verifiedAt: DateTime.now(),
    );
  }

  PanStatus _parsePanStatus(String code) {
    switch (code) {
      case 'E':
        return PanStatus.valid;
      case 'I':
        return PanStatus.invalid;
      case 'X':
        return PanStatus.deleted;
      case 'A':
        return PanStatus.inactive;
      default:
        throw ArgumentError('Unknown TRACES PAN status code: "$code"');
    }
  }

  // ── Challan Status ───────────────────────────────────────────────────────

  /// Parse a TRACES challan status response JSON into a [TracesChallanStatus].
  ///
  /// TRACES booking status codes:
  /// - "F" → [ChallanBookingStatus.matched]
  /// - "U" → [ChallanBookingStatus.unmatched]
  /// - "B" → [ChallanBookingStatus.bookingConfirmed]
  /// - "O" → [ChallanBookingStatus.overBooked]
  ///
  /// Throws [ArgumentError] for unrecognised booking status codes.
  TracesChallanStatus parseChallanStatusResponse(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>;

    final bsrCode = response['bsrCode'] as String;
    final dateStr = response['date'] as String;
    final serial = response['serial'] as String;
    final tan = response['tan'] as String;
    final section = response['section'] as String;
    final depositedAmount = response['amount'] as int;
    final consumedAmount = response['consumed'] as int;
    final balanceAmount = response['balance'] as int;
    final bookingStatusCode = response['bookingStatus'] as String;

    final challanDate = _parseDdMmYyyy(dateStr);
    final status = _parseChallanStatus(bookingStatusCode);

    return TracesChallanStatus(
      bsrCode: bsrCode,
      challanDate: challanDate,
      challanSerial: serial,
      tan: tan,
      section: section,
      depositedAmount: depositedAmount,
      status: status,
      consumedAmount: consumedAmount,
      balanceAmount: balanceAmount,
    );
  }

  ChallanBookingStatus _parseChallanStatus(String code) {
    switch (code) {
      case 'F':
        return ChallanBookingStatus.matched;
      case 'U':
        return ChallanBookingStatus.unmatched;
      case 'B':
        return ChallanBookingStatus.bookingConfirmed;
      case 'O':
        return ChallanBookingStatus.overBooked;
      default:
        throw ArgumentError(
          'Unknown TRACES challan booking status code: "$code"',
        );
    }
  }

  // ── Form 16 Status ───────────────────────────────────────────────────────

  /// Parse a TRACES Form 16 status response JSON into a [TracesForm16Request].
  ///
  /// TRACES request status codes:
  /// - "A" → [Form16RequestStatus.available]
  /// - "P" → [Form16RequestStatus.processing]
  /// - "F" → [Form16RequestStatus.failed]
  ///
  /// Request type strings: "form16", "form16a", "form16b", "justificationReport"
  ///
  /// Throws [ArgumentError] for unrecognised status or requestType values.
  TracesForm16Request parseForm16StatusResponse(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>;

    final requestId = response['requestId'] as String;
    final tan = response['tan'] as String;
    final pan = response['pan'] as String?;
    final financialYear = response['financialYear'] as int;
    final requestTypeStr = response['requestType'] as String;
    final statusCode = response['status'] as String;
    final downloadUrl = response['downloadUrl'] as String?;

    final requestType = _parseForm16RequestType(requestTypeStr);
    final status = _parseForm16Status(statusCode);

    return TracesForm16Request(
      requestId: requestId,
      tan: tan,
      pan: pan,
      financialYear: financialYear,
      requestType: requestType,
      status: status,
      downloadUrl: downloadUrl,
      requestedAt: DateTime.now(),
    );
  }

  Form16RequestStatus _parseForm16Status(String code) {
    switch (code) {
      case 'A':
        return Form16RequestStatus.available;
      case 'P':
        return Form16RequestStatus.processing;
      case 'F':
        return Form16RequestStatus.failed;
      default:
        throw ArgumentError(
          'Unknown TRACES Form 16 request status code: "$code"',
        );
    }
  }

  Form16RequestType _parseForm16RequestType(String typeStr) {
    switch (typeStr) {
      case 'form16':
        return Form16RequestType.form16;
      case 'form16a':
        return Form16RequestType.form16a;
      case 'form16b':
        return Form16RequestType.form16b;
      case 'justificationReport':
        return Form16RequestType.justificationReport;
      default:
        throw ArgumentError(
          'Unknown TRACES Form 16 request type: "$typeStr"',
        );
    }
  }

  // ── Justification Report ─────────────────────────────────────────────────

  /// Parse a TRACES justification report response JSON into a
  /// [TracesJustificationReport].
  ///
  /// Quarter is encoded as an integer 1-4.
  TracesJustificationReport parseJustificationReport(
    Map<String, dynamic> json,
  ) {
    final response = json['response'] as Map<String, dynamic>;

    final tan = response['tan'] as String;
    final financialYear = response['financialYear'] as int;
    final quarterInt = response['quarter'] as int;
    final totalShortfall = response['totalShortfall'] as int;
    final totalInterestDemand = response['totalInterestDemand'] as int;

    final shortDeductionsRaw =
        response['shortDeductions'] as List<dynamic>;
    final lateDeductionsRaw =
        response['lateDeductions'] as List<dynamic>;

    final shortDeductions = shortDeductionsRaw
        .map(
          (e) => _parseShortDeductionEntry(e as Map<String, dynamic>),
        )
        .toList();

    final lateDeductions = lateDeductionsRaw
        .map(
          (e) => _parseLateDeductionEntry(e as Map<String, dynamic>),
        )
        .toList();

    final quarter = TdsQuarter.values[quarterInt - 1];

    return TracesJustificationReport(
      tan: tan,
      financialYear: financialYear,
      quarter: quarter,
      shortDeductions: shortDeductions,
      lateDeductions: lateDeductions,
      totalShortfall: totalShortfall,
      totalInterestDemand: totalInterestDemand,
    );
  }

  ShortDeductionEntry _parseShortDeductionEntry(Map<String, dynamic> json) {
    return ShortDeductionEntry(
      pan: json['pan'] as String,
      section: json['section'] as String,
      amountPaid: json['amountPaid'] as int,
      tdsDeducted: json['tdsDeducted'] as int,
      tdsRequired: json['tdsRequired'] as int,
      shortfall: json['shortfall'] as int,
    );
  }

  LateDeductionEntry _parseLateDeductionEntry(Map<String, dynamic> json) {
    return LateDeductionEntry(
      pan: json['pan'] as String,
      section: json['section'] as String,
      dueDate: json['dueDate'] as String,
      depositedDate: json['depositedDate'] as String,
      daysLate: json['daysLate'] as int,
      interest: json['interest'] as int,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Parse a date string in "dd/MM/yyyy" format into a [DateTime].
  DateTime _parseDdMmYyyy(String dateStr) {
    final parts = dateStr.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }
}
