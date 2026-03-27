import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_event.dart';
import 'package:ca_app/features/compliance/data/mappers/compliance_mapper.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  late int testCounter;

  setUpAll(() async {
    database = _createTestDatabase();
    testCounter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  group('ComplianceDao', () {
    ComplianceEvent createTestEvent({
      String? id,
      String? clientId,
      ComplianceEventType? type,
      String? description,
      DateTime? dueDate,
      DateTime? filedDate,
      ComplianceEventStatus? status,
      double? penalty,
    }) {
      testCounter++;
      return ComplianceEvent(
        id: id ?? 'event-$testCounter',
        clientId: clientId ?? 'client-$testCounter',
        type: type ?? ComplianceEventType.itr,
        description: description ?? 'ITR Filing for FY 2024',
        dueDate: dueDate ?? DateTime(2024, 7, 31),
        filedDate: filedDate,
        status: status ?? ComplianceEventStatus.pending,
        penalty: penalty,
      );
    }

    group('insertEvent', () {
      test('inserts event and returns non-empty ID', () async {
        final event = createTestEvent();
        final companion = ComplianceMapper.toCompanion(event);
        final id = await database.complianceDao.insertEvent(companion);
        expect(id, isNotEmpty);
      });

      test('stored event has correct type', () async {
        final event = createTestEvent(type: ComplianceEventType.gst);
        final companion = ComplianceMapper.toCompanion(event);
        await database.complianceDao.insertEvent(companion);
        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved?.type, ComplianceEventType.gst.name);
      });

      test('stored event has correct client ID', () async {
        final event = createTestEvent();
        final companion = ComplianceMapper.toCompanion(event);
        await database.complianceDao.insertEvent(companion);
        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved?.clientId, event.clientId);
      });

      test('stored event has correct due date', () async {
        final event = createTestEvent();
        final companion = ComplianceMapper.toCompanion(event);
        await database.complianceDao.insertEvent(companion);
        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved?.dueDate, event.dueDate);
      });
    });

    group('getEventsByClient', () {
      test('returns events for specific client', () async {
        final event1 = createTestEvent();
        final event2 = createTestEvent(clientId: event1.clientId);

        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event1),
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event2),
        );

        final results = await database.complianceDao.getEventsByClient(
          event1.clientId,
        );
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list for non-existent client', () async {
        final results = await database.complianceDao.getEventsByClient(
          'non-existent',
        );
        expect(results, isEmpty);
      });

      test('filters events by client correctly', () async {
        const client1Id = 'client-filter-1';
        const client2Id = 'client-filter-2';
        final event1 = createTestEvent(clientId: client1Id);
        final event2 = createTestEvent(clientId: client2Id);

        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event1),
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event2),
        );

        final results = await database.complianceDao.getEventsByClient(
          client1Id,
        );
        expect(results.every((e) => e.clientId == client1Id), isTrue);
      });
    });

    group('getEventById', () {
      test('retrieves event by ID', () async {
        final event = createTestEvent();
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved != null, isTrue);
        expect(retrieved?.id, event.id);
      });

      test('returns null for non-existent ID', () async {
        final retrieved = await database.complianceDao.getEventById(
          'non-existent-id',
        );
        expect(retrieved == null, isTrue);
      });
    });

    group('getUpcomingEvents', () {
      test('returns events due within specified days', () async {
        final today = DateTime.now();
        final inThreeDays = today.add(const Duration(days: 3));
        final inFiveDays = today.add(const Duration(days: 5));
        final inTenDays = today.add(const Duration(days: 10));

        final event1 = createTestEvent(dueDate: inThreeDays);
        final event2 = createTestEvent(dueDate: inFiveDays);
        final event3 = createTestEvent(dueDate: inTenDays);

        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event1),
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event2),
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event3),
        );

        final upcoming = await database.complianceDao.getUpcomingEvents(7);
        expect(upcoming.length, greaterThanOrEqualTo(2));
      });

      test('returns empty list when no upcoming events', () async {
        final pastDate = DateTime.now().subtract(const Duration(days: 10));
        final event = createTestEvent(
          dueDate: pastDate,
          status: ComplianceEventStatus.completed,
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final upcoming = await database.complianceDao.getUpcomingEvents(7);
        // Past completed events should not be included
        expect(upcoming.where((e) => e.id == event.id).isEmpty, isTrue);
      });
    });

    group('getOverdueEvents', () {
      test('returns overdue events', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final event = createTestEvent(
          dueDate: yesterday,
          status: ComplianceEventStatus.pending,
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final overdue = await database.complianceDao.getOverdueEvents();
        expect(overdue.where((e) => e.id == event.id).isNotEmpty, isTrue);
      });

      test('excludes completed overdue events', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final event = createTestEvent(
          dueDate: yesterday,
          status: ComplianceEventStatus.completed,
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final overdue = await database.complianceDao.getOverdueEvents();
        expect(overdue.where((e) => e.id == event.id).isEmpty, isTrue);
      });

      test('excludes future events', () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final event = createTestEvent(dueDate: tomorrow);
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final overdue = await database.complianceDao.getOverdueEvents();
        expect(overdue.where((e) => e.id == event.id).isEmpty, isTrue);
      });
    });

    group('updateEventStatus', () {
      test('updates event status successfully', () async {
        final event = createTestEvent();
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final success = await database.complianceDao.updateEventStatus(
          event.id,
          ComplianceEventStatus.filed.name,
        );
        expect(success, isTrue);

        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved?.status, ComplianceEventStatus.filed.name);
      });

      test('updates status from pending to completed', () async {
        final event = createTestEvent(status: ComplianceEventStatus.pending);
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        await database.complianceDao.updateEventStatus(
          event.id,
          ComplianceEventStatus.completed.name,
        );

        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved?.status, ComplianceEventStatus.completed.name);
      });
    });

    group('getEventsByType', () {
      test('returns events of specific type', () async {
        final event1 = createTestEvent(type: ComplianceEventType.itr);
        final event2 = createTestEvent(type: ComplianceEventType.itr);
        final event3 = createTestEvent(type: ComplianceEventType.gst);

        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event1),
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event2),
        );
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event3),
        );

        final results = await database.complianceDao.getEventsByType(
          ComplianceEventType.itr.name,
        );
        expect(results.length, greaterThanOrEqualTo(2));
        expect(
          results.every((e) => e.type == ComplianceEventType.itr.name),
          isTrue,
        );
      });

      test('returns empty list for non-existent type', () async {
        final results = await database.complianceDao.getEventsByType(
          ComplianceEventType.audit.name,
        );
        expect(results, isEmpty);
      });
    });

    group('updateEvent', () {
      test('updates event successfully', () async {
        final event = createTestEvent();
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final updated = event.copyWith(
          status: ComplianceEventStatus.filed,
          filedDate: DateTime(2024, 6, 15),
        );
        final success = await database.complianceDao.updateEvent(
          ComplianceMapper.toCompanion(updated),
        );

        expect(success, isTrue);
        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved?.status, ComplianceEventStatus.filed.name);
        expect(retrieved?.filedDate, DateTime(2024, 6, 15));
      });

      test('updates event with penalty', () async {
        final event = createTestEvent();
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final updated = event.copyWith(penalty: 5000.0);
        await database.complianceDao.updateEvent(
          ComplianceMapper.toCompanion(updated),
        );

        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved?.penalty, 5000.0);
      });
    });

    group('deleteEvent', () {
      test('deletes event successfully', () async {
        final event = createTestEvent();
        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final success = await database.complianceDao.deleteEvent(event.id);
        expect(success, isTrue);

        final retrieved = await database.complianceDao.getEventById(event.id);
        expect(retrieved == null, isTrue);
      });

      test('returns false when deleting non-existent event', () async {
        final success = await database.complianceDao.deleteEvent(
          'non-existent',
        );
        expect(success, isFalse);
      });
    });

    group('watchEventsByClient', () {
      test('emits events for client on watch', () async {
        final event = createTestEvent();

        await database.complianceDao.insertEvent(
          ComplianceMapper.toCompanion(event),
        );

        final stream = database.complianceDao.watchEventsByClient(
          event.clientId,
        );
        expect(
          stream,
          emits(
            isA<List<ComplianceEventRow>>().having(
              (rows) => rows.isNotEmpty,
              'has events',
              true,
            ),
          ),
        );
      });
    });

    group('Immutability', () {
      test('event has copyWith for immutable updates', () {
        final event1 = createTestEvent();
        final event2 = event1.copyWith(status: ComplianceEventStatus.filed);

        expect(event1.status, ComplianceEventStatus.pending);
        expect(event2.status, ComplianceEventStatus.filed);
        expect(event1.id, event2.id);
      });

      test('copyWith preserves all fields when not updated', () {
        final event1 = createTestEvent();
        final event2 = event1.copyWith(status: ComplianceEventStatus.completed);

        expect(event2.clientId, event1.clientId);
        expect(event2.type, event1.type);
        expect(event2.description, event1.description);
        expect(event2.dueDate, event1.dueDate);
      });
    });
  });
}
