import 'dart:math';

import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/post_filing/filing_acknowledgement.dart';
import 'package:ca_app/features/filing/domain/models/post_filing/intimation_143_1.dart';
import 'package:ca_app/features/filing/domain/models/post_filing/refund_status.dart';

/// Simulates Income Tax Department portal interactions with realistic
/// async delays. Intended for development and testing only.
class MockPortalService {
  MockPortalService({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Simulates submitting an ITR-1 return to the portal.
  ///
  /// Returns a [FilingAcknowledgement] after a 2-3 second delay.
  Future<FilingAcknowledgement> submitReturn(
    Itr1FormData formData,
    String assessmentYear,
  ) async {
    final delayMs = 2000 + _random.nextInt(1001);
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    final ackNumber = _generateAcknowledgementNumber();
    final now = DateTime.now();

    return FilingAcknowledgement(
      acknowledgementNumber: ackNumber,
      filingDate: now,
      itrType: 'ITR-1',
      assessmentYear: assessmentYear,
      verificationStatus: VerificationStatus.pending,
      verificationMethod: VerificationMethod.none,
      itrVFormUrl: 'https://portal.incometax.gov.in/itrv/$ackNumber',
    );
  }

  /// Simulates requesting an OTP for e-verification via Aadhaar.
  ///
  /// Returns an OTP reference number after a 1 second delay.
  Future<String> requestEVerificationOtp(
    String pan,
    String acknowledgementNumber,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    final refNumber = 'OTP${_generateDigits(12)}';
    return refNumber;
  }

  /// Simulates OTP verification. Accepts any 6-digit OTP.
  ///
  /// Returns `true` if the OTP is exactly 6 digits, `false` otherwise.
  Future<bool> verifyOtp(String otpRef, String otp) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    final isValid = RegExp(r'^\d{6}$').hasMatch(otp);
    return isValid;
  }

  /// Checks the e-verification status for a given acknowledgement number.
  ///
  /// Randomly returns a [VerificationStatus] after a 1 second delay.
  Future<VerificationStatus> checkFilingStatus(
    String acknowledgementNumber,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    const statuses = VerificationStatus.values;
    return statuses[_random.nextInt(statuses.length)];
  }

  /// Checks the refund status for the given PAN and assessment year.
  ///
  /// Returns a mock [RefundStatus] after a 1 second delay.
  Future<RefundStatus> checkRefundStatus(
    String pan,
    String assessmentYear,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    const lifecycles = RefundLifecycle.values;
    final status = lifecycles[_random.nextInt(lifecycles.length)];

    return RefundStatus(
      refundAmount: (5000 + _random.nextInt(45001)).toDouble(),
      status: status,
      bankAccount: '****${_generateDigits(4)}',
      ifsc: 'SBIN0${_generateDigits(6)}',
      initiatedDate: status.index >= RefundLifecycle.initiated.index
          ? DateTime.now().subtract(Duration(days: _random.nextInt(30) + 1))
          : null,
      creditedDate: status == RefundLifecycle.credited
          ? DateTime.now().subtract(Duration(days: _random.nextInt(7)))
          : null,
      failureReason: status == RefundLifecycle.failed
          ? 'Bank account validation failed'
          : null,
    );
  }

  /// Fetches the Intimation u/s 143(1) for the given PAN and AY.
  ///
  /// Returns `null` approximately 50% of the time to simulate
  /// cases where processing is not yet complete.
  Future<Intimation1431?> getIntimation(
    String pan,
    String assessmentYear,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    // 50% chance of no intimation yet
    if (_random.nextBool()) {
      return null;
    }

    final incomeReturn = (400000 + _random.nextInt(600001)).toDouble();
    final incomeProcessing = incomeReturn + (_random.nextInt(20001) - 10000);
    final taxReturn = (incomeReturn * 0.15).roundToDouble();
    final taxProcessing = (incomeProcessing * 0.15).roundToDouble();
    final difference = taxProcessing - taxReturn;

    final IntimationStatus status;
    final double demand;
    final double refund;

    if (difference.abs() < 100) {
      status = IntimationStatus.noDeviations;
      demand = 0;
      refund = 0;
    } else if (difference > 0) {
      status = IntimationStatus.demandRaised;
      demand = difference;
      refund = 0;
    } else {
      status = IntimationStatus.refundDetermined;
      demand = 0;
      refund = difference.abs();
    }

    return Intimation1431(
      intimationDate: DateTime.now().subtract(
        Duration(days: _random.nextInt(60) + 30),
      ),
      assessmentYear: assessmentYear,
      pan: pan,
      processingStatus: status,
      demandAmount: demand,
      refundAmount: refund,
      incomeAsPerReturn: incomeReturn,
      incomeAsPerProcessing: incomeProcessing,
      taxAsPerReturn: taxReturn,
      taxAsPerProcessing: taxProcessing,
      remarks: status == IntimationStatus.noDeviations
          ? 'No deviation from the return filed.'
          : 'Processed with adjustments. Refer to computation sheet.',
    );
  }

  /// Generates a realistic acknowledgement number: 'ACK' + 15 random digits.
  String _generateAcknowledgementNumber() {
    return 'ACK${_generateDigits(15)}';
  }

  /// Generates a string of [count] random digits.
  String _generateDigits(int count) {
    final buffer = StringBuffer();
    for (var i = 0; i < count; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }
}
