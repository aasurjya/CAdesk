import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/ai/ocr/document_classifier.dart';
import 'package:ca_app/core/ai/ocr/document_linker.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/gst/domain/models/gst_client.dart';

void main() {
  group('DocumentLinker', () {
    late DocumentLinker linker;

    setUp(() {
      linker = const DocumentLinker();
    });

    // ---------------------------------------------------------------------------
    // Test data helpers
    // ---------------------------------------------------------------------------

    Client client({
      required String id,
      required String pan,
      String name = 'Test Client',
    }) => Client(
      id: id,
      name: name,
      pan: pan,
      clientType: ClientType.individual,
      status: ClientStatus.active,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    GstClient gstClient({
      required String id,
      required String gstin,
      required String pan,
    }) => GstClient(
      id: id,
      businessName: 'Test Business',
      gstin: gstin,
      pan: pan,
      registrationType: GstRegistrationType.regular,
      state: 'Karnataka',
      stateCode: '29',
    );

    final client1 = client(id: 'client_001', pan: 'ABCDE1234F');
    final client2 = client(id: 'client_002', pan: 'PQRST5678G');
    final client3 = client(id: 'client_003', pan: 'XYZWV9012H');

    group('findClientByPan', () {
      test('matches client with exact PAN', () async {
        final id = await linker.findClientByPan('ABCDE1234F', [
          client1,
          client2,
          client3,
        ]);

        expect(id, equals('client_001'));
      });

      test('matching is case-insensitive', () async {
        final id = await linker.findClientByPan('abcde1234f', [
          client1,
          client2,
          client3,
        ]);

        expect(id, equals('client_001'));
      });

      test('returns null when no client matches the PAN', () async {
        final id = await linker.findClientByPan('ZZZZZ9999Z', [
          client1,
          client2,
          client3,
        ]);

        expect(id, isNull);
      });

      test('returns null for empty PAN string', () async {
        final id = await linker.findClientByPan('', [client1]);
        expect(id, isNull);
      });

      test('returns null for whitespace-only PAN', () async {
        final id = await linker.findClientByPan('   ', [client1]);
        expect(id, isNull);
      });

      test('returns null when client list is empty', () async {
        final id = await linker.findClientByPan('ABCDE1234F', []);
        expect(id, isNull);
      });

      test('returns correct client from multiple clients', () async {
        final id = await linker.findClientByPan('PQRST5678G', [
          client1,
          client2,
          client3,
        ]);

        expect(id, equals('client_002'));
      });
    });

    group('findGstClientByGstin', () {
      final gstClient1 = gstClient(
        id: 'gst_001',
        gstin: '29ABCDE1234F1Z5',
        pan: 'ABCDE1234F',
      );
      final gstClient2 = gstClient(
        id: 'gst_002',
        gstin: '07PQRST5678G1ZM',
        pan: 'PQRST5678G',
      );

      test('matches GST client with exact GSTIN', () async {
        final id = await linker.findGstClientByGstin('29ABCDE1234F1Z5', [
          gstClient1,
          gstClient2,
        ]);

        expect(id, equals('gst_001'));
      });

      test('GSTIN matching is case-insensitive', () async {
        final id = await linker.findGstClientByGstin('29abcde1234f1z5', [
          gstClient1,
          gstClient2,
        ]);

        expect(id, equals('gst_001'));
      });

      test('returns null when no GST client matches', () async {
        final id = await linker.findGstClientByGstin('99ZZZZZ9999Z9Z9', [
          gstClient1,
          gstClient2,
        ]);

        expect(id, isNull);
      });

      test('returns null for empty GSTIN', () async {
        final id = await linker.findGstClientByGstin('', [gstClient1]);
        expect(id, isNull);
      });
    });

    group('findClientByPanOrGstin', () {
      test('finds client by direct PAN match', () async {
        final id = await linker.findClientByPanOrGstin('ABCDE1234F', [
          client1,
          client2,
          client3,
        ]);

        expect(id, equals('client_001'));
      });

      test('extracts PAN from GSTIN and matches client', () async {
        // GSTIN 29ABCDE1234F1Z5 → PAN is chars 2..11 = 'ABCDE1234F'
        final id = await linker.findClientByPanOrGstin('29ABCDE1234F1Z5', [
          client1,
          client2,
          client3,
        ]);

        expect(
          id,
          equals('client_001'),
          reason: 'PAN extracted from GSTIN should match client_001',
        );
      });

      test(
        'returns null when neither PAN nor GSTIN-derived PAN matches',
        () async {
          final id = await linker.findClientByPanOrGstin('ZZZZZ9999Z', [
            client1,
            client2,
            client3,
          ]);

          expect(id, isNull);
        },
      );
    });

    group('suggestCategory', () {
      test('form16 maps to tdsDocuments', () {
        expect(
          linker.suggestCategory(DocumentType.form16),
          equals(DocumentCategory.tdsDocuments),
        );
      });

      test('form26as maps to tdsDocuments', () {
        expect(
          linker.suggestCategory(DocumentType.form26as),
          equals(DocumentCategory.tdsDocuments),
        );
      });

      test('gstInvoice maps to gstDocuments', () {
        expect(
          linker.suggestCategory(DocumentType.gstInvoice),
          equals(DocumentCategory.gstDocuments),
        );
      });

      test('bankStatement maps to bankingDocuments', () {
        expect(
          linker.suggestCategory(DocumentType.bankStatement),
          equals(DocumentCategory.bankingDocuments),
        );
      });

      test('panCard maps to kycDocuments', () {
        expect(
          linker.suggestCategory(DocumentType.panCard),
          equals(DocumentCategory.kycDocuments),
        );
      });

      test('aadhaarCard maps to kycDocuments', () {
        expect(
          linker.suggestCategory(DocumentType.aadhaarCard),
          equals(DocumentCategory.kycDocuments),
        );
      });

      test('balanceSheet maps to financialStatements', () {
        expect(
          linker.suggestCategory(DocumentType.balanceSheet),
          equals(DocumentCategory.financialStatements),
        );
      });

      test('salarySlip maps to payrollDocuments', () {
        expect(
          linker.suggestCategory(DocumentType.salarySlip),
          equals(DocumentCategory.payrollDocuments),
        );
      });

      test('unknown maps to generalDocuments', () {
        expect(
          linker.suggestCategory(DocumentType.unknown),
          equals(DocumentCategory.generalDocuments),
        );
      });
    });

    group('buildDocumentTag', () {
      test('builds tag combining docType and clientId', () {
        final tag = linker.buildDocumentTag(DocumentType.form16, 'client_abc');
        expect(tag, equals('form16::client_abc'));
      });

      test('returns only docType name when clientId is null', () {
        final tag = linker.buildDocumentTag(DocumentType.gstInvoice, null);
        expect(tag, equals('gstInvoice'));
      });

      test('returns only docType name when clientId is empty', () {
        final tag = linker.buildDocumentTag(DocumentType.salarySlip, '');
        expect(tag, equals('salarySlip'));
      });
    });
  });
}
