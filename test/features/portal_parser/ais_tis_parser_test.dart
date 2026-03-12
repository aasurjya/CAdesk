import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_parser/models/ais_data.dart';
import 'package:ca_app/features/portal_parser/models/ais_income_source.dart';
import 'package:ca_app/features/portal_parser/services/ais_tis_parser.dart';

void main() {
  group('AisTisParser', () {
    late AisTisParser parser;

    setUp(() {
      parser = AisTisParser.instance;
    });

    // --------------- parseAis ---------------

    group('parseAis', () {
      const sampleAisJson = '''
{
  "aisData": {
    "pan": "ABCDE1234F",
    "financialYear": "2023-24",
    "salaryIncome": [
      {"description": "ABC Ltd", "pan": "AAATA1234X", "amount": 500000, "feedbackStatus": "A"}
    ],
    "dividendIncome": [],
    "interestIncome": [
      {"description": "SBI Bank", "pan": "AABCS1429B", "amount": 10000, "feedbackStatus": "NA"}
    ]
  }
}''';

      test('parses PAN correctly', () {
        final result = parser.parseAis(sampleAisJson);
        expect(result.pan, equals('ABCDE1234F'));
      });

      test('parses financial year correctly', () {
        final result = parser.parseAis(sampleAisJson);
        expect(result.financialYear, equals('2023-24'));
      });

      test('parses salary sources', () {
        final result = parser.parseAis(sampleAisJson);
        expect(result.salarySources, hasLength(1));
        expect(result.salarySources.first.sourceDescription, equals('ABC Ltd'));
      });

      test('parses salary source PAN', () {
        final result = parser.parseAis(sampleAisJson);
        expect(result.salarySources.first.sourcePan, equals('AAATA1234X'));
      });

      test('converts salary amount to paise', () {
        final result = parser.parseAis(sampleAisJson);
        // 500000 rupees → 50000000 paise
        expect(result.salarySources.first.amount, equals(50000000));
      });

      test('parses feedbackStatus A as accepted', () {
        final result = parser.parseAis(sampleAisJson);
        expect(
          result.salarySources.first.feedbackStatus,
          equals(AisFeedbackStatus.accepted),
        );
      });

      test('parses feedbackStatus NA as noFeedback', () {
        final result = parser.parseAis(sampleAisJson);
        expect(
          result.interestSources.first.feedbackStatus,
          equals(AisFeedbackStatus.noFeedback),
        );
      });

      test('parses empty dividend income list', () {
        final result = parser.parseAis(sampleAisJson);
        expect(result.dividendSources, isEmpty);
      });

      test('parses interest income sources', () {
        final result = parser.parseAis(sampleAisJson);
        expect(result.interestSources, hasLength(1));
        expect(result.interestSources.first.sourceDescription, equals('SBI Bank'));
      });

      test('converts interest amount to paise', () {
        final result = parser.parseAis(sampleAisJson);
        expect(result.interestSources.first.amount, equals(1000000));
      });

      test('returns empty capital gain and foreign remittance lists when absent', () {
        final result = parser.parseAis(sampleAisJson);
        expect(result.capitalGainTransactions, isEmpty);
        expect(result.foreignRemittances, isEmpty);
      });

      test('parses feedbackStatus M as modified', () {
        const json = '''
{
  "aisData": {
    "pan": "TEST1234F",
    "financialYear": "2023-24",
    "salaryIncome": [
      {"description": "Corp", "pan": "AABCS1234B", "amount": 1000, "feedbackStatus": "M"}
    ],
    "dividendIncome": [],
    "interestIncome": []
  }
}''';
        final result = parser.parseAis(json);
        expect(
          result.salarySources.first.feedbackStatus,
          equals(AisFeedbackStatus.modified),
        );
      });

      test('parses feedbackStatus D as denied', () {
        const json = '''
{
  "aisData": {
    "pan": "TEST1234F",
    "financialYear": "2023-24",
    "salaryIncome": [],
    "dividendIncome": [
      {"description": "Infosys", "pan": "AABCI1234A", "amount": 5000, "feedbackStatus": "D"}
    ],
    "interestIncome": []
  }
}''';
        final result = parser.parseAis(json);
        expect(
          result.dividendSources.first.feedbackStatus,
          equals(AisFeedbackStatus.denied),
        );
      });
    });

    // --------------- parseTis ---------------

    group('parseTis', () {
      const sampleTisJson = '''
{
  "tisData": {
    "pan": "ABCDE1234F",
    "financialYear": "2023-24",
    "salary": 500000,
    "interest": 10000,
    "dividend": 0
  }
}''';

      test('parses PAN from TIS', () {
        final result = parser.parseTis(sampleTisJson);
        expect(result.pan, equals('ABCDE1234F'));
      });

      test('parses financial year from TIS', () {
        final result = parser.parseTis(sampleTisJson);
        expect(result.financialYear, equals('2023-24'));
      });

      test('converts TIS salary to paise in salarySources', () {
        final result = parser.parseTis(sampleTisJson);
        expect(result.salarySources, hasLength(1));
        expect(result.salarySources.first.amount, equals(50000000));
      });

      test('converts TIS interest to paise in interestSources', () {
        final result = parser.parseTis(sampleTisJson);
        expect(result.interestSources, hasLength(1));
        expect(result.interestSources.first.amount, equals(1000000));
      });

      test('skips zero-amount income types in TIS', () {
        final result = parser.parseTis(sampleTisJson);
        expect(result.dividendSources, isEmpty);
      });

      test('TIS salary source has noFeedback status', () {
        final result = parser.parseTis(sampleTisJson);
        expect(
          result.salarySources.first.feedbackStatus,
          equals(AisFeedbackStatus.noFeedback),
        );
      });
    });

    // --------------- Model equality ---------------

    group('AisData model', () {
      test('two identical instances are equal', () {
        const source = AisIncomeSource(
          sourceDescription: 'ABC Ltd',
          sourcePan: 'AAATA1234X',
          amount: 50000000,
          feedbackStatus: AisFeedbackStatus.accepted,
        );
        const a = AisData(
          pan: 'ABCDE1234F',
          financialYear: '2023-24',
          salarySources: [source],
          dividendSources: [],
          interestSources: [],
          capitalGainTransactions: [],
          foreignRemittances: [],
        );
        const b = AisData(
          pan: 'ABCDE1234F',
          financialYear: '2023-24',
          salarySources: [source],
          dividendSources: [],
          interestSources: [],
          capitalGainTransactions: [],
          foreignRemittances: [],
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('copyWith produces updated instance without mutating original', () {
        const original = AisData(
          pan: 'ABCDE1234F',
          financialYear: '2023-24',
          salarySources: [],
          dividendSources: [],
          interestSources: [],
          capitalGainTransactions: [],
          foreignRemittances: [],
        );
        final updated = original.copyWith(financialYear: '2024-25');
        expect(updated.financialYear, equals('2024-25'));
        expect(original.financialYear, equals('2023-24'));
      });
    });

    group('AisIncomeSource model', () {
      test('copyWith updates field immutably', () {
        const src = AisIncomeSource(
          sourceDescription: 'ABC Ltd',
          sourcePan: 'AAATA1234X',
          amount: 50000000,
          feedbackStatus: AisFeedbackStatus.accepted,
        );
        final updated = src.copyWith(amount: 99999900);
        expect(updated.amount, equals(99999900));
        expect(src.amount, equals(50000000));
      });
    });
  });
}
