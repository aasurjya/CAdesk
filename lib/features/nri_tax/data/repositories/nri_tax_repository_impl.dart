import 'package:ca_app/features/nri_tax/data/datasources/nri_tax_local_source.dart';
import 'package:ca_app/features/nri_tax/data/datasources/nri_tax_remote_source.dart';
import 'package:ca_app/features/nri_tax/data/mappers/nri_tax_mapper.dart';
import 'package:ca_app/features/nri_tax/domain/models/nri_tax_record.dart';
import 'package:ca_app/features/nri_tax/domain/repositories/nri_tax_repository.dart';

class NriTaxRepositoryImpl implements NriTaxRepository {
  const NriTaxRepositoryImpl({required this.remote, required this.local});

  final NriTaxRemoteSource remote;
  final NriTaxLocalSource local;

  @override
  Future<void> insert(NriTaxRecord record) async {
    try {
      final json = await remote.insert({...NriTaxMapper.toJson(record)});
      final created = NriTaxMapper.fromJson(json);
      await local.insert(created);
    } catch (_) {
      await local.insert(record);
    }
  }

  @override
  Future<List<NriTaxRecord>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final records = jsonList.map(NriTaxMapper.fromJson).toList();
      for (final record in records) {
        await local.insert(record);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<NriTaxRecord>> getByYear(String assessmentYear) async {
    try {
      final jsonList = await remote.fetchByYear(assessmentYear);
      final records = jsonList.map(NriTaxMapper.fromJson).toList();
      for (final record in records) {
        await local.insert(record);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByYear(assessmentYear);
    }
  }

  @override
  Future<void> updateStatus(String id, NriTaxStatus status) async {
    try {
      await remote.update(id, {'status': status.name});
    } catch (_) {
      // Remote failed — local is updated below (offline-first)
    }
    await local.updateStatus(id, status);
  }

  @override
  Future<List<NriTaxRecord>> getScheduleFARequired() async {
    // Schedule FA filter is client-side only; fallback to local.
    return local.getScheduleFARequired();
  }
}
