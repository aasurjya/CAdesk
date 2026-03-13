import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_filing_status.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstn_verification_result.dart';
import 'package:ca_app/features/gstn_api/domain/models/gstr2b_fetch_result.dart';
import 'package:ca_app/features/gstn_api/domain/services/gstn_response_mapper.dart';

void main() {
  late GstnResponseMapper mapper;

  setUp(() {
    mapper = GstnResponseMapper();
  });

  group('GstnResponseMapper.mapFilingStatus', () {
    final filedJson = {
      'gstin': '29AABCT1332L000',
      'ret_period': '032024',
      'status': 'CNF',
      'arn': 'AA2903210365234',
      'dof': '11-03-2024 10:30:00',
    };

    test('maps CNF status to filed', () {
      final status = mapper.mapFilingStatus(filedJson);
      expect(status.status, GstnReturnStatus.filed);
    });

    test('maps SUB status to submitted', () {
      final json = {...filedJson, 'status': 'SUB'};
      final status = mapper.mapFilingStatus(json);
      expect(status.status, GstnReturnStatus.submitted);
    });

    test('maps SAV status to saved', () {
      final json = {...filedJson, 'status': 'SAV'};
      final status = mapper.mapFilingStatus(json);
      expect(status.status, GstnReturnStatus.saved);
    });

    test('maps NF status to notFiled', () {
      final json = {...filedJson, 'status': 'NF'};
      final status = mapper.mapFilingStatus(json);
      expect(status.status, GstnReturnStatus.notFiled);
    });

    test('unknown status maps to notFiled as fallback', () {
      final json = {...filedJson, 'status': 'UNKNOWN'};
      final status = mapper.mapFilingStatus(json);
      expect(status.status, GstnReturnStatus.notFiled);
    });

    test('preserves gstin field', () {
      final status = mapper.mapFilingStatus(filedJson);
      expect(status.gstin, '29AABCT1332L000');
    });

    test('preserves period field', () {
      final status = mapper.mapFilingStatus(filedJson);
      expect(status.period, '032024');
    });

    test('preserves arn field', () {
      final status = mapper.mapFilingStatus(filedJson);
      expect(status.arn, 'AA2903210365234');
    });

    test('null arn when missing from json', () {
      final json = Map<String, dynamic>.from(filedJson)..remove('arn');
      final status = mapper.mapFilingStatus(json);
      expect(status.arn, isNull);
    });
  });

  group('GstnResponseMapper.mapVerification', () {
    final activeJson = {
      'status_cd': '1',
      'data': {
        'gstnId': '29AABCT1332L000',
        'tradeNam': 'ABC Traders',
        'lgnm': 'ABC Pvt Ltd',
        'rgdt': '01/07/2017',
        'ctj': 'Private Limited Company',
        'sts': 'Active',
        'stj': '29',
        'dty': 'Regular',
      },
    };

    test('maps Active status to active enum', () {
      final result = mapper.mapVerification(activeJson);
      expect(result.status, GstnRegistrationStatus.active);
    });

    test('maps Cancelled status to cancelled enum', () {
      final json = {
        'status_cd': '1',
        'data': {
          ...(activeJson['data'] as Map<String, dynamic>),
          'sts': 'Cancelled',
        },
      };
      final result = mapper.mapVerification(json);
      expect(result.status, GstnRegistrationStatus.cancelled);
    });

    test('maps Suspended status to suspended enum', () {
      final json = {
        'status_cd': '1',
        'data': {
          ...(activeJson['data'] as Map<String, dynamic>),
          'sts': 'Suspended',
        },
      };
      final result = mapper.mapVerification(json);
      expect(result.status, GstnRegistrationStatus.suspended);
    });

    test('legalName is mapped from lgnm', () {
      final result = mapper.mapVerification(activeJson);
      expect(result.legalName, 'ABC Pvt Ltd');
    });

    test('tradeName is mapped from tradeNam', () {
      final result = mapper.mapVerification(activeJson);
      expect(result.tradeName, 'ABC Traders');
    });

    test('stateCode is mapped from stj', () {
      final result = mapper.mapVerification(activeJson);
      expect(result.stateCode, '29');
    });

    test('constitutionType is mapped from ctj', () {
      final result = mapper.mapVerification(activeJson);
      expect(result.constitutionType, 'Private Limited Company');
    });

    test('registrationDate is parsed from rgdt dd/MM/yyyy', () {
      final result = mapper.mapVerification(activeJson);
      expect(result.registrationDate.year, 2017);
      expect(result.registrationDate.month, 7);
      expect(result.registrationDate.day, 1);
    });

    test('isValid is true for active status', () {
      final result = mapper.mapVerification(activeJson);
      expect(result.isValid, isTrue);
    });

    test('returnFilingFrequency is monthly for Regular', () {
      final result = mapper.mapVerification(activeJson);
      expect(result.returnFilingFrequency, ReturnFilingFrequency.monthly);
    });

    test('returnFilingFrequency is quarterly for Composition', () {
      final json = {
        'status_cd': '1',
        'data': {
          ...(activeJson['data'] as Map<String, dynamic>),
          'dty': 'Composition',
        },
      };
      final result = mapper.mapVerification(json);
      expect(result.returnFilingFrequency, ReturnFilingFrequency.quarterly);
    });
  });

  group('GstnResponseMapper.mapGstr2b', () {
    final generatedJson = {
      'gstin': '29AABCT1332L000',
      'period': '032024',
      'gen_date': '10-03-2024 14:00:00',
      'status': 'generated',
      'igst': 500000,
      'cgst': 250000,
      'sgst': 250000,
      'entry_count': 15,
    };

    test('maps generated status correctly', () {
      final result = mapper.mapGstr2b(generatedJson);
      expect(result.status, Gstr2bStatus.generated);
    });

    test('maps notGenerated status correctly', () {
      final json = {...generatedJson, 'status': 'notGenerated'};
      final result = mapper.mapGstr2b(json);
      expect(result.status, Gstr2bStatus.notGenerated);
    });

    test('maps processing status correctly', () {
      final json = {...generatedJson, 'status': 'processing'};
      final result = mapper.mapGstr2b(json);
      expect(result.status, Gstr2bStatus.processing);
    });

    test('credit fields are mapped correctly', () {
      final result = mapper.mapGstr2b(generatedJson);
      expect(result.totalIgstCredit, 500000);
      expect(result.totalCgstCredit, 250000);
      expect(result.totalSgstCredit, 250000);
    });

    test('entryCount is mapped correctly', () {
      final result = mapper.mapGstr2b(generatedJson);
      expect(result.entryCount, 15);
    });
  });

  group('GstnResponseMapper.extractArn', () {
    test('extracts arn from json', () {
      final json = {'arn': 'AA2903210365234'};
      expect(mapper.extractArn(json), 'AA2903210365234');
    });

    test('returns null when arn is absent', () {
      expect(mapper.extractArn({}), isNull);
    });

    test('returns null when arn is null in json', () {
      final json = {'arn': null};
      expect(mapper.extractArn(json), isNull);
    });
  });

  group('GstnResponseMapper.extractErrorCode', () {
    test('extracts error_code from json', () {
      final json = {'error_code': 'RET003'};
      expect(mapper.extractErrorCode(json), 'RET003');
    });

    test('returns null when absent', () {
      expect(mapper.extractErrorCode({}), isNull);
    });

    test('returns null when null in json', () {
      final json = {'error_code': null};
      expect(mapper.extractErrorCode(json), isNull);
    });
  });
}
