import 'package:ca_app/features/income_tax/data/datasources/itr_filing_local_source.dart';
import 'package:ca_app/features/income_tax/data/datasources/itr_filing_remote_source.dart';
import 'package:ca_app/features/income_tax/data/mappers/itr_filing_mapper.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/repositories/itr_filing_repository.dart';

class ItrFilingRepositoryImpl implements ItrFilingRepository {
  const ItrFilingRepositoryImpl({
    required this.remote,
    required this.local,
    this.firmId = '',
  });

  final ItrFilingRemoteSource remote;
  final ItrFilingLocalSource local;
  final String firmId;

  @override
  Future<List<ItrClient>> getAll({String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.fetchAll(firmId: effectiveFirmId);
      final filings = jsonList.map(ItrFilingMapper.fromJson).toList();
      for (final filing in filings) {
        await local.upsert(filing, firmId: effectiveFirmId);
      }
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getAll(firmId: effectiveFirmId);
    }
  }

  @override
  Future<ItrClient?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final filing = ItrFilingMapper.fromJson(json);
      await local.upsert(filing, firmId: firmId);
      return filing;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<ItrClient> create(ItrClient filing) async {
    final json = await remote.insert({
      ...ItrFilingMapper.toJson(filing),
      'firm_id': firmId,
    });
    final created = ItrFilingMapper.fromJson(json);
    await local.upsert(created, firmId: firmId);
    return created;
  }

  @override
  Future<ItrClient> update(ItrClient filing) async {
    final json = await remote.update(filing.id, ItrFilingMapper.toJson(filing));
    final updated = ItrFilingMapper.fromJson(json);
    await local.upsert(updated, firmId: firmId);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await remote.delete(id);
    await local.delete(id);
  }

  @override
  Future<List<ItrClient>> search(String query, {String? firmId}) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.search(query, firmId: effectiveFirmId);
      return List.unmodifiable(jsonList.map(ItrFilingMapper.fromJson).toList());
    } catch (_) {
      return local.search(query, firmId: effectiveFirmId);
    }
  }

  @override
  Future<List<ItrClient>> getByAssessmentYear(
    String ay, {
    String? firmId,
  }) async {
    final effectiveFirmId = firmId ?? this.firmId;
    try {
      final jsonList = await remote.getByAssessmentYear(
        ay,
        firmId: effectiveFirmId,
      );
      return List.unmodifiable(jsonList.map(ItrFilingMapper.fromJson).toList());
    } catch (_) {
      return local.getByAssessmentYear(ay, firmId: effectiveFirmId);
    }
  }

  @override
  Stream<List<ItrClient>> watchAll({String? firmId}) =>
      local.watchAll(firmId: firmId ?? this.firmId);
}
