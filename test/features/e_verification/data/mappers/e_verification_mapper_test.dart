import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/e_verification/data/mappers/e_verification_mapper.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';

void main() {
  group('EVerificationMapper', () {
    // -------------------------------------------------------------------------
    // VerificationRequest
    // -------------------------------------------------------------------------
    group('vreqFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'vreq-001',
          'client_name': 'Ramesh Kumar',
          'pan': 'ABCDE1234F',
          'itr_type': 'ITR-1',
          'assessment_year': '2025-26',
          'filing_date': '2025-07-25T00:00:00.000Z',
          'deadline_date': '2025-08-24T00:00:00.000Z',
          'status': 'pending',
          'acknowledgement_number': 'ACK123456789',
        };

        final req = EVerificationMapper.vreqFromJson(json);

        expect(req.id, 'vreq-001');
        expect(req.clientName, 'Ramesh Kumar');
        expect(req.pan, 'ABCDE1234F');
        expect(req.itrType, 'ITR-1');
        expect(req.assessmentYear, '2025-26');
        expect(req.status, VerificationStatus.pending);
        expect(req.acknowledgementNumber, 'ACK123456789');
        expect(req.filingDate.year, 2025);
        expect(req.filingDate.month, 7);
      });

      test('handles null acknowledgement_number', () {
        final json = {
          'id': 'vreq-002',
          'client_name': 'Priya Singh',
          'pan': 'PQRST5678G',
          'itr_type': 'ITR-4',
          'assessment_year': '2025-26',
          'filing_date': '2025-08-01T00:00:00.000Z',
          'deadline_date': '2025-08-31T00:00:00.000Z',
          'status': 'verifiedEvc',
        };

        final req = EVerificationMapper.vreqFromJson(json);
        expect(req.acknowledgementNumber, isNull);
        expect(req.status, VerificationStatus.verifiedEvc);
      });

      test('defaults status to pending for unknown value', () {
        final json = {
          'id': 'vreq-003',
          'client_name': '',
          'pan': 'XXXXX0000X',
          'itr_type': 'ITR-2',
          'assessment_year': '2025-26',
          'filing_date': '2025-08-01T00:00:00.000Z',
          'deadline_date': '2025-08-31T00:00:00.000Z',
          'status': 'unknownStatus',
        };

        final req = EVerificationMapper.vreqFromJson(json);
        expect(req.status, VerificationStatus.pending);
      });

      test('handles all VerificationStatus values', () {
        for (final status in VerificationStatus.values) {
          final json = {
            'id': 'vreq-status-${status.name}',
            'client_name': '',
            'pan': 'ABCDE1234F',
            'itr_type': 'ITR-1',
            'assessment_year': '2025-26',
            'filing_date': '2025-08-01T00:00:00.000Z',
            'deadline_date': '2025-08-31T00:00:00.000Z',
            'status': status.name,
          };
          final req = EVerificationMapper.vreqFromJson(json);
          expect(req.status, status);
        }
      });
    });

    group('vreqToJson', () {
      test('includes all fields and round-trips correctly', () {
        final req = VerificationRequest(
          id: 'vreq-json-001',
          clientName: 'Sunita Patel',
          pan: 'SUNIP1234X',
          itrType: 'ITR-3',
          assessmentYear: '2025-26',
          filingDate: DateTime.utc(2025, 7, 20),
          deadlineDate: DateTime.utc(2025, 8, 19),
          status: VerificationStatus.verifiedDsc,
          acknowledgementNumber: 'DSC999888777',
        );

        final json = EVerificationMapper.vreqToJson(req);

        expect(json['id'], 'vreq-json-001');
        expect(json['client_name'], 'Sunita Patel');
        expect(json['pan'], 'SUNIP1234X');
        expect(json['itr_type'], 'ITR-3');
        expect(json['status'], 'verifiedDsc');
        expect(json['acknowledgement_number'], 'DSC999888777');

        final restored = EVerificationMapper.vreqFromJson(json);
        expect(restored.id, req.id);
        expect(restored.status, req.status);
        expect(restored.acknowledgementNumber, req.acknowledgementNumber);
      });

      test('serializes null acknowledgement_number as null', () {
        final req = VerificationRequest(
          id: 'vreq-null',
          clientName: '',
          pan: 'ABCDE1234F',
          itrType: 'ITR-1',
          assessmentYear: '2025-26',
          filingDate: DateTime.utc(2025, 8, 1),
          deadlineDate: DateTime.utc(2025, 8, 31),
          status: VerificationStatus.expired,
        );

        final json = EVerificationMapper.vreqToJson(req);
        expect(json['acknowledgement_number'], isNull);
      });
    });

    // -------------------------------------------------------------------------
    // SigningRequest
    // -------------------------------------------------------------------------
    group('sreqFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'request_id': 'sreq-001',
          'document_hash': 'abc123def456',
          'document_type': 'itrV',
          'signer_pan': 'ABCDE1234F',
          'signer_name': 'Ramesh Kumar',
          'status': 'signed',
          'signed_at': '2025-08-15T10:30:00.000Z',
          'signature': 'base64sigdata==',
        };

        final req = EVerificationMapper.sreqFromJson(json);

        expect(req.requestId, 'sreq-001');
        expect(req.documentHash, 'abc123def456');
        expect(req.documentType, DocumentType.itrV);
        expect(req.signerPan, 'ABCDE1234F');
        expect(req.signerName, 'Ramesh Kumar');
        expect(req.status, SigningStatus.signed);
        expect(req.signedAt, isNotNull);
        expect(req.signature, 'base64sigdata==');
      });

      test('handles null signedAt and signature', () {
        final json = {
          'request_id': 'sreq-002',
          'document_hash': 'hash000',
          'document_type': 'gstReturn',
          'signer_pan': 'PQRST5678G',
          'signer_name': 'Priya',
          'status': 'pending',
        };

        final req = EVerificationMapper.sreqFromJson(json);
        expect(req.signedAt, isNull);
        expect(req.signature, isNull);
        expect(req.status, SigningStatus.pending);
        expect(req.documentType, DocumentType.gstReturn);
      });

      test('defaults document_type to itrV for unknown value', () {
        final json = {
          'request_id': 'sreq-003',
          'document_hash': 'hash111',
          'document_type': 'unknownDoc',
          'signer_pan': 'XXXXX0000X',
          'signer_name': '',
          'status': 'pending',
        };

        final req = EVerificationMapper.sreqFromJson(json);
        expect(req.documentType, DocumentType.itrV);
      });

      test('handles all DocumentType values', () {
        for (final docType in DocumentType.values) {
          final json = {
            'request_id': 'sreq-doctype-${docType.name}',
            'document_hash': 'hash',
            'document_type': docType.name,
            'signer_pan': 'ABCDE1234F',
            'signer_name': '',
            'status': 'pending',
          };
          final req = EVerificationMapper.sreqFromJson(json);
          expect(req.documentType, docType);
        }
      });

      test('handles all SigningStatus values', () {
        for (final status in SigningStatus.values) {
          final json = {
            'request_id': 'sreq-status-${status.name}',
            'document_hash': 'hash',
            'document_type': 'itrV',
            'signer_pan': 'ABCDE1234F',
            'signer_name': '',
            'status': status.name,
          };
          final req = EVerificationMapper.sreqFromJson(json);
          expect(req.status, status);
        }
      });
    });

    group('sreqToJson', () {
      test('includes all fields and round-trips correctly', () {
        const req = SigningRequest(
          requestId: 'sreq-json-001',
          documentHash: 'sha256hashvalue',
          documentType: DocumentType.auditReport,
          signerPan: 'AUDIT1234X',
          signerName: 'CA Mehta',
          status: SigningStatus.inProgress,
        );

        final json = EVerificationMapper.sreqToJson(req);

        expect(json['request_id'], 'sreq-json-001');
        expect(json['document_hash'], 'sha256hashvalue');
        expect(json['document_type'], 'auditReport');
        expect(json['signer_pan'], 'AUDIT1234X');
        expect(json['status'], 'inProgress');
        expect(json['signed_at'], isNull);
        expect(json['signature'], isNull);

        final restored = EVerificationMapper.sreqFromJson(json);
        expect(restored.requestId, req.requestId);
        expect(restored.documentType, req.documentType);
        expect(restored.status, req.status);
      });
    });
  });
}
