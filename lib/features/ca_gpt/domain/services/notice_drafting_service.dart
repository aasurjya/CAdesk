import 'package:ca_app/features/ca_gpt/domain/models/notice_draft.dart';

/// Stateless service for drafting notice replies and legal documents.
///
/// Contains built-in templates for common Income Tax notices.
/// All methods are static — no instantiation required.
class NoticeDraftingService {
  NoticeDraftingService._();

  // ---------------------------------------------------------------------------
  // Template registry
  // ---------------------------------------------------------------------------

  static const Map<String, String> _templates = {
    '143_1': '''To,
The Centralised Processing Centre,
Income Tax Department.

Subject: Reply to Intimation under Section 143(1) for Assessment Year {assessmentYear}

PAN: {pan}
Name: {taxpayerName}

Respected Sir/Madam,

I, {taxpayerName}, PAN {pan}, hereby submit my reply to the intimation received under Section 143(1) of the Income Tax Act, 1961, for Assessment Year {assessmentYear}.

Grounds of Objection:
{groundsOfAppeal}

Relief Sought:
{reliefSought}

I request the hon'ble CPC to kindly review the above and pass suitable rectification order.

Yours faithfully,
{taxpayerName}
PAN: {pan}''',

    '143_3': '''To,
The Assessing Officer,
Income Tax Department.

Subject: Reply to Notice under Section 142(1) / Assessment under Section 143(3) for Assessment Year {assessmentYear}

PAN: {pan}
Name: {taxpayerName}

Respected Sir/Madam,

In response to the notice/draft assessment order for Assessment Year {assessmentYear}, I, {taxpayerName} (PAN: {pan}), respectfully submit the following reply:

Grounds of Objection:
{groundsOfAppeal}

Relief Sought:
{reliefSought}

Supporting documents are enclosed herewith. I request the hon'ble Assessing Officer to consider the above submissions and pass a speaking order.

Yours faithfully,
{taxpayerName}
PAN: {pan}''',

    'appeal': '''Before the Commissioner of Income Tax (Appeals)

Memorandum of Appeal

Appellant: {taxpayerName}
PAN: {pan}
Assessment Year: {assessmentYear}

Subject: Appeal against the Order of Assessment under Section 143(3) / 144 / 147 for Assessment Year {assessmentYear}

Grounds of Appeal:
{groundsOfAppeal}

Relief Sought:
{reliefSought}

The appellant humbly prays that the hon'ble CIT(A) may be pleased to grant the relief sought above and pass such other orders as may be deemed fit.

{taxpayerName}
(Appellant)''',

    'rectification': '''To,
The Income Tax Officer / Assessing Officer,
Income Tax Department.

Subject: Application for Rectification under Section 154 for Assessment Year {assessmentYear}

PAN: {pan}
Name: {taxpayerName}

Respected Sir/Madam,

I, {taxpayerName} (PAN: {pan}), respectfully draw your attention to a mistake apparent from record in the order passed for Assessment Year {assessmentYear}.

Grounds for Rectification:
{groundsOfAppeal}

Relief Sought:
{reliefSought}

I request the rectification of the above mistake and issuance of a revised order.

Yours faithfully,
{taxpayerName}
PAN: {pan}''',

    'condonation': '''To,
The Chief Commissioner of Income Tax / Commissioner of Income Tax,
Income Tax Department.

Subject: Application for Condonation of Delay for Assessment Year {assessmentYear}

PAN: {pan}
Name: {taxpayerName}

Respected Sir/Madam,

I, {taxpayerName} (PAN: {pan}), humbly request condonation of delay in filing/submitting for Assessment Year {assessmentYear}.

Reasons for Delay:
{groundsOfAppeal}

Relief Sought:
{reliefSought}

I assure that the delay was not intentional and request the hon'ble authority to condone the same in the interest of justice.

Yours faithfully,
{taxpayerName}
PAN: {pan}''',

    'penalty': '''To,
The Assessing Officer,
Income Tax Department.

Subject: Reply to Show Cause Notice for Penalty for Assessment Year {assessmentYear}

PAN: {pan}
Name: {taxpayerName}

Respected Sir/Madam,

In response to the show cause notice proposing penalty for Assessment Year {assessmentYear}, I, {taxpayerName} (PAN: {pan}), submit the following reply:

Grounds:
{groundsOfAppeal}

Relief Sought:
{reliefSought}

I submit that the conditions for levy of penalty are not satisfied and request that the proposed penalty be dropped.

Yours faithfully,
{taxpayerName}
PAN: {pan}''',

    'revision': '''To,
The Principal Commissioner of Income Tax / Commissioner of Income Tax,
Income Tax Department.

Subject: Application for Revision under Section 264 for Assessment Year {assessmentYear}

PAN: {pan}
Name: {taxpayerName}

Respected Sir/Madam,

I, {taxpayerName} (PAN: {pan}), hereby apply for revision of the order passed for Assessment Year {assessmentYear} under Section 264 of the Income Tax Act, 1961.

Grounds for Revision:
{groundsOfAppeal}

Relief Sought:
{reliefSought}

I request the hon'ble authority to revise the order and grant the relief sought above.

Yours faithfully,
{taxpayerName}
PAN: {pan}''',
  };

  // ---------------------------------------------------------------------------
  // NoticeType mapping
  // ---------------------------------------------------------------------------

  static const Map<String, NoticeType> _typeMap = {
    '143_1': NoticeType.reply143_1,
    '143_3': NoticeType.reply143_3,
    'appeal': NoticeType.appeal,
    'rectification': NoticeType.rectification,
    'condonation': NoticeType.condonation,
    'penalty': NoticeType.penalty,
    'revision': NoticeType.revision,
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Drafts a reply for the given [noticeType] using the supplied [facts].
  ///
  /// [noticeType] must be one of: 143_1, 143_3, appeal, rectification,
  /// condonation, penalty, revision.
  ///
  /// [facts] should contain keys: taxpayerName, pan, assessmentYear,
  /// groundsOfAppeal, reliefSought.
  ///
  /// Each call produces a new [NoticeDraft] with a unique [draftId].
  static NoticeDraft draftReply(String noticeType, Map<String, String> facts) {
    final template = getTemplate(noticeType);
    final draftText = fillTemplate(template, facts);
    final resolvedType = _typeMap[noticeType] ?? NoticeType.reply143_1;

    final rawGrounds = facts['groundsOfAppeal'] ?? '';
    final groundsList = rawGrounds.isEmpty
        ? const <String>[]
        : rawGrounds.split('\n');

    // Use microseconds for uniqueness within the same process invocation.
    final draftId =
        'draft_${noticeType}_${DateTime.now().microsecondsSinceEpoch}';

    return NoticeDraft(
      draftId: draftId,
      noticeType: resolvedType,
      originalNoticeDate: DateTime.now(),
      assessmentYear: facts['assessmentYear'] ?? '',
      taxpayerName: facts['taxpayerName'] ?? '',
      pan: facts['pan'] ?? '',
      groundsOfAppeal: groundsList,
      draftText: draftText,
      templateUsed: noticeType,
    );
  }

  /// Returns the raw template string for the given [noticeType].
  ///
  /// Returns a generic fallback template for unknown notice types.
  static String getTemplate(String noticeType) {
    return _templates[noticeType] ??
        '''To,
The Concerned Authority.

Subject: Reply / Application for Assessment Year {assessmentYear}

PAN: {pan}
Name: {taxpayerName}

Respected Sir/Madam,

{taxpayerName} (PAN: {pan}) respectfully submits:

Grounds:
{groundsOfAppeal}

Relief Sought:
{reliefSought}

Yours faithfully,
{taxpayerName}''';
  }

  /// Fills all `{key}` placeholders in [template] with values from [facts].
  ///
  /// Placeholders with no corresponding key in [facts] are left unchanged.
  static String fillTemplate(String template, Map<String, String> facts) {
    if (template.isEmpty) return '';
    var result = template;
    facts.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
