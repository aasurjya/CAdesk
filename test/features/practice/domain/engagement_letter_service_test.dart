import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/practice/domain/models/fee_structure.dart';
import 'package:ca_app/features/practice/domain/services/engagement_letter_service.dart';

const _client = ClientData(
  clientId: 'client-001',
  name: 'Ramesh Kumar',
  pan: 'ABCDE1234F',
  address: '12, MG Road, Bengaluru - 560001',
);

const _firm = CaFirmData(
  firmName: 'Shah & Associates',
  membershipNumber: '123456',
  firmRegistrationNumber: '001234N',
  address: '5th Floor, Prestige Tower, Bengaluru - 560025',
  signatoryName: 'CA Vikram Shah',
);

const _fixedFee = FeeStructure(
  basis: FeeBasis.fixed,
  fixedAmount: 500000,
  hourlyRate: null,
  retainerAmount: null,
  billingFrequency: BillingFrequency.milestone,
);

void main() {
  group('EngagementLetterService.generateLetter', () {
    test('creates letter with correct client details', () {
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        ['Income Tax Return Filing (ITR-1)', 'Tax Planning Advice'],
        _fixedFee,
        _firm,
      );
      expect(letter.clientName, 'Ramesh Kumar');
      expect(letter.clientPan, 'ABCDE1234F');
    });

    test('includes all scope items', () {
      final scope = ['ITR Filing', 'GST Returns', 'TDS Compliance'];
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        scope,
        _fixedFee,
        _firm,
      );
      expect(letter.scope, scope);
    });

    test('sets firm and signatory details', () {
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        ['ITR Filing'],
        _fixedFee,
        _firm,
      );
      expect(letter.signatoryName, 'CA Vikram Shah');
      expect(letter.membershipNumber, '123456');
      expect(letter.firmName, 'Shah & Associates');
    });

    test('sets start date to today and end date one year later', () {
      final before = DateTime.now();
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        ['ITR Filing'],
        _fixedFee,
        _firm,
      );
      final after = DateTime.now();
      expect(
        letter.startDate.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        letter.endDate.isAfter(letter.startDate),
        isTrue,
      );
      expect(
        letter.endDate.isBefore(after.add(const Duration(days: 366))),
        isTrue,
      );
    });

    test('generates unique letterId per call', () {
      final l1 = EngagementLetterService.instance.generateLetter(
        _client,
        ['ITR'],
        _fixedFee,
        _firm,
      );
      final l2 = EngagementLetterService.instance.generateLetter(
        _client,
        ['GST'],
        _fixedFee,
        _firm,
      );
      expect(l1.letterId, isNot(equals(l2.letterId)));
    });
  });

  group('EngagementLetterService.generateLetterText', () {
    test('includes client name and PAN in letter text', () {
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        ['ITR Filing'],
        _fixedFee,
        _firm,
      );
      final text = EngagementLetterService.instance.generateLetterText(letter);
      expect(text, contains('Ramesh Kumar'));
      expect(text, contains('ABCDE1234F'));
    });

    test('includes ICAI membership number', () {
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        ['ITR Filing'],
        _fixedFee,
        _firm,
      );
      final text = EngagementLetterService.instance.generateLetterText(letter);
      expect(text, contains('123456'));
    });

    test('includes scope of work', () {
      final scope = ['ITR Filing', 'Tax Planning'];
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        scope,
        _fixedFee,
        _firm,
      );
      final text = EngagementLetterService.instance.generateLetterText(letter);
      expect(text, contains('ITR Filing'));
      expect(text, contains('Tax Planning'));
    });

    test('includes confidentiality clause', () {
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        ['ITR Filing'],
        _fixedFee,
        _firm,
      );
      final text = EngagementLetterService.instance.generateLetterText(letter);
      expect(text.toLowerCase(), contains('confidential'));
    });

    test('includes limitation of liability clause', () {
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        ['ITR Filing'],
        _fixedFee,
        _firm,
      );
      final text = EngagementLetterService.instance.generateLetterText(letter);
      expect(text.toLowerCase(), contains('liability'));
    });

    test('includes firm registration number', () {
      final letter = EngagementLetterService.instance.generateLetter(
        _client,
        ['ITR Filing'],
        _fixedFee,
        _firm,
      );
      final text = EngagementLetterService.instance.generateLetterText(letter);
      expect(text, contains('001234N'));
    });
  });
}
