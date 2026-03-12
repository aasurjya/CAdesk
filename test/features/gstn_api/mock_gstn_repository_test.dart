import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/gstn_api/data/mock_gstn_repository.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_token.dart';

void main() {
  late MockGstnRepository repo;

  setUp(() {
    repo = MockGstnRepository();
  });

  group('MockGstnRepository.verifyGstin', () {
    test('returns active result for valid 15-char GSTIN', () async {
      final result = await repo.verifyGstin('29AABCT1332L000');
      expect(result.gstin, '29AABCT1332L000');
      expect(result.status, GstnRegistrationStatus.active);
      expect(result.isValid, isTrue);
      expect(result.legalName, isNotEmpty);
      expect(result.stateCode, '29');
    });

    test('returns invalid result for GSTIN shorter than 15 chars', () async {
      final result = await repo.verifyGstin('SHORT');
      expect(result.isValid, isFalse);
      expect(result.status, GstnRegistrationStatus.cancelled);
    });

    test('returns invalid result for empty GSTIN', () async {
      final result = await repo.verifyGstin('');
      expect(result.isValid, isFalse);
    });

    test('returned model has constitutionType set', () async {
      final result = await repo.verifyGstin('29AABCT1332L000');
      expect(result.constitutionType, isNotEmpty);
    });

    test('registrationDate is set in past', () async {
      final result = await repo.verifyGstin('29AABCT1332L000');
      expect(result.registrationDate.isBefore(DateTime.now()), isTrue);
    });
  });

  group('MockGstnRepository.saveReturn', () {
    test('returns status=saved for valid inputs', () async {
      final status = await repo.saveReturn(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
        '{}',
      );
      expect(status.status, GstnReturnStatus.saved);
      expect(status.gstin, '29AABCT1332L000');
      expect(status.period, '032024');
    });

    test('generated ARN is not null after save', () async {
      final status = await repo.saveReturn(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
        '{}',
      );
      expect(status.arn, isNotNull);
    });

    test('returnType is gstr1 when GSTR1 passed', () async {
      final status = await repo.saveReturn(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
        '{}',
      );
      expect(status.returnType, GstnReturnType.gstr1);
    });

    test('returnType is gstr3b when GSTR3B passed', () async {
      final status = await repo.saveReturn(
        '29AABCT1332L000',
        'GSTR3B',
        '032024',
        '{}',
      );
      expect(status.returnType, GstnReturnType.gstr3b);
    });
  });

  group('MockGstnRepository.submitReturn', () {
    test('returns status=submitted', () async {
      final status = await repo.submitReturn(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
      );
      expect(status.status, GstnReturnStatus.submitted);
    });

    test('gstin and period are preserved', () async {
      final status = await repo.submitReturn(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
      );
      expect(status.gstin, '29AABCT1332L000');
      expect(status.period, '032024');
    });
  });

  group('MockGstnRepository.fileReturn', () {
    test('returns status=filed', () async {
      final status = await repo.fileReturn(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
        '123456',
      );
      expect(status.status, GstnReturnStatus.filed);
    });

    test('ARN matches pattern AA+stateCode+8digits+7digits', () async {
      final status = await repo.fileReturn(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
        '123456',
      );
      expect(status.arn, isNotNull);
      final arn = status.arn!;
      // AA (2) + state code (2) + date DDMMYYYY (8) + sequence (7) = 19 chars
      expect(arn.length, 19);
      expect(arn.startsWith('AA'), isTrue);
    });

    test('filedAt is set after filing', () async {
      final status = await repo.fileReturn(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
        '123456',
      );
      expect(status.filedAt, isNotNull);
    });
  });

  group('MockGstnRepository.getFilingStatus', () {
    test('returns filed status for known period', () async {
      final status = await repo.getFilingStatus(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
      );
      expect(status.status, GstnReturnStatus.filed);
    });

    test('gstin is preserved in status', () async {
      final status = await repo.getFilingStatus(
        '29AABCT1332L000',
        'GSTR1',
        '032024',
      );
      expect(status.gstin, '29AABCT1332L000');
    });
  });

  group('MockGstnRepository.fetchGstr2b', () {
    test('returns generated status', () async {
      final result = await repo.fetchGstr2b('29AABCT1332L000', '032024');
      expect(result.status, Gstr2bStatus.generated);
    });

    test('result has correct gstin and period', () async {
      final result = await repo.fetchGstr2b('29AABCT1332L000', '032024');
      expect(result.gstin, '29AABCT1332L000');
      expect(result.period, '032024');
    });

    test('credit values are non-negative', () async {
      final result = await repo.fetchGstr2b('29AABCT1332L000', '032024');
      expect(result.totalIgstCredit, greaterThanOrEqualTo(0));
      expect(result.totalCgstCredit, greaterThanOrEqualTo(0));
      expect(result.totalSgstCredit, greaterThanOrEqualTo(0));
    });

    test('entryCount is positive', () async {
      final result = await repo.fetchGstr2b('29AABCT1332L000', '032024');
      expect(result.entryCount, greaterThan(0));
    });

    test('generatedAt is set', () async {
      final result = await repo.fetchGstr2b('29AABCT1332L000', '032024');
      expect(result.generatedAt, isNotNull);
    });
  });

  group('MockGstnRepository.getToken', () {
    test('returns a valid token', () async {
      final token = await repo.getToken('29AABCT1332L000', 'testuser', '123456');
      expect(token.accessToken, isNotEmpty);
      expect(token.tokenType, 'Bearer');
    });

    test('token is valid for 6 hours', () async {
      final token = await repo.getToken('29AABCT1332L000', 'testuser', '123456');
      expect(token.expiresIn, 6 * 3600);
    });

    test('token is not expired immediately after issue', () async {
      final token = await repo.getToken('29AABCT1332L000', 'testuser', '123456');
      expect(token.isExpired, isFalse);
    });

    test('expiresAt is issuedAt + expiresIn seconds', () async {
      final token = await repo.getToken('29AABCT1332L000', 'testuser', '123456');
      final expected = token.issuedAt.add(Duration(seconds: token.expiresIn));
      expect(token.expiresAt, expected);
    });
  });
}
