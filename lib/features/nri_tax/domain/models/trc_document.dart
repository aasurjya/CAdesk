import 'package:flutter/foundation.dart';

/// Immutable model representing a Tax Residency Certificate (TRC) issued by
/// the tax authority of a foreign country.
///
/// TRC is mandatory for claiming DTAA benefits under Section 90(4) of the
/// Income Tax Act, 1961. Form 10F is additionally required when the TRC does
/// not contain all prescribed particulars under Rule 21AB.
@immutable
class TrcDocument {
  const TrcDocument({
    required this.pan,
    required this.countryCode,
    required this.trcNumber,
    required this.issuingAuthority,
    required this.validFrom,
    required this.validTo,
  });

  /// PAN of the NRI taxpayer holding this TRC.
  final String pan;

  /// ISO alpha-2 country code of the issuing country (e.g. "US", "GB").
  final String countryCode;

  /// Unique TRC reference number as issued by the foreign authority.
  final String trcNumber;

  /// Name of the issuing tax authority (e.g. "IRS", "HMRC").
  final String issuingAuthority;

  /// Date from which the TRC is valid (inclusive).
  final DateTime validFrom;

  /// Date until which the TRC is valid (inclusive).
  final DateTime validTo;

  /// True when today's date falls within [validFrom] and [validTo] (inclusive).
  bool get isValid {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = DateTime(validFrom.year, validFrom.month, validFrom.day);
    final to = DateTime(validTo.year, validTo.month, validTo.day);
    return !today.isBefore(from) && !today.isAfter(to);
  }

  TrcDocument copyWith({
    String? pan,
    String? countryCode,
    String? trcNumber,
    String? issuingAuthority,
    DateTime? validFrom,
    DateTime? validTo,
  }) {
    return TrcDocument(
      pan: pan ?? this.pan,
      countryCode: countryCode ?? this.countryCode,
      trcNumber: trcNumber ?? this.trcNumber,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrcDocument &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          countryCode == other.countryCode &&
          trcNumber == other.trcNumber &&
          issuingAuthority == other.issuingAuthority &&
          validFrom == other.validFrom &&
          validTo == other.validTo;

  @override
  int get hashCode => Object.hash(
        pan,
        countryCode,
        trcNumber,
        issuingAuthority,
        validFrom,
        validTo,
      );

  @override
  String toString() =>
      'TrcDocument(pan: $pan, country: $countryCode, '
      'trcNumber: $trcNumber, valid: $validFrom–$validTo)';
}
