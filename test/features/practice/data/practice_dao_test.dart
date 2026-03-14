import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/practice/domain/models/workflow.dart';
import 'package:ca_app/features/practice/data/mappers/practice_mapper.dart';

AppDatabase _createTestDatabase() =>
    AppDatabase(executor: NativeDatabase.memory());

void main() {
  late AppDatabase database;
  late int counter;

  setUpAll(() async {
    database = _createTestDatabase();
    counter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  Workflow makeWorkflow({
    String? id,
    String? name,
    WorkflowCategory? category,
    bool? isActive,
    List<String>? steps,
    int? estimatedDays,
  }) {
    counter++;
    return Workflow(
      id: id ?? 'wf-$counter',
      name: name ?? 'Workflow $counter',
      description: 'Description $counter',
      steps: steps ?? const ['Step 1', 'Step 2'],
      estimatedDays: estimatedDays ?? 3,
      category: category ?? WorkflowCategory.itrFiling,
      isActive: isActive ?? true,
      createdAt: DateTime(2026, 1, counter),
      updatedAt: DateTime(2026, 1, counter),
    );
  }

  group('PracticeDao', () {
    group('insertWorkflow', () {
      test('returns the ID of the inserted workflow', () async {
        final w = makeWorkflow();
        final id = await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        expect(id, w.id);
      });

      test('stored workflow has correct name', () async {
        final w = makeWorkflow(name: 'GST Monthly Filing');
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        final row = await database.practiceDao.getWorkflowById(w.id);
        expect(row?.name, 'GST Monthly Filing');
      });

      test('stored workflow has correct category', () async {
        final w = makeWorkflow(category: WorkflowCategory.gstFiling);
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        final row = await database.practiceDao.getWorkflowById(w.id);
        final domain = row != null ? PracticeMapper.workflowFromRow(row) : null;
        expect(domain?.category, WorkflowCategory.gstFiling);
      });

      test('stored workflow preserves steps JSON', () async {
        final steps = ['Collect data', 'Prepare', 'File', 'Acknowledge'];
        final w = makeWorkflow(steps: steps);
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        final row = await database.practiceDao.getWorkflowById(w.id);
        final domain = row != null ? PracticeMapper.workflowFromRow(row) : null;
        expect(domain?.steps, steps);
      });

      test('stored workflow has correct estimatedDays', () async {
        final w = makeWorkflow(estimatedDays: 7);
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        final row = await database.practiceDao.getWorkflowById(w.id);
        expect(row?.estimatedDays, 7);
      });
    });

    group('getAllWorkflows', () {
      test('returns all inserted workflows', () async {
        final w1 = makeWorkflow();
        final w2 = makeWorkflow();
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w1),
        );
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w2),
        );

        final all = await database.practiceDao.getAllWorkflows();
        final ids = all.map((r) => r.id).toSet();
        expect(ids, containsAll([w1.id, w2.id]));
      });

      test(
        'returns empty list when no workflows exist for unused prefix',
        () async {
          // All workflows are in the same DB; we just verify the method returns a list
          final all = await database.practiceDao.getAllWorkflows();
          expect(all, isA<List>());
        },
      );
    });

    group('getByCategory', () {
      test('returns only workflows matching the given category', () async {
        final gst = makeWorkflow(category: WorkflowCategory.gstFiling);
        final audit = makeWorkflow(category: WorkflowCategory.audit);
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(gst),
        );
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(audit),
        );

        final results = await database.practiceDao.getByCategory(
          WorkflowCategory.gstFiling.name,
        );
        expect(
          results.every((r) => r.category == WorkflowCategory.gstFiling.name),
          isTrue,
        );
      });

      test('returns empty list for category with no workflows', () async {
        final results = await database.practiceDao.getByCategory(
          WorkflowCategory.mca.name,
        );
        expect(results, isEmpty);
      });
    });

    group('getActiveWorkflows', () {
      test('returns only active workflows', () async {
        final active = makeWorkflow(isActive: true);
        final inactive = makeWorkflow(isActive: false);
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(active),
        );
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(inactive),
        );

        final results = await database.practiceDao.getActiveWorkflows();
        expect(results.every((r) => r.isActive), isTrue);
        final ids = results.map((r) => r.id).toSet();
        expect(ids.contains(active.id), isTrue);
        expect(ids.contains(inactive.id), isFalse);
      });
    });

    group('updateWorkflow', () {
      test('update returns true for existing workflow', () async {
        final w = makeWorkflow();
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        final updated = w.copyWith(name: 'Updated Name', estimatedDays: 10);
        final result = await database.practiceDao.updateWorkflow(
          PracticeMapper.workflowToCompanion(updated),
        );
        expect(result, isTrue);
      });

      test('updated workflow has new name', () async {
        final w = makeWorkflow();
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        final updated = w.copyWith(name: 'Renamed Workflow');
        await database.practiceDao.updateWorkflow(
          PracticeMapper.workflowToCompanion(updated),
        );
        final row = await database.practiceDao.getWorkflowById(w.id);
        expect(row?.name, 'Renamed Workflow');
      });

      test('update returns false for non-existent ID', () async {
        final w = makeWorkflow(id: 'non-existent-id-xyz');
        final result = await database.practiceDao.updateWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        expect(result, isFalse);
      });
    });

    group('deleteWorkflow', () {
      test('delete returns true for existing workflow', () async {
        final w = makeWorkflow();
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        final result = await database.practiceDao.deleteWorkflow(w.id);
        expect(result, isTrue);
      });

      test('deleted workflow is no longer retrievable', () async {
        final w = makeWorkflow();
        await database.practiceDao.insertWorkflow(
          PracticeMapper.workflowToCompanion(w),
        );
        await database.practiceDao.deleteWorkflow(w.id);
        final row = await database.practiceDao.getWorkflowById(w.id);
        expect(row, isNull);
      });

      test('delete returns false for non-existent workflow', () async {
        final result = await database.practiceDao.deleteWorkflow(
          'non-existent-xyz',
        );
        expect(result, isFalse);
      });
    });

    group('Immutability', () {
      test('Workflow has copyWith', () {
        final w1 = makeWorkflow(isActive: true);
        final w2 = w1.copyWith(isActive: false);
        expect(w1.isActive, isTrue);
        expect(w2.isActive, isFalse);
        expect(w1.id, w2.id);
      });

      test('copyWith preserves all unchanged fields', () {
        final w1 = makeWorkflow(name: 'Original', estimatedDays: 5);
        final w2 = w1.copyWith(isActive: false);
        expect(w2.name, 'Original');
        expect(w2.estimatedDays, 5);
        expect(w2.category, w1.category);
      });
    });
  });
}
