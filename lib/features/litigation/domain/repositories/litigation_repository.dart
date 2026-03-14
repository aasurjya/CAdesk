import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/domain/models/response_template.dart';

/// Abstract contract for litigation data operations.
///
/// Covers tax notices, appeal cases, and response templates.
abstract class LitigationRepository {
  // -------------------------------------------------------------------------
  // TaxNotice operations
  // -------------------------------------------------------------------------

  /// Retrieve all tax notices.
  Future<List<TaxNotice>> getNotices();

  /// Retrieve tax notices for a specific [pan].
  Future<List<TaxNotice>> getNoticesByPan(String pan);

  /// Retrieve tax notices filtered by [status].
  Future<List<TaxNotice>> getNoticesByStatus(NoticeStatus status);

  /// Retrieve a single notice by [noticeId]. Returns null if not found.
  Future<TaxNotice?> getNoticeById(String noticeId);

  /// Insert a new [TaxNotice] and return its ID.
  Future<String> insertNotice(TaxNotice notice);

  /// Update an existing [TaxNotice]. Returns true on success.
  Future<bool> updateNotice(TaxNotice notice);

  /// Delete the notice identified by [noticeId]. Returns true on success.
  Future<bool> deleteNotice(String noticeId);

  // -------------------------------------------------------------------------
  // AppealCase operations
  // -------------------------------------------------------------------------

  /// Retrieve all appeal cases.
  Future<List<AppealCase>> getAppealCases();

  /// Retrieve appeal cases for a specific [pan].
  Future<List<AppealCase>> getAppealCasesByPan(String pan);

  /// Insert a new [AppealCase] and return its ID.
  Future<String> insertAppealCase(AppealCase appealCase);

  /// Update an existing [AppealCase]. Returns true on success.
  Future<bool> updateAppealCase(AppealCase appealCase);

  /// Delete the appeal case identified by [caseId]. Returns true on success.
  Future<bool> deleteAppealCase(String caseId);

  // -------------------------------------------------------------------------
  // ResponseTemplate operations
  // -------------------------------------------------------------------------

  /// Retrieve all response templates.
  Future<List<ResponseTemplate>> getTemplates();

  /// Retrieve response templates for a specific [noticeType].
  Future<List<ResponseTemplate>> getTemplatesByNoticeType(
    NoticeType noticeType,
  );
}
