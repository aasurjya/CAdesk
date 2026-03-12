import 'package:flutter/foundation.dart';

/// Feedback status that a taxpayer has submitted for an AIS entry.
enum AisFeedbackStatus {
  accepted(label: 'Accepted', code: 'A'),
  modified(label: 'Modified', code: 'M'),
  denied(label: 'Denied', code: 'D'),
  noFeedback(label: 'No Feedback', code: 'NA');

  const AisFeedbackStatus({required this.label, required this.code});

  final String label;
  final String code;

  /// Maps the code string returned by the AIS JSON to a [AisFeedbackStatus].
  /// Returns [AisFeedbackStatus.noFeedback] for unrecognised codes.
  static AisFeedbackStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'A':
        return AisFeedbackStatus.accepted;
      case 'M':
        return AisFeedbackStatus.modified;
      case 'D':
        return AisFeedbackStatus.denied;
      default:
        return AisFeedbackStatus.noFeedback;
    }
  }
}

/// Immutable model for a single income source record in AIS/TIS data.
///
/// All monetary amounts are stored in **paise** (1 rupee = 100 paise).
@immutable
class AisIncomeSource {
  const AisIncomeSource({
    required this.sourceDescription,
    required this.sourcePan,
    required this.amount,
    required this.feedbackStatus,
  });

  /// Human-readable name / description of the income source.
  final String sourceDescription;

  /// PAN of the income source (payer / deductor).
  final String sourcePan;

  /// Amount received from this source, in paise.
  final int amount;

  /// Taxpayer's feedback status for this entry.
  final AisFeedbackStatus feedbackStatus;

  AisIncomeSource copyWith({
    String? sourceDescription,
    String? sourcePan,
    int? amount,
    AisFeedbackStatus? feedbackStatus,
  }) {
    return AisIncomeSource(
      sourceDescription: sourceDescription ?? this.sourceDescription,
      sourcePan: sourcePan ?? this.sourcePan,
      amount: amount ?? this.amount,
      feedbackStatus: feedbackStatus ?? this.feedbackStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AisIncomeSource &&
          runtimeType == other.runtimeType &&
          sourceDescription == other.sourceDescription &&
          sourcePan == other.sourcePan &&
          amount == other.amount &&
          feedbackStatus == other.feedbackStatus;

  @override
  int get hashCode =>
      Object.hash(sourceDescription, sourcePan, amount, feedbackStatus);

  @override
  String toString() =>
      'AisIncomeSource(description: $sourceDescription, '
      'amount: $amount, status: ${feedbackStatus.label})';
}

/// Immutable model for a capital gain transaction in AIS data.
@immutable
class AisCapGainTransaction {
  const AisCapGainTransaction({
    required this.description,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.gainAmount,
    required this.feedbackStatus,
  });

  final String description;
  final int saleAmount;
  final int purchaseAmount;
  final int gainAmount;
  final AisFeedbackStatus feedbackStatus;

  AisCapGainTransaction copyWith({
    String? description,
    int? saleAmount,
    int? purchaseAmount,
    int? gainAmount,
    AisFeedbackStatus? feedbackStatus,
  }) {
    return AisCapGainTransaction(
      description: description ?? this.description,
      saleAmount: saleAmount ?? this.saleAmount,
      purchaseAmount: purchaseAmount ?? this.purchaseAmount,
      gainAmount: gainAmount ?? this.gainAmount,
      feedbackStatus: feedbackStatus ?? this.feedbackStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AisCapGainTransaction &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          saleAmount == other.saleAmount &&
          gainAmount == other.gainAmount;

  @override
  int get hashCode => Object.hash(description, saleAmount, gainAmount);
}

/// Immutable model for a foreign remittance entry in AIS data.
@immutable
class AisForeignRemittance {
  const AisForeignRemittance({
    required this.remitterName,
    required this.country,
    required this.amount,
    required this.feedbackStatus,
  });

  final String remitterName;
  final String country;
  final int amount;
  final AisFeedbackStatus feedbackStatus;

  AisForeignRemittance copyWith({
    String? remitterName,
    String? country,
    int? amount,
    AisFeedbackStatus? feedbackStatus,
  }) {
    return AisForeignRemittance(
      remitterName: remitterName ?? this.remitterName,
      country: country ?? this.country,
      amount: amount ?? this.amount,
      feedbackStatus: feedbackStatus ?? this.feedbackStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AisForeignRemittance &&
          runtimeType == other.runtimeType &&
          remitterName == other.remitterName &&
          country == other.country &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(remitterName, country, amount);
}
