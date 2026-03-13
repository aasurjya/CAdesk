import 'package:ca_app/features/sebi/data/datasources/sebi_local_source.dart';
import 'package:ca_app/features/sebi/data/datasources/sebi_remote_source.dart';
import 'package:ca_app/features/sebi/data/mappers/sebi_mapper.dart';
import 'package:ca_app/features/sebi/domain/models/sebi_compliance_data.dart';
import 'package:ca_app/features/sebi/domain/repositories/sebi_repository.dart';

/// Concrete [SebiRepository] — remote-first with local Drift cache fallback.
class SebiRepositoryImpl implements SebiRepository {
  const SebiRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final SebiRemoteSource remote;
  final SebiLocalSource local;

  @override
  Future<String> insert(SebiComplianceData compliance) async {
    try {
      final json = await remote.insert(SebiMapper.toJson(compliance));
      final created = SebiMapper.fromJson(json);
      await local.insert(created);
      return created.id;
    } catch (_) {
      return local.insert(compliance);
    }
  }

  @override
  Future<List<SebiComplianceData>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final records = jsonList.map(SebiMapper.fromJson).toList();
      for (final r in records) {
        await local.insert(r);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<SebiComplianceData>> getByType(SebiType complianceType) async {
    try {
      final jsonList = await remote.fetchByType(complianceType.name);
      final records = jsonList.map(SebiMapper.fromJson).toList();
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByType(complianceType);
    }
  }

  @override
  Future<List<SebiComplianceData>> getOverdue() async {
    try {
      final jsonList = await remote.fetchOverdue();
      final records = jsonList.map(SebiMapper.fromJson).toList();
      return List.unmodifiable(records);
    } catch (_) {
      return local.getOverdue();
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
}
