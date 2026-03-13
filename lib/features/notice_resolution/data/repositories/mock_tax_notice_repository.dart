import 'package:ca_app/features/notice_resolution/domain/models/tax_notice.dart';
import 'package:ca_app/features/notice_resolution/domain/repositories/tax_notice_repository.dart';

class MockTaxNoticeRepository implements TaxNoticeRepository {
  static final List<TaxNotice> _seed = [
    TaxNotice(
      id: 'notice-1',
      clientId: 'client-1',
      noticeType: NoticeType.section143_1,
      issuedDate: DateTime(2024, 9, 1),
      dueDate: DateTime(2024, 12, 31),
      demandAmount: 50000.0,
      status: NoticeStatus.received,
      attachments: const [],
      createdAt: DateTime(2024, 9, 1),
      updatedAt: DateTime(2024, 9, 1),
    ),
    TaxNotice(
      id: 'notice-2',
      clientId: 'client-2',
      noticeType: NoticeType.gstAudit,
      issuedDate: DateTime(2024, 10, 1),
      dueDate: DateTime(2025, 1, 31),
      status: NoticeStatus.inReview,
      attachments: const ['path/to/notice.pdf'],
      createdAt: DateTime(2024, 10, 1),
      updatedAt: DateTime(2024, 10, 5),
    ),
  ];

  final List<TaxNotice> _state = List.of(_seed);

  @override
  Future<void> insert(TaxNotice notice) async {
    _state.add(notice);
  }

  @override
  Future<List<TaxNotice>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((n) => n.clientId == clientId));

  @override
  Future<List<TaxNotice>> getByType(NoticeType noticeType) async =>
      List.unmodifiable(_state.where((n) => n.noticeType == noticeType));

  @override
  Future<List<TaxNotice>> getByStatus(NoticeStatus status) async =>
      List.unmodifiable(_state.where((n) => n.status == status));

  @override
  Future<void> updateStatus(String id, NoticeStatus status) async {
    final idx = _state.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _state[idx] = _state[idx].copyWith(status: status);
  }

  @override
  Future<List<TaxNotice>> getOverdue(DateTime asOf) async =>
      List.unmodifiable(
        _state.where(
          (n) =>
              n.dueDate.isBefore(asOf) && n.status != NoticeStatus.disposed,
        ),
      );
}
