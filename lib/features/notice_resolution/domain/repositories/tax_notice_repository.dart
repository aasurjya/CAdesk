import 'package:ca_app/features/notice_resolution/domain/models/tax_notice.dart';

abstract class TaxNoticeRepository {
  Future<void> insert(TaxNotice notice);
  Future<List<TaxNotice>> getByClient(String clientId);
  Future<List<TaxNotice>> getByType(NoticeType noticeType);
  Future<List<TaxNotice>> getByStatus(NoticeStatus status);
  Future<void> updateStatus(String id, NoticeStatus status);
  Future<List<TaxNotice>> getOverdue(DateTime asOf);
}
