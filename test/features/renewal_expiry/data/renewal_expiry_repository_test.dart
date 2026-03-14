import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/renewal_item.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/retainer_contract.dart';
import 'package:ca_app/features/renewal_expiry/data/repositories/mock_renewal_expiry_repository.dart';

void main() {
  group('MockRenewalExpiryRepository', () {
    late MockRenewalExpiryRepository repo;

    setUp(() {
      repo = MockRenewalExpiryRepository();
    });

    // -------------------------------------------------------------------------
    // RenewalItem
    // -------------------------------------------------------------------------

    group('RenewalItems', () {
      test('getRenewalItems returns at least 3 seed items', () async {
        final items = await repo.getRenewalItems();
        expect(items.length, greaterThanOrEqualTo(3));
      });

      test('getRenewalItemById returns matching item', () async {
        final all = await repo.getRenewalItems();
        final first = all.first;
        final found = await repo.getRenewalItemById(first.id);
        expect(found?.id, first.id);
      });

      test('getRenewalItemById returns null for unknown id', () async {
        final found = await repo.getRenewalItemById('no-such-id');
        expect(found, isNull);
      });

      test('getRenewalItemsByClient filters by clientId', () async {
        final all = await repo.getRenewalItems();
        final clientId = all.first.clientId;
        final filtered = await repo.getRenewalItemsByClient(clientId);
        expect(filtered.every((i) => i.clientId == clientId), isTrue);
      });

      test('getRenewalItemsByStatus filters correctly', () async {
        final items = await repo.getRenewalItemsByStatus(RenewalStatus.overdue);
        expect(items.every((i) => i.status == RenewalStatus.overdue), isTrue);
      });

      test('insertRenewalItem adds item and returns id', () async {
        final item = RenewalItem(
          id: 'renewal-new-001',
          clientId: 'client-new',
          clientName: 'New Client Ltd',
          itemType: RenewalItemType.dscCertificate,
          dueDate: DateTime(2026, 12, 31),
          status: RenewalStatus.upToDate,
          fee: 1500.0,
          notes: 'Annual DSC renewal',
        );
        final id = await repo.insertRenewalItem(item);
        expect(id, item.id);

        final all = await repo.getRenewalItems();
        expect(all.any((i) => i.id == 'renewal-new-001'), isTrue);
      });

      test('updateRenewalItem updates existing item', () async {
        final all = await repo.getRenewalItems();
        final first = all.first;
        final updated = first.copyWith(status: RenewalStatus.renewed);
        final success = await repo.updateRenewalItem(updated);
        expect(success, isTrue);

        final found = await repo.getRenewalItemById(first.id);
        expect(found?.status, RenewalStatus.renewed);
      });

      test('updateRenewalItem returns false for non-existent', () async {
        final ghost = RenewalItem(
          id: 'ghost-id',
          clientId: 'c',
          clientName: 'Ghost',
          itemType: RenewalItemType.shopAct,
          dueDate: DateTime(2026),
          status: RenewalStatus.upToDate,
          fee: 0.0,
          notes: '',
        );
        final success = await repo.updateRenewalItem(ghost);
        expect(success, isFalse);
      });

      test('deleteRenewalItem removes item', () async {
        final all = await repo.getRenewalItems();
        final first = all.first;
        final success = await repo.deleteRenewalItem(first.id);
        expect(success, isTrue);

        final found = await repo.getRenewalItemById(first.id);
        expect(found, isNull);
      });

      test('deleteRenewalItem returns false for unknown id', () async {
        final success = await repo.deleteRenewalItem('no-such-id');
        expect(success, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // RetainerContract
    // -------------------------------------------------------------------------

    group('RetainerContracts', () {
      test('getRetainerContracts returns at least 3 seed items', () async {
        final contracts = await repo.getRetainerContracts();
        expect(contracts.length, greaterThanOrEqualTo(3));
      });

      test('getRetainerContractById returns matching contract', () async {
        final all = await repo.getRetainerContracts();
        final first = all.first;
        final found = await repo.getRetainerContractById(first.id);
        expect(found?.id, first.id);
      });

      test('getRetainerContractById returns null for unknown id', () async {
        final found = await repo.getRetainerContractById('no-such-id');
        expect(found, isNull);
      });

      test('getRetainerContractsByClient filters by clientId', () async {
        final all = await repo.getRetainerContracts();
        final clientId = all.first.clientId;
        final filtered = await repo.getRetainerContractsByClient(clientId);
        expect(filtered.every((c) => c.clientId == clientId), isTrue);
      });

      test('insertRetainerContract adds contract and returns id', () async {
        final contract = RetainerContract(
          id: 'retainer-new-001',
          clientId: 'client-new',
          clientName: 'New Client Pvt Ltd',
          serviceScope: 'Monthly GST & ITR filing',
          monthlyFee: 5000.0,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 12, 31),
          autoRenew: true,
          status: RetainerStatus.active,
        );
        final id = await repo.insertRetainerContract(contract);
        expect(id, contract.id);
      });

      test('updateRetainerContract updates existing contract', () async {
        final all = await repo.getRetainerContracts();
        final first = all.first;
        final updated = first.copyWith(status: RetainerStatus.paused);
        final success = await repo.updateRetainerContract(updated);
        expect(success, isTrue);

        final found = await repo.getRetainerContractById(first.id);
        expect(found?.status, RetainerStatus.paused);
      });

      test('updateRetainerContract returns false for non-existent', () async {
        final ghost = RetainerContract(
          id: 'ghost-id',
          clientId: 'c',
          clientName: 'Ghost',
          serviceScope: 'Nothing',
          monthlyFee: 0,
          startDate: DateTime(2026),
          endDate: DateTime(2027),
          autoRenew: false,
          status: RetainerStatus.expired,
        );
        final success = await repo.updateRetainerContract(ghost);
        expect(success, isFalse);
      });

      test('deleteRetainerContract removes contract', () async {
        final all = await repo.getRetainerContracts();
        final first = all.first;
        final success = await repo.deleteRetainerContract(first.id);
        expect(success, isTrue);
      });

      test('deleteRetainerContract returns false for unknown id', () async {
        final success = await repo.deleteRetainerContract('no-such-id');
        expect(success, isFalse);
      });
    });
  });
}
