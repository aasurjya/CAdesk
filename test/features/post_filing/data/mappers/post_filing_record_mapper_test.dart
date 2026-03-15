import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/post_filing/data/mappers/post_filing_record_mapper.dart';
import 'package:ca_app/features/post_filing/domain/models/post_filing_record.dart';

void main() {
  group('PostFilingRecordMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'pfr-001',
          'client_id': 'client-001',
          'filing_id': 'filing-001',
          'activity_type': 'eVerification',
          'status': 'completed',
          'completed_at': '2025-07-20T10:00:00.000Z',
          'notes': 'EVC verified successfully',
          'created_at': '2025-07-15T00:00:00.000Z',
        };

        final record = PostFilingRecordMapper.fromJson(json);

        expect(record.id, 'pfr-001');
        expect(record.clientId, 'client-001');
        expect(record.filingId, 'filing-001');
        expect(record.activityType, PostFilingActivity.eVerification);
        expect(record.status, PostFilingStatus.completed);
        expect(record.completedAt, isNotNull);
        expect(record.notes, 'EVC verified successfully');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'pfr-002',
          'client_id': 'client-002',
          'filing_id': 'filing-002',
          'activity_type': 'itrVDownload',
          'status': 'pending',
          'created_at': '2025-07-15T00:00:00.000Z',
        };

        final record = PostFilingRecordMapper.fromJson(json);
        expect(record.completedAt, isNull);
        expect(record.notes, isNull);
      });

      test('defaults activity_type to itrVDownload for unknown value', () {
        final json = {
          'id': 'pfr-003',
          'client_id': 'c1',
          'filing_id': 'f1',
          'activity_type': 'unknownActivity',
          'status': 'pending',
          'created_at': '2025-07-15T00:00:00.000Z',
        };

        final record = PostFilingRecordMapper.fromJson(json);
        expect(record.activityType, PostFilingActivity.itrVDownload);
      });

      test('defaults status to pending for unknown value', () {
        final json = {
          'id': 'pfr-004',
          'client_id': 'c1',
          'filing_id': 'f1',
          'activity_type': 'refundClaim',
          'status': 'unknownStatus',
          'created_at': '2025-07-15T00:00:00.000Z',
        };

        final record = PostFilingRecordMapper.fromJson(json);
        expect(record.status, PostFilingStatus.pending);
      });

      test('handles all PostFilingActivity values', () {
        for (final activity in PostFilingActivity.values) {
          final json = {
            'id': 'pfr-activity-${activity.name}',
            'client_id': 'c1',
            'filing_id': 'f1',
            'activity_type': activity.name,
            'status': 'pending',
            'created_at': '2025-07-15T00:00:00.000Z',
          };
          final record = PostFilingRecordMapper.fromJson(json);
          expect(record.activityType, activity);
        }
      });

      test('handles all PostFilingStatus values', () {
        for (final status in PostFilingStatus.values) {
          final json = {
            'id': 'pfr-status-${status.name}',
            'client_id': 'c1',
            'filing_id': 'f1',
            'activity_type': 'itrVDownload',
            'status': status.name,
            'created_at': '2025-07-15T00:00:00.000Z',
          };
          final record = PostFilingRecordMapper.fromJson(json);
          expect(record.status, status);
        }
      });
    });

    group('toJson', () {
      late PostFilingRecord sampleRecord;

      setUp(() {
        sampleRecord = PostFilingRecord(
          id: 'pfr-json-001',
          clientId: 'client-json-001',
          filingId: 'filing-json-001',
          activityType: PostFilingActivity.refundClaim,
          status: PostFilingStatus.inProgress,
          completedAt: null,
          notes: 'Refund application submitted',
          createdAt: DateTime(2025, 8, 1),
        );
      });

      test('includes all fields', () {
        final json = PostFilingRecordMapper.toJson(sampleRecord);

        expect(json['id'], 'pfr-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['filing_id'], 'filing-json-001');
        expect(json['activity_type'], 'refundClaim');
        expect(json['status'], 'inProgress');
        expect(json['completed_at'], isNull);
        expect(json['notes'], 'Refund application submitted');
      });

      test('serializes completed_at as ISO string when present', () {
        final completedRecord = sampleRecord.copyWith(
          status: PostFilingStatus.completed,
          completedAt: DateTime(2025, 8, 15),
        );
        final json = PostFilingRecordMapper.toJson(completedRecord);
        expect(json['completed_at'], startsWith('2025-08-15'));
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final completedRecord = PostFilingRecord(
          id: 'pfr-rt',
          clientId: 'c1',
          filingId: 'f1',
          activityType: PostFilingActivity.eVerification,
          status: PostFilingStatus.completed,
          completedAt: DateTime(2025, 8, 10),
          notes: 'Done',
          createdAt: DateTime(2025, 8, 1),
        );
        final json = PostFilingRecordMapper.toJson(completedRecord);
        json['created_at'] = completedRecord.createdAt.toIso8601String();

        final restored = PostFilingRecordMapper.fromJson(json);

        expect(restored.id, completedRecord.id);
        expect(restored.activityType, completedRecord.activityType);
        expect(restored.status, completedRecord.status);
        expect(restored.notes, completedRecord.notes);
      });

      test('serializes null notes correctly', () {
        final noNotesRecord = PostFilingRecord(
          id: 'pfr-nonotes',
          clientId: 'c1',
          filingId: 'f1',
          activityType: PostFilingActivity.itrVDownload,
          status: PostFilingStatus.pending,
          createdAt: DateTime(2025, 8, 1),
        );
        final json = PostFilingRecordMapper.toJson(noNotesRecord);
        expect(json['notes'], isNull);
      });
    });
  });
}
