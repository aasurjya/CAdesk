import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_deliverable.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_retainer.dart';
import 'package:ca_app/features/sme_cfo/data/repositories/mock_sme_cfo_repository.dart';

void main() {
  group('MockSmeCfoRepository', () {
    late MockSmeCfoRepository repo;

    setUp(() {
      repo = MockSmeCfoRepository();
    });

    // -------------------------------------------------------------------------
    // CfoDeliverable
    // -------------------------------------------------------------------------

    group('CfoDeliverables', () {
      test('getDeliverables returns at least 3 seed items', () async {
        final deliverables = await repo.getDeliverables();
        expect(deliverables.length, greaterThanOrEqualTo(3));
      });

      test('getDeliverableById returns matching deliverable', () async {
        final all = await repo.getDeliverables();
        final first = all.first;
        final found = await repo.getDeliverableById(first.id);
        expect(found?.id, first.id);
      });

      test('getDeliverableById returns null for unknown id', () async {
        final found = await repo.getDeliverableById('no-such-id');
        expect(found, isNull);
      });

      test('getDeliverablesByRetainer filters by retainerId', () async {
        final all = await repo.getDeliverables();
        final retainerId = all.first.retainerId;
        final filtered = await repo.getDeliverablesByRetainer(retainerId);
        expect(filtered.every((d) => d.retainerId == retainerId), isTrue);
      });

      test('getDeliverablesByStatus filters correctly', () async {
        final deliverables = await repo.getDeliverablesByStatus(
          DeliverableStatus.pending,
        );
        expect(
          deliverables.every((d) => d.status == DeliverableStatus.pending),
          isTrue,
        );
      });

      test('insertDeliverable adds deliverable and returns id', () async {
        final deliverable = CfoDeliverable(
          id: 'deliverable-new-001',
          retainerId: 'retainer-001',
          clientName: 'New SME Client',
          title: 'Q1 MIS Report',
          deliverableType: DeliverableType.misReport,
          dueDate: DateTime(2026, 4, 15),
          status: DeliverableStatus.pending,
        );
        final id = await repo.insertDeliverable(deliverable);
        expect(id, deliverable.id);

        final all = await repo.getDeliverables();
        expect(all.any((d) => d.id == 'deliverable-new-001'), isTrue);
      });

      test('updateDeliverable updates existing deliverable', () async {
        final all = await repo.getDeliverables();
        final first = all.first;
        final updated = first.copyWith(status: DeliverableStatus.delivered);
        final success = await repo.updateDeliverable(updated);
        expect(success, isTrue);

        final found = await repo.getDeliverableById(first.id);
        expect(found?.status, DeliverableStatus.delivered);
      });

      test('updateDeliverable returns false for non-existent', () async {
        final ghost = CfoDeliverable(
          id: 'ghost-id',
          retainerId: 'r',
          clientName: 'Ghost',
          title: 'Ghost Deliverable',
          deliverableType: DeliverableType.boardPack,
          dueDate: DateTime(2026),
          status: DeliverableStatus.pending,
        );
        final success = await repo.updateDeliverable(ghost);
        expect(success, isFalse);
      });

      test('deleteDeliverable removes deliverable', () async {
        final all = await repo.getDeliverables();
        final first = all.first;
        final success = await repo.deleteDeliverable(first.id);
        expect(success, isTrue);

        final found = await repo.getDeliverableById(first.id);
        expect(found, isNull);
      });

      test('deleteDeliverable returns false for unknown id', () async {
        final success = await repo.deleteDeliverable('no-such-id');
        expect(success, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // CfoRetainer
    // -------------------------------------------------------------------------

    group('CfoRetainers', () {
      test('getRetainers returns at least 3 seed items', () async {
        final retainers = await repo.getRetainers();
        expect(retainers.length, greaterThanOrEqualTo(3));
      });

      test('getRetainerById returns matching retainer', () async {
        final all = await repo.getRetainers();
        final first = all.first;
        final found = await repo.getRetainerById(first.id);
        expect(found?.id, first.id);
      });

      test('getRetainerById returns null for unknown id', () async {
        final found = await repo.getRetainerById('no-such-id');
        expect(found, isNull);
      });

      test('getRetainersByStatus filters correctly', () async {
        final retainers = await repo.getRetainersByStatus(
          CfoRetainerStatus.active,
        );
        expect(
          retainers.every((r) => r.status == CfoRetainerStatus.active),
          isTrue,
        );
      });

      test('insertRetainer adds retainer and returns id', () async {
        final retainer = CfoRetainer(
          id: 'retainer-new-001',
          clientId: 'client-new',
          clientName: 'New SME Pvt Ltd',
          industry: 'Manufacturing',
          monthlyFee: 18000.0,
          startDate: DateTime(2026, 1, 1),
          nextReviewDate: DateTime(2026, 6, 30),
          deliverables: const ['MIS Report', 'Cash Flow Forecast'],
          status: CfoRetainerStatus.active,
          assignedPartner: 'CA Sharma',
          healthScore: 85,
        );
        final id = await repo.insertRetainer(retainer);
        expect(id, retainer.id);
      });

      test('updateRetainer updates existing retainer', () async {
        final all = await repo.getRetainers();
        final first = all.first;
        final updated = first.copyWith(healthScore: 95);
        final success = await repo.updateRetainer(updated);
        expect(success, isTrue);

        final found = await repo.getRetainerById(first.id);
        expect(found?.healthScore, 95);
      });

      test('updateRetainer returns false for non-existent', () async {
        final ghost = CfoRetainer(
          id: 'ghost-id',
          clientId: 'c',
          clientName: 'Ghost',
          industry: 'None',
          monthlyFee: 0,
          startDate: DateTime(2026),
          nextReviewDate: DateTime(2027),
          deliverables: const [],
          status: CfoRetainerStatus.churned,
          assignedPartner: 'Nobody',
          healthScore: 0,
        );
        final success = await repo.updateRetainer(ghost);
        expect(success, isFalse);
      });

      test('deleteRetainer removes retainer', () async {
        final all = await repo.getRetainers();
        final first = all.first;
        final success = await repo.deleteRetainer(first.id);
        expect(success, isTrue);
      });

      test('deleteRetainer returns false for unknown id', () async {
        final success = await repo.deleteRetainer('no-such-id');
        expect(success, isFalse);
      });
    });
  });
}
