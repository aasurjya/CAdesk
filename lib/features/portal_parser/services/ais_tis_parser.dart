import 'dart:convert';

import 'package:ca_app/features/portal_parser/models/ais_data.dart';
import 'package:ca_app/features/portal_parser/models/ais_income_source.dart';

/// Stateless singleton parser for AIS (Annual Information Statement) and
/// TIS (Taxpayer Information Summary) JSON downloads from the Income Tax portal.
///
/// All monetary amounts in the returned models are in **paise**
/// (input rupee values are multiplied by 100).
class AisTisParser {
  AisTisParser._();

  static final AisTisParser instance = AisTisParser._();

  // --------------- public API ---------------

  /// Parses AIS JSON content into [AisData].
  ///
  /// Expected top-level structure:
  /// ```json
  /// {
  ///   "aisData": {
  ///     "pan": "...",
  ///     "financialYear": "...",
  ///     "salaryIncome": [...],
  ///     "dividendIncome": [...],
  ///     "interestIncome": [...]
  ///   }
  /// }
  /// ```
  AisData parseAis(String jsonContent) {
    final root = jsonDecode(jsonContent) as Map<String, Object?>;
    final aisData = root['aisData'] as Map<String, Object?>? ?? {};

    final pan = (aisData['pan'] as String?) ?? '';
    final financialYear = (aisData['financialYear'] as String?) ?? '';

    final salarySources = _parseIncomeSources(aisData['salaryIncome']);
    final dividendSources = _parseIncomeSources(aisData['dividendIncome']);
    final interestSources = _parseIncomeSources(aisData['interestIncome']);
    final capitalGainTransactions =
        _parseCapGainTransactions(aisData['capitalGains']);
    final foreignRemittances =
        _parseForeignRemittances(aisData['foreignRemittance']);

    return AisData(
      pan: pan,
      financialYear: financialYear,
      salarySources: salarySources,
      dividendSources: dividendSources,
      interestSources: interestSources,
      capitalGainTransactions: capitalGainTransactions,
      foreignRemittances: foreignRemittances,
    );
  }

  /// Parses TIS (Taxpayer Information Summary) JSON content into [AisData].
  ///
  /// TIS is a simplified summary with aggregate amounts rather than
  /// individual transactions.  Expected structure:
  /// ```json
  /// {
  ///   "tisData": {
  ///     "pan": "...",
  ///     "financialYear": "...",
  ///     "salary": <rupees>,
  ///     "interest": <rupees>,
  ///     "dividend": <rupees>
  ///   }
  /// }
  /// ```
  AisData parseTis(String jsonContent) {
    final root = jsonDecode(jsonContent) as Map<String, Object?>;
    final tisData = root['tisData'] as Map<String, Object?>? ?? {};

    final pan = (tisData['pan'] as String?) ?? '';
    final financialYear = (tisData['financialYear'] as String?) ?? '';

    final salaryRupees = _toInt(tisData['salary']);
    final interestRupees = _toInt(tisData['interest']);
    final dividendRupees = _toInt(tisData['dividend']);

    final salarySources = salaryRupees > 0
        ? [
            AisIncomeSource(
              sourceDescription: 'Salary (TIS aggregate)',
              sourcePan: '',
              amount: salaryRupees * 100,
              feedbackStatus: AisFeedbackStatus.noFeedback,
            ),
          ]
        : <AisIncomeSource>[];

    final interestSources = interestRupees > 0
        ? [
            AisIncomeSource(
              sourceDescription: 'Interest (TIS aggregate)',
              sourcePan: '',
              amount: interestRupees * 100,
              feedbackStatus: AisFeedbackStatus.noFeedback,
            ),
          ]
        : <AisIncomeSource>[];

    final dividendSources = dividendRupees > 0
        ? [
            AisIncomeSource(
              sourceDescription: 'Dividend (TIS aggregate)',
              sourcePan: '',
              amount: dividendRupees * 100,
              feedbackStatus: AisFeedbackStatus.noFeedback,
            ),
          ]
        : <AisIncomeSource>[];

    return AisData(
      pan: pan,
      financialYear: financialYear,
      salarySources: salarySources,
      dividendSources: dividendSources,
      interestSources: interestSources,
      capitalGainTransactions: const [],
      foreignRemittances: const [],
    );
  }

  // --------------- private helpers ---------------

  List<AisIncomeSource> _parseIncomeSources(Object? rawList) {
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map<String, Object?>>()
        .map(_mapToIncomeSource)
        .toList();
  }

  AisIncomeSource _mapToIncomeSource(Map<String, Object?> map) {
    final description = (map['description'] as String?) ?? '';
    final pan = (map['pan'] as String?) ?? '';
    final amountRupees = _toInt(map['amount']);
    final feedbackCode = (map['feedbackStatus'] as String?) ?? 'NA';
    return AisIncomeSource(
      sourceDescription: description,
      sourcePan: pan,
      amount: amountRupees * 100,
      feedbackStatus: AisFeedbackStatus.fromCode(feedbackCode),
    );
  }

  List<AisCapGainTransaction> _parseCapGainTransactions(Object? rawList) {
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map<String, Object?>>()
        .map(_mapToCapGainTransaction)
        .toList();
  }

  AisCapGainTransaction _mapToCapGainTransaction(Map<String, Object?> map) {
    return AisCapGainTransaction(
      description: (map['description'] as String?) ?? '',
      saleAmount: _toInt(map['saleAmount']) * 100,
      purchaseAmount: _toInt(map['purchaseAmount']) * 100,
      gainAmount: _toInt(map['gainAmount']) * 100,
      feedbackStatus: AisFeedbackStatus.fromCode(
        (map['feedbackStatus'] as String?) ?? 'NA',
      ),
    );
  }

  List<AisForeignRemittance> _parseForeignRemittances(Object? rawList) {
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map<String, Object?>>()
        .map(_mapToForeignRemittance)
        .toList();
  }

  AisForeignRemittance _mapToForeignRemittance(Map<String, Object?> map) {
    return AisForeignRemittance(
      remitterName: (map['remitterName'] as String?) ?? '',
      country: (map['country'] as String?) ?? '',
      amount: _toInt(map['amount']) * 100,
      feedbackStatus: AisFeedbackStatus.fromCode(
        (map['feedbackStatus'] as String?) ?? 'NA',
      ),
    );
  }

  /// Safely converts a JSON value to an [int].
  int _toInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
