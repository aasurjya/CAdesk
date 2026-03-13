import 'package:ca_app/features/vda/data/datasources/vda_local_source.dart';
import 'package:ca_app/features/vda/data/datasources/vda_remote_source.dart';
import 'package:ca_app/features/vda/data/mappers/vda_record_mapper.dart';
import 'package:ca_app/features/vda/domain/models/vda_record.dart';
import 'package:ca_app/features/vda/domain/repositories/vda_repository.dart';

class VdaRepositoryImpl implements VdaRepository {
  const VdaRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final VdaRemoteSource remote;
  final VdaLocalSource local;

  @override
  Future<void> insert(VdaRecord record) async {
    try {
      final json = await remote.insert(VdaRecordMapper.toJson(record));
      final created = VdaRecordMapper.fromJson(json);
      await local.insert(created);
    } catch (_) {
      await local.insert(record);
    }
  }

  @override
  Future<List<VdaRecord>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final records = jsonList.map(VdaRecordMapper.fromJson).toList();
      for (final record in records) {
        await local.insert(record);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<VdaRecord>> getByYear(String assessmentYear) async {
    try {
      final jsonList = await remote.fetchByYear(assessmentYear);
      final records = jsonList.map(VdaRecordMapper.fromJson).toList();
      for (final record in records) {
        await local.insert(record);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByYear(assessmentYear);
    }
  }

  @override
  Future<double> getTotalGainLoss(
    String clientId,
    String assessmentYear,
  ) =>
      local.getTotalGainLoss(clientId, assessmentYear);

  @override
  Future<double> getTdsDeducted(
    String clientId,
    String assessmentYear,
  ) =>
      local.getTdsDeducted(clientId, assessmentYear);

  @override
  Future<void> delete(String id) async {
    try {
      await remote.delete(id);
    } catch (_) {
      // Remote deletion failed — local deletion proceeds (offline-first).
    }
    await local.delete(id);
  }
}
