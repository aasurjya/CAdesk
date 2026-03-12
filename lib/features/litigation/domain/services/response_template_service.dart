import 'package:ca_app/features/litigation/domain/models/response_template.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';

/// Static service for managing notice response templates.
///
/// Templates use `{placeholder}` syntax for variable substitution.
/// All methods are pure functions with no side effects.
abstract final class ResponseTemplateService {
  // ---------------------------------------------------------------------------
  // Template library
  // ---------------------------------------------------------------------------

  static const Map<NoticeType, ResponseTemplate> _templates = {
    NoticeType.intimation143_1: ResponseTemplate(
      templateId: 'TPL-143-1',
      noticeType: NoticeType.intimation143_1,
      title: 'Response to Intimation u/s 143(1)',
      templateText: '''
Sub: Response to Intimation issued u/s 143(1) of the Income Tax Act, 1961
for Assessment Year {assessmentYear}

Dear Sir/Madam,

With reference to the above intimation dated {noticeDate} bearing reference
number {referenceNumber} for PAN {pan} for Assessment Year {assessmentYear},
I/we hereby submit the following response:

1. The intimation proposes an adjustment/addition of ₹{demandAmount} on account
   of {additionReason}. The same is incorrect for the following reasons:

2. Form 26AS and TDS certificates have been verified. The TDS credits as
   claimed in the original return are correct and duly supported by documentary
   evidence enclosed herewith.

3. The arithmetic computation in the return is correct and in accordance with
   the provisions of the Act.

In view of the above, it is respectfully submitted that the proposed demand of
₹{demandAmount} may kindly be deleted and the original return filed by
the assessee may be accepted as filed.

Thanking You.

Yours faithfully,
{assesseeName}
PAN: {pan}
''',
      requiredDocuments: [
        'Form 26AS (TDS credit statement)',
        'TDS certificates (Form 16/16A)',
        'Original ITR acknowledgement',
        'Bank statements showing income',
        'Computation of income',
      ],
      legalGrounds: [
        'Section 143(1) — CPC intimation',
        'Section 154 — Rectification of mistake apparent from record',
        'Section 245 — Set-off of refund against demand',
      ],
      successRate: 0.82,
    ),

    NoticeType.scrutiny143_2: ResponseTemplate(
      templateId: 'TPL-143-2',
      noticeType: NoticeType.scrutiny143_2,
      title: 'Response to Scrutiny Notice u/s 143(2)',
      templateText: '''
Sub: Response to Notice issued u/s 143(2) of the Income Tax Act, 1961
for Assessment Year {assessmentYear}

Dear Sir/Madam,

With reference to the notice issued u/s 143(2) dated {noticeDate} bearing
DIN {din} for PAN {pan} for Assessment Year {assessmentYear}, we wish to
submit our response as under:

1. In response to the specific queries raised, the assessee submits:
   {queryResponse}

2. All income has been correctly disclosed in the return of income filed on
   {filingDate}.

3. All deductions claimed are within the permissible limits under the Act
   and are supported by documentary evidence.

We request that the assessment be completed accepting the returned income.

Thanking You.

Yours faithfully,
{assesseeName}
PAN: {pan}
''',
      requiredDocuments: [
        'Original ITR with computation',
        'Books of accounts / audited financials',
        'Bank statements (all accounts)',
        'Deduction-supporting documents',
        'Investment proofs',
        'Contract notes / capital gains workings',
      ],
      legalGrounds: [
        'Section 143(2) — Notice for scrutiny',
        'Section 143(3) — Assessment after scrutiny',
        'Section 250 — Procedure in appeal before CIT(A)',
      ],
      successRate: 0.65,
    ),

    NoticeType.assessment143_3: ResponseTemplate(
      templateId: 'TPL-143-3',
      noticeType: NoticeType.assessment143_3,
      title: 'Objections to Assessment Order u/s 143(3)',
      templateText: '''
Sub: Objections to Draft Assessment Order / Response u/s 143(3) for AY {assessmentYear}

Dear Sir/Madam,

With reference to the draft assessment order / assessment order dated
{noticeDate} for PAN {pan} for Assessment Year {assessmentYear},
I/we hereby raise the following objections:

Proposed Addition: ₹{demandAmount} on account of {additionReason}

Grounds of Objection:
1. {groundOne}
2. {groundTwo}
3. The addition made is contrary to the facts and circumstances of the case
   and is without any basis in law.

Supporting Evidence: (enclosed)

We request that the proposed addition be deleted and the returned income be
accepted.

Thanking You.

Yours faithfully,
{assesseeName}
PAN: {pan}
''',
      requiredDocuments: [
        'Books of accounts',
        'Audited financial statements',
        'Supporting vouchers and bills',
        'Bank statements',
        'Previous assessment orders',
        'Case law / judicial precedents',
      ],
      legalGrounds: [
        'Section 143(3) — Assessment',
        'Section 250 — Appeal to CIT(A)',
        'Section 263 — Revision by Principal CIT',
      ],
      successRate: 0.58,
    ),

    NoticeType.reopening148: ResponseTemplate(
      templateId: 'TPL-148',
      noticeType: NoticeType.reopening148,
      title: 'Objections to Reopening Notice u/s 148',
      templateText: '''
Sub: Objections to Notice u/s 148 issued beyond limitation period / Response for AY {assessmentYear}

Dear Sir/Madam,

With reference to the notice issued u/s 148 dated {noticeDate} for PAN {pan}
for Assessment Year {assessmentYear}, I/we submit the following objections:

Preliminary Objection — Limitation:
1. The notice is barred by limitation as the time period prescribed u/s 149
   for issuing a 148 notice has expired. The assessment year in question is
   {assessmentYear} and the last date for issuance was {limitationDate}.

2. No new tangible material has come to the possession of the AO to justify
   reopening of the assessment within the meaning of Explanation 1 to
   Section 148.

3. The reassessment notice amounts to a mere change of opinion which is not
   permissible in law as held in GKN Driveshafts (India) Ltd v ITO [2003]
   259 ITR 19 (SC).

On merits: {meritsResponse}

We request that the notice be dropped forthwith.

Thanking You.

Yours faithfully,
{assesseeName}
PAN: {pan}
''',
      requiredDocuments: [
        'Original return for the relevant AY',
        'Assessment/intimation order for that AY',
        'Evidence that all income was disclosed',
        'CA certificate if required',
        'Calculation of limitation period',
      ],
      legalGrounds: [
        'Section 147 — Income escaping assessment',
        'Section 148 — Notice before assessment',
        'Section 149 — Time limit for notice',
        'GKN Driveshafts — Change of opinion not permissible',
      ],
      successRate: 0.55,
    ),

    NoticeType.penalty156: ResponseTemplate(
      templateId: 'TPL-156',
      noticeType: NoticeType.penalty156,
      title: 'Response to Penalty Notice u/s 156 / 271',
      templateText: '''
Sub: Response to Penalty Notice for Assessment Year {assessmentYear}

Dear Sir/Madam,

With reference to the penalty notice dated {noticeDate} bearing reference
{referenceNumber} for PAN {pan} for Assessment Year {assessmentYear}:

Grounds of Defence:
1. The assessee acted in bona fide belief regarding the tax treatment of the
   relevant income / deduction as the law was not settled at the time of
   filing.

2. The assessee had reasonable cause for the omission / act u/s 273B of the
   Act.

3. There was no concealment of income. Any difference was due to a genuine
   mistake which has since been rectified.

4. The provisions of Section 271(1)(c) require that the AO be satisfied that
   the assessee has concealed income or furnished inaccurate particulars.
   No such satisfaction is recorded in the assessment order.

We respectfully request that the penalty proceedings be dropped.

Thanking You.

Yours faithfully,
{assesseeName}
PAN: {pan}
''',
      requiredDocuments: [
        'Copy of assessment order',
        'Proof of bona fide interpretation',
        'CA opinion letter (if available)',
        'Evidence of reasonable cause',
        'Documents showing voluntary disclosure',
      ],
      legalGrounds: [
        'Section 271(1)(c) — Penalty for concealment',
        'Section 273B — No penalty if reasonable cause',
        'CIT v Reliance Petro Products — Mere claim not concealment',
      ],
      successRate: 0.60,
    ),

    NoticeType.show_cause: ResponseTemplate(
      templateId: 'TPL-SCN',
      noticeType: NoticeType.show_cause,
      title: 'Reply to Show Cause Notice',
      templateText: '''
Sub: Reply to Show Cause Notice dated {noticeDate} for AY {assessmentYear}

Dear Sir/Madam,

With reference to the show cause notice dated {noticeDate} for PAN {pan}
for Assessment Year {assessmentYear}, I/we furnish the following reply:

1. Background: {background}

2. Our Explanation: {explanation}

3. Cause Shown:
   We hereby show cause as to why the proposed {proposedAction} should not
   be made. The assessee has complied with all statutory requirements.

4. Supporting Evidence: enclosed herewith.

In view of the above, we request that the show cause notice be dropped and
no adverse order be passed.

Thanking You.

Yours faithfully,
{assesseeName}
PAN: {pan}
''',
      requiredDocuments: [
        'Relevant books of accounts',
        'Correspondence history',
        'Statutory compliance certificates',
        'Affidavit (if required)',
      ],
      legalGrounds: [
        'Principles of natural justice — audi alteram partem',
        'Section 129 — Change of incumbent',
      ],
      successRate: 0.68,
    ),

    NoticeType.highPitchAssessment: ResponseTemplate(
      templateId: 'TPL-HPA',
      noticeType: NoticeType.highPitchAssessment,
      title: 'Complaint Against High-Pitched Assessment',
      templateText: '''
Sub: Complaint u/s High-Pitched Assessment Guidelines for AY {assessmentYear}

Dear Sir/Madam,

The assessee {assesseeName} (PAN: {pan}) has received an assessment order
u/s 143(3) for AY {assessmentYear} wherein an addition of ₹{demandAmount}
has been made, resulting in a demand which is {multiplier}× the returned income.

This constitutes a "high-pitched assessment" within the meaning of the
CBDT instructions.

We request:
1. Immediate stay of demand pending appeal.
2. Reference of the matter to the Local Committee for High-Pitched Assessment.
3. Action against the assessing officer in accordance with CBDT guidelines.

Grounds:
1. The addition is ex-facie unreasonable and without basis.
2. The principle of fair assessment has been violated.

Thanking You.

Yours faithfully,
{assesseeName}
PAN: {pan}
''',
      requiredDocuments: [
        'Assessment order copy',
        'Computation showing returned vs assessed income',
        'Demand notice',
        'Stay petition',
        'Bank guarantee / security for stay',
      ],
      legalGrounds: [
        'CBDT Instruction No. 17/2015 — High-Pitched Assessments',
        'Section 220(6) — Stay of demand pending appeal',
        'Section 246A — Appeal to CIT(A)',
      ],
      successRate: 0.50,
    ),

    NoticeType.search_seizure: ResponseTemplate(
      templateId: 'TPL-S-S',
      noticeType: NoticeType.search_seizure,
      title: 'Response to Search and Seizure — Block Assessment',
      templateText: '''
Sub: Statement and Response pursuant to Search u/s 132 for AY {assessmentYear}

Dear Sir/Madam,

With reference to the search and seizure operation conducted u/s 132 of the
Income Tax Act, 1961 at the premises of {assesseeName} (PAN: {pan}):

1. Statement on Seized Material: {seizedMaterialExplanation}

2. Source of Unexplained Income/Assets:
   {sourceExplanation}

3. All assets and income disclosed in block returns filed pursuant to
   Section 158BC are derived from legitimate sources.

4. No undisclosed income exists within the meaning of Section 158B.

We request that the block assessment be completed accepting the disclosed income.

Thanking You.

Yours faithfully,
{assesseeName}
PAN: {pan}
''',
      requiredDocuments: [
        'Panchnama copies',
        'List of seized documents',
        'Block return (ITR-B)',
        'Source of funds / asset documentation',
        'Gift deeds / inheritance documents if applicable',
        'Business records explaining cash / inventory',
      ],
      legalGrounds: [
        'Section 132 — Search and seizure',
        'Section 158B — Undisclosed income',
        'Section 158BC — Procedure for block assessment',
        'Section 158BD — Notice in respect of undisclosed income',
      ],
      successRate: 0.40,
    ),
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the [ResponseTemplate] for the given [noticeType].
  static ResponseTemplate getTemplate(NoticeType noticeType) {
    final template = _templates[noticeType];
    if (template == null) {
      throw ArgumentError('No template found for notice type: $noticeType');
    }
    return template;
  }

  /// Fills `{placeholder}` markers in [template.templateText] with values
  /// from [facts]. Placeholders not present in [facts] are left unchanged.
  static String fillTemplate(
    ResponseTemplate template,
    Map<String, String> facts,
  ) {
    var text = template.templateText;
    for (final entry in facts.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  /// Returns the list of required documents for the given [noticeType].
  static List<String> getRequiredDocuments(NoticeType noticeType) {
    return getTemplate(noticeType).requiredDocuments;
  }
}
