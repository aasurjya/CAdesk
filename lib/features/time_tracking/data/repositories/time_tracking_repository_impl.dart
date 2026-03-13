import 'package:ca_app/features/time_tracking/data/datasources/time_tracking_local_source.dart';
import 'package:ca_app/features/time_tracking/data/datasources/time_tracking_remote_source.dart';
import 'package:ca_app/features/time_tracking/data/mappers/time_entry_mapper.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';
import 'package:ca_app/features/time_tracking/domain/repositories/time_tracking_repository.dart';

class TimeTrackingRepositoryImpl implements TimeTrackingRepository {
  const TimeTrackingRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final TimeTrackingRemoteSource remote;
  final TimeTrackingLocalSource local;

  @override
  Future<String> insertEntry(TimeEntry entry) async {
    try {
      final json = await remote.insert(TimeEntryMapper.toJson(entry));
      final created = TimeEntryMapper.fromJson(json);
      await local.insertEntry(created);
      return created.id;
    } catch (_) {
      return local.insertEntry(entry);
    }
  }

  @override
  Future<List<TimeEntry>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final entries = jsonList.map(TimeEntryMapper.fromJson).toList();
      for (final e in entries) {
        await local.updateEntry(e);
      }
      return List.unmodifiable(entries);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<TimeEntry>> getByDateRange(DateTime from, DateTime to) async {
    try {
      final jsonList = await remote.fetchByDateRange(from, to);
      return List.unmodifiable(
        jsonList.map(TimeEntryMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getByDateRange(from, to);
    }
  }

  @override
  Future<bool> updateEntry(TimeEntry entry) async {
    try {
      await remote.update(entry.id, TimeEntryMapper.toJson(entry));
      return local.updateEntry(entry);
    } catch (_) {
      return local.updateEntry(entry);
    }
  }

  @override
  Future<bool> deleteEntry(String id) async {
    await remote.delete(id);
    return local.deleteEntry(id);
  }

  @override
  Future<List<TimeEntry>> getUnbilled(String clientId) async {
    try {
      final jsonList = await remote.fetchUnbilled(clientId);
      return List.unmodifiable(
        jsonList.map(TimeEntryMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getUnbilled(clientId);
    }
  }

  @override
  Future<double> getTotalHours(String clientId, int month, int year) async {
    // Always use local for aggregation to avoid extra Supabase queries
    return local.getTotalHours(clientId, month, year);
  }
}
