import 'package:ca_app/features/fema/data/datasources/fema_local_source.dart';
import 'package:ca_app/features/fema/data/datasources/fema_remote_source.dart';
import 'package:ca_app/features/fema/data/mappers/fema_mapper.dart';
import 'package:ca_app/features/fema/domain/models/fema_filing_data.dart';
import 'package:ca_app/features/fema/domain/repositories/fema_repository.dart';

/// Concrete [FemaRepository] — remote-first with local Drift cache fallback.
class FemaRepositoryImpl implements FemaRepository {
  const FemaRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final FemaRemoteSource remote;
  final FemaLocalSource local;

  @override
  Future<String> insert(FemaFilingData filing) async {
    try {
      final json = await remote.insert(FemaMapper.toJson(filing));
      final created = FemaMapper.fromJson(json);
      await local.insert(created);
      return created.id;
    } catch (_) {
      return local.insert(filing);
    }
  }

  @override
  Future<List<FemaFilingData>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final filings = jsonList.map(FemaMapper.fromJson).toList();
      for (final f in filings) {
        await local.insert(f);
      }
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<FemaFilingData>> getByType(FemaType filingType) async {
    try {
      final jsonList = await remote.fetchByType(filingType.name);
      final filings = jsonList.map(FemaMapper.fromJson).toList();
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getByType(filingType);
    }
  }

  @override
  Future<bool> updateStatus(String id, String status) async {
    try {
      await remote.updateStatus(id, status);
      return local.updateStatus(id, status);
    } catch (_) {
      return local.updateStatus(id, status);
    }
  }

  @override
  Future<List<FemaFilingData>> getByYear(String clientId, int year) async {
    try {
      final jsonList = await remote.fetchByYear(clientId, year);
      final filings = jsonList.map(FemaMapper.fromJson).toList();
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getByYear(clientId, year);
    }
  }
}
