import 'package:ca_app/features/notice_resolution/data/datasources/tax_notice_local_source.dart';
import 'package:ca_app/features/notice_resolution/data/datasources/tax_notice_remote_source.dart';
import 'package:ca_app/features/notice_resolution/data/mappers/tax_notice_mapper.dart';
import 'package:ca_app/features/notice_resolution/domain/models/tax_notice.dart';
import 'package:ca_app/features/notice_resolution/domain/repositories/tax_notice_repository.dart';

class TaxNoticeRepositoryImpl implements TaxNoticeRepository {
  const TaxNoticeRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final TaxNoticeRemoteSource remote;
  final TaxNoticeLocalSource local;

  @override
  Future<void> insert(TaxNotice notice) async {
    try {
      final json = await remote.insert(TaxNoticeMapper.toJson(notice));
      final created = TaxNoticeMapper.fromJson(json);
      await local.insert(created);
    } catch (_) {
      await local.insert(notice);
    }
  }

  @override
  Future<List<TaxNotice>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final notices = jsonList.map(TaxNoticeMapper.fromJson).toList();
      for (final notice in notices) {
        await local.insert(notice);
      }
      return List.unmodifiable(notices);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<TaxNotice>> getByType(NoticeType noticeType) async {
    try {
      final jsonList = await remote.fetchByType(noticeType.name);
      final notices = jsonList.map(TaxNoticeMapper.fromJson).toList();
      for (final notice in notices) {
        await local.insert(notice);
      }
      return List.unmodifiable(notices);
    } catch (_) {
      return local.getByType(noticeType);
    }
  }

  @override
  Future<List<TaxNotice>> getByStatus(NoticeStatus status) async {
    try {
      final jsonList = await remote.fetchByStatus(status.name);
      final notices = jsonList.map(TaxNoticeMapper.fromJson).toList();
      for (final notice in notices) {
        await local.insert(notice);
      }
      return List.unmodifiable(notices);
    } catch (_) {
      return local.getByStatus(status);
    }
  }

  @override
  Future<void> updateStatus(String id, NoticeStatus status) async {
    try {
      await remote.update(id, {'status': status.name});
    } catch (_) {
      // Remote failed — local updated below (offline-first)
    }
    await local.updateStatus(id, status);
  }

  @override
  Future<List<TaxNotice>> getOverdue(DateTime asOf) =>
      local.getOverdue(asOf);
}
