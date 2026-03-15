import 'package:ca_app/features/practice/domain/models/fee_structure.dart';
import 'package:ca_app/features/practice/domain/services/engagement_letter_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = EngagementLetterService.instance;

  final testClient = const ClientData(
    clientId: 'C001',
    name: 'Ramesh Kumar',
    pan: 'ABCPK1234F',
    address: '123 MG Road, Bangalore - 560001',
  );

  final testFirm = const CaFirmData(
    firmName: 'Shah & Associates',
    membershipNumber: '123456',
    firmRegistrationNumber: '001234N',
    address: 'CA Chambers, Nariman Point, Mumbai',
    signatoryName: 'CA Priya Shah',
  );

  const testScope = ['Income Tax Return Filing', 'GST Compliance'];

  const fixedFees = FeeStructure(
    basis: FeeBasis.fixed,
    fixedAmount: 500000, // Rs 5000 in paise
    hourlyRate: null,
    retainerAmount: null,
    billingFrequency: BillingFrequency.annual,
  );

  const hourlyFees = FeeStructure(
    basis: FeeBasis.hourly,
    fixedAmount: null,
    hourlyRate: 150000, // Rs 1500/hr in paise
    retainerAmount: null,
    billingFrequency: BillingFrequency.monthly,
  );

  const retainerFees = FeeStructure(
    basis: FeeBasis.retainer,
    fixedAmount: null,
    hourlyRate: null,
    retainerAmount: 2000000, // Rs 20000/month in paise
    billingFrequency: BillingFrequency.monthly,
  );

  const valueAddedFees = FeeStructure(
    basis: FeeBasis.valueAdded,
    fixedAmount: null,
    hourlyRate: null,
    retainerAmount: null,
    billingFrequency: BillingFrequency.milestone,
  );

  group('EngagementLetterService.instance', () {
    test('singleton returns same instance', () {
      expect(
        identical(EngagementLetterService.instance, service),
        isTrue,
      );
    });
  });

  group('EngagementLetterService.generateLetter', () {
    test('generated letter contains correct client name and PAN', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );

      expect(letter.clientName, 'Ramesh Kumar');
      expect(letter.clientPan, 'ABCPK1234F');
    });

    test('generated letter contains correct firm details', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );

      expect(letter.signatoryName, 'CA Priya Shah');
      expect(letter.membershipNumber, '123456');
      expect(letter.firmName, 'Shah & Associates');
      expect(letter.firmRegistrationNumber, '001234N');
    });

    test('generated letter has a non-empty letterId', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );

      expect(letter.letterId, isNotEmpty);
      expect(letter.letterId, startsWith('letter-'));
    });

    test('scope is stored as unmodifiable copy', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );

      expect(letter.scope, equals(testScope));
      // Attempting to modify should throw
      expect(() => letter.scope.add('New Item'), throwsA(anything));
    });

    test('endDate is approximately one year after startDate', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );

      final diff = letter.endDate.difference(letter.startDate);
      expect(diff.inDays, greaterThanOrEqualTo(364));
      expect(diff.inDays, lessThanOrEqualTo(366));
    });
  });

  group('EngagementLetterService.generateLetterText', () {
    test('letter text contains firm name', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('Shah & Associates'));
    });

    test('letter text contains firm registration number', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('001234N'));
    });

    test('letter text contains client name', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('Ramesh Kumar'));
    });

    test('letter text contains client PAN', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('ABCPK1234F'));
    });

    test('letter text contains scope items numbered', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('1. Income Tax Return Filing'));
      expect(text, contains('2. GST Compliance'));
    });

    test('fixed fee text contains rupee amount', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('Fixed fee'));
      expect(text, contains('₹5000'));
    });

    test('hourly fee text contains rate and frequency', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        hourlyFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('Hourly rate'));
      expect(text, contains('₹1500'));
      expect(text, contains('monthly'));
    });

    test('retainer fee text contains amount and frequency', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        retainerFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('Retainer'));
      expect(text, contains('₹20000'));
    });

    test('value-added fee text does not use hardcoded amount', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        valueAddedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('Value-added fee'));
      expect(text, contains('milestone'));
    });

    test('letter text contains ICAI compliance clause', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('ICAI'));
      expect(text, contains('CONFIDENTIALITY'));
    });

    test('letter text contains signatory details at end', () {
      final letter = service.generateLetter(
        testClient,
        testScope,
        fixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);

      expect(text, contains('CA Priya Shah'));
      expect(text, contains('Membership No.: 123456'));
    });

    test('fixed fee null amount shows "as agreed"', () {
      const nullFixedFees = FeeStructure(
        basis: FeeBasis.fixed,
        fixedAmount: null,
        hourlyRate: null,
        retainerAmount: null,
        billingFrequency: BillingFrequency.annual,
      );
      final letter = service.generateLetter(
        testClient,
        testScope,
        nullFixedFees,
        testFirm,
      );
      final text = service.generateLetterText(letter);
      expect(text, contains('as agreed'));
    });
  });

  group('ClientData', () {
    test('equality — same fields are equal', () {
      const a = ClientData(
        clientId: 'C001',
        name: 'Test',
        pan: 'ABCDE1234F',
        address: 'Test Address',
      );
      const b = ClientData(
        clientId: 'C001',
        name: 'Test',
        pan: 'ABCDE1234F',
        address: 'Test Address',
      );

      expect(a, equals(b));
    });

    test('hashCode is consistent for equal objects', () {
      const a = ClientData(
        clientId: 'C001',
        name: 'Test',
        pan: 'ABCDE1234F',
        address: 'Test Address',
      );
      const b = ClientData(
        clientId: 'C001',
        name: 'Test',
        pan: 'ABCDE1234F',
        address: 'Test Address',
      );

      expect(a.hashCode, b.hashCode);
    });
  });

  group('CaFirmData', () {
    test('equality — same fields are equal', () {
      const a = CaFirmData(
        firmName: 'Firm A',
        membershipNumber: '111111',
        firmRegistrationNumber: '001111N',
        address: 'Addr',
        signatoryName: 'CA A',
      );
      const b = CaFirmData(
        firmName: 'Firm A',
        membershipNumber: '111111',
        firmRegistrationNumber: '001111N',
        address: 'Addr',
        signatoryName: 'CA A',
      );

      expect(a, equals(b));
    });
  });
}
