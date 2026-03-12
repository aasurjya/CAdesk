import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/models/response_template.dart';

/// Stateless service for managing and filling response templates for
/// Income Tax notices.
///
/// Templates use `{placeholderName}` markers. Call [fillTemplate] to
/// substitute actual values from a facts map.
class ResponseTemplateService {
  ResponseTemplateService._();

  static final ResponseTemplateService instance = ResponseTemplateService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the [ResponseTemplate] for the given [noticeType].
  static ResponseTemplate getTemplate(NoticeType noticeType) {
    return switch (noticeType) {
      NoticeType.intimation143_1 => _template143_1(),
      NoticeType.scrutiny143_2 => _template143_2(),
      NoticeType.assessment143_3 => _template143_3(),
      NoticeType.reopening148 => _template148(),
      NoticeType.penalty156 => _template156(),
      NoticeType.showCause => _templateShowCause(),
      NoticeType.highPitchAssessment => _templateHighPitch(),
      NoticeType.searchSeizure => _templateSearchSeizure(),
    };
  }

  /// Substitutes `{key}` placeholders in [template.templateText] with values
  /// from [facts]. Keys not present in [facts] are left unchanged.
  static String fillTemplate(
    ResponseTemplate template,
    Map<String, String> facts,
  ) {
    var text = template.templateText;
    facts.forEach((key, value) {
      text = text.replaceAll('{$key}', value);
    });
    return text;
  }

  /// Returns the list of documents required for responding to a [noticeType].
  static List<String> getRequiredDocuments(NoticeType noticeType) {
    return getTemplate(noticeType).requiredDocuments;
  }

  // ---------------------------------------------------------------------------
  // Template definitions
  // ---------------------------------------------------------------------------

  static ResponseTemplate _template143_1() {
    return const ResponseTemplate(
      templateId: 'TPL-143-1',
      noticeType: NoticeType.intimation143_1,
      title: 'Response to Intimation u/s 143(1) — CPC Adjustment',
      templateText: '''
To,
The Income Tax Officer / CPC,
{issuedBy}

Sub: Response to Intimation u/s 143(1) for AY {assessmentYear} — PAN {pan}

Sir/Madam,

I/We are in receipt of the intimation dated {issuedDate} for Assessment Year
{assessmentYear} bearing reference number {noticeId}, raising a demand of
₹{demandAmount}.

The intimation appears to have been issued on account of the following
discrepancy: {discrepancyDescription}.

We submit that:

1. TDS Credit: The TDS amount of ₹{tdsAmount} appearing in Form 26AS / AIS has
   not been duly credited. The relevant TDS certificates (Form 16/16A) are
   enclosed as Annexure A.

2. Advance Tax: Advance tax of ₹{advanceTaxAmount} paid vide challan(s) enclosed
   as Annexure B has not been considered.

3. The adjustment/addition is an arithmetical/apparent error and is liable to be
   rectified u/s 154 of the Income Tax Act, 1961.

In view of the above, we humbly request that the demand of ₹{demandAmount} be
withdrawn / revised, and the intimation be issued afresh after considering the
credits mentioned above.

Yours faithfully,
{assesseeName}
PAN: {pan}
Date: {responseDate}
''',
      requiredDocuments: [
        'Form 26AS / Annual Information Statement (AIS)',
        'Form 16 / Form 16A (TDS certificates)',
        'Advance tax payment challans',
        'Copy of original ITR acknowledgement',
        'Copy of intimation u/s 143(1)',
      ],
      legalGrounds: [
        'Section 143(1)(a) — adjustment limited to arithmetical errors only',
        'Section 154 — rectification of apparent mistakes on record',
        'Rule 37BA — credit for TDS where income assessable in hands of another person',
        'CBDT Circular on TDS mismatch — credit cannot be denied for non-matching entries',
      ],
      successRate: 0.82,
    );
  }

  static ResponseTemplate _template143_2() {
    return const ResponseTemplate(
      templateId: 'TPL-143-2',
      noticeType: NoticeType.scrutiny143_2,
      title: 'Response to Notice u/s 143(2) — Scrutiny',
      templateText: '''
To,
The Income Tax Officer,
{issuedBy}

Sub: Response to Notice u/s 143(2) for AY {assessmentYear} — PAN {pan}

Sir/Madam,

With reference to the notice dated {issuedDate} u/s 143(2) for AY {assessmentYear},
we hereby submit the following details and documents in compliance:

1. Source of Income: {sourceOfIncomeDetails}
2. Deductions claimed: {deductionDetails}
3. Capital gains computation: {capitalGainsDetails}
4. High-value transactions (SFT): {sftDetails}

All supporting documents are enclosed. We request that the assessment may be
completed after considering the above explanation.

Note: Under the Faceless Assessment Scheme (NFAC), all submissions must be
made only through the e-Proceedings portal at incometax.gov.in.

Yours faithfully,
{assesseeName}
PAN: {pan}
Date: {responseDate}
''',
      requiredDocuments: [
        'Copy of ITR and all schedules',
        'Form 26AS / AIS / TIS',
        'Bank statements for all accounts',
        'Books of accounts (if applicable)',
        'Proof of deductions claimed (80C, 80D, etc.)',
        'Capital gains computation and broker statements',
        'Loan statements and repayment schedules',
        'High-value transaction explanations',
      ],
      legalGrounds: [
        'Section 143(2) — limited to issues specified in the scrutiny notice',
        'Faceless Assessment Scheme 2019 — NFAC jurisdiction',
        'Section 68/69 — onus of proof and explanation of source',
        'Section 80C to 80U — deduction entitlement with evidence',
      ],
      successRate: 0.65,
    );
  }

  static ResponseTemplate _template143_3() {
    return const ResponseTemplate(
      templateId: 'TPL-143-3',
      noticeType: NoticeType.assessment143_3,
      title: 'Objections to Draft Assessment Order u/s 143(3)',
      templateText: '''
To,
The National Faceless Assessment Centre (NFAC),
{issuedBy}

Sub: Objections to Draft Assessment Order u/s 144B for AY {assessmentYear} — PAN {pan}

Sir/Madam,

We are in receipt of the draft assessment order dated {issuedDate} for AY {assessmentYear}
proposing an addition of ₹{additionAmount} on account of {additionGrounds}.

We respectfully submit the following objections:

1. JURISDICTIONAL OBJECTION: The addition proposed is without jurisdiction as
   the income in question does not fall within the scope of the notice u/s 143(2).

2. VIOLATION OF NATURAL JUSTICE: The opportunity of being heard as mandated
   by Section 144B(1)(xvi) has not been provided before making the addition.

3. ADDITION BASED ON ESTIMATE: The addition is based on estimation/surmise
   without any cogent material on record. Supporting documents evidencing the
   true nature of the transaction are enclosed.

4. FACELESS SCHEME COMPLIANCE: The procedure prescribed under the Faceless
   Assessment Scheme 2019 has not been followed in its entirety.

In view of the foregoing, we request that the proposed addition of ₹{additionAmount}
be deleted and the assessment be completed at the returned income.

Yours faithfully,
{assesseeName}
PAN: {pan}
Date: {responseDate}
''',
      requiredDocuments: [
        'Copy of draft assessment order',
        'Original ITR and all schedules',
        'Ledger account extracts',
        'Contracts / agreements for disputed transactions',
        'Bank statements corroborating the transactions',
        'Expert valuation report (if applicable)',
        'Comparable transaction data',
        'Legal precedents (court decisions) cited in support',
      ],
      legalGrounds: [
        'Section 144B — Faceless assessment procedure must be followed',
        'Section 144B(1)(xvi) — mandatory show-cause notice before adverse order',
        'Section 251 — scope of additions in assessment order',
        'Principles of natural justice — audi alteram partem',
        'CBDT Instruction No. 1/2020 — Faceless Assessment guidelines',
      ],
      successRate: 0.55,
    );
  }

  static ResponseTemplate _template148() {
    return const ResponseTemplate(
      templateId: 'TPL-148',
      noticeType: NoticeType.reopening148,
      title: 'Response to Notice u/s 148 — Reopening of Assessment',
      templateText: '''
To,
The Income Tax Officer,
{issuedBy}

Sub: Response to Notice u/s 148 for AY {assessmentYear} — PAN {pan}

Sir/Madam,

We are in receipt of the notice dated {issuedDate} u/s 148 of the Income Tax Act, 1961
proposing to reassess the income for AY {assessmentYear}.

We raise the following preliminary objections:

1. LIMITATION PERIOD: The reassessment notice is beyond the limitation period
   prescribed u/s 149 of the Act. For escaped income below ₹50 lakh, the limit
   is 3 years from end of relevant AY. The present notice is time-barred.

2. NO TANGIBLE MATERIAL: There is no tangible material to form a reason to
   believe that income has escaped assessment. The notice is based on a change
   of opinion / review of the same material already considered in original
   assessment, which is not permissible (GKN Driveshafts precedent).

3. INCOME ALREADY DISCLOSED: All income was duly offered and assessed in the
   original return for AY {assessmentYear}. There is no escapement of income.

4. SANCTION NOT OBTAINED: Prior approval of the specified authority u/s 151
   has not been validly obtained.

We request that the notice be dropped on the above preliminary grounds before
calling for the return u/s 148.

Yours faithfully,
{assesseeName}
PAN: {pan}
Date: {responseDate}
''',
      requiredDocuments: [
        'Copy of original ITR for AY {assessmentYear}',
        'Copy of original assessment order (if any)',
        'Proof of all income disclosed in original return',
        'Copy of Form 26AS for the relevant year',
        'Response to earlier notices (if any) for the same AY',
      ],
      legalGrounds: [
        'Section 147 — condition: income must have escaped assessment',
        'Section 148 — notice must be issued within limitation period',
        'Section 149 — time limits: 3 years (< ₹50L), 10 years (≥ ₹50L)',
        'Section 151 — prior sanction from specified authority mandatory',
        'GKN Driveshafts (India) Ltd v ITO [2003] — right to file objections',
        'Change of opinion not valid ground for reopening (SC ruling)',
      ],
      successRate: 0.70,
    );
  }

  static ResponseTemplate _template156() {
    return const ResponseTemplate(
      templateId: 'TPL-156',
      noticeType: NoticeType.penalty156,
      title: 'Reply to Demand Notice u/s 156 / Penalty Proceedings',
      templateText: '''
To,
The Income Tax Officer,
{issuedBy}

Sub: Reply to Penalty Notice / Demand u/s 156 for AY {assessmentYear} — PAN {pan}

Sir/Madam,

With reference to the notice dated {issuedDate} u/s 271(1)(c) / 270A raising
a penalty demand of ₹{penaltyAmount} for AY {assessmentYear}, we submit:

1. BONA FIDE BELIEF: The income in question was computed based on a bona fide
   belief as to its taxability. There was no intent to conceal income or furnish
   inaccurate particulars.

2. REASONABLE CAUSE: There existed reasonable cause for the discrepancy, namely:
   {reasonableClause}. Under Section 273B, penalty is not leviable where reasonable
   cause is established.

3. NO CONCEALMENT INTENT: The entire income has been disclosed in the return.
   Any shortfall is due to a computational difference, not deliberate concealment
   u/s 271(1)(c) or misreporting u/s 270A.

4. QUANTUM APPEAL PENDING: The penalty proceedings are consequential upon the
   assessment order, which is currently under appeal. The penalty proceedings
   ought to be kept in abeyance pending final decision on quantum.

In view of the above, we request that the penalty be dropped / waived.

Yours faithfully,
{assesseeName}
PAN: {pan}
Date: {responseDate}
''',
      requiredDocuments: [
        'Copy of assessment order',
        'Copy of penalty notice',
        'Evidence of bona fide belief (legal opinion, CA certificate)',
        'Evidence of reasonable cause',
        'Copy of appeal filed against quantum addition (if any)',
        'Documentary proof of income disclosure',
      ],
      legalGrounds: [
        'Section 271(1)(c) — penalty for concealment / furnishing inaccurate particulars',
        'Section 270A — penalty for under-reporting / misreporting',
        'Section 273B — penalty not leviable where reasonable cause exists',
        'CIT v. Reliance Petroproducts — no penalty if bonafide claim is made',
        'Penalty proceedings are civil in nature — mens rea not required but intention relevant',
      ],
      successRate: 0.68,
    );
  }

  static ResponseTemplate _templateShowCause() {
    return const ResponseTemplate(
      templateId: 'TPL-SCN',
      noticeType: NoticeType.showCause,
      title: 'Response to Show-Cause Notice',
      templateText: '''
To,
The Income Tax Officer,
{issuedBy}

Sub: Response to Show-Cause Notice for AY {assessmentYear} — PAN {pan}

Sir/Madam,

We have received your show-cause notice dated {issuedDate} in connection with
{subjectMatter} for AY {assessmentYear}.

We submit the following explanation:

1. FACTUAL EXPLANATION: {factualExplanation}

2. DOCUMENTARY EVIDENCE: All relevant supporting documents are enclosed as
   Annexure A to Annexure {annexureCount}.

3. BONA FIDE COMPLIANCE: The assessee has at all times acted in good faith and
   in full compliance with the provisions of the Income Tax Act, 1961. There has
   been no deliberate non-compliance or suppression of facts.

4. REQUEST FOR HEARING: We request an opportunity of personal hearing before
   any adverse order is passed, as mandated by the principles of natural justice.

We trust the above explanation and enclosed evidence are sufficient. We request
that the show-cause notice be dropped.

Yours faithfully,
{assesseeName}
PAN: {pan}
Date: {responseDate}
''',
      requiredDocuments: [
        'Supporting documents for factual explanation',
        'Correspondence history with the department',
        'Proof of compliance (if applicable)',
        'Legal precedents supporting assessee\'s position',
      ],
      legalGrounds: [
        'Principles of natural justice — audi alteram partem',
        'Section 273B — reasonable cause defence',
        'Assessee\'s right to be heard before adverse order',
      ],
      successRate: 0.72,
    );
  }

  static ResponseTemplate _templateHighPitch() {
    return const ResponseTemplate(
      templateId: 'TPL-HIGH-PITCH',
      noticeType: NoticeType.highPitchAssessment,
      title: 'Representation Against High-Pitched Assessment',
      templateText: '''
To,
The Principal Commissioner of Income Tax (PCIT),
{issuedBy}

Sub: Representation against High-Pitched Assessment — AY {assessmentYear} — PAN {pan}

Sir/Madam,

The assessment for AY {assessmentYear} vide order dated {issuedDate} raises a demand
of ₹{demandAmount}, which is in excess of 3 times the returned income of ₹{returnedIncome}.
This constitutes a "high-pitched assessment" under the CBDT guidelines.

We bring to your notice:

1. MANDATORY REVIEW: As per the CBDT's "Local Committees on Disputes" mechanism
   (F.No. 225/202/2018-ITA-II), demand exceeding 3× returned income mandates
   review by the PCIT/CIT.

2. ADDITION WITHOUT EVIDENCE: The additions aggregating to ₹{additionAmount} are
   based on assumptions without any corroborative evidence on record.

3. COMPARABLE CASES IGNORED: Well-settled judicial precedents establishing the
   correct tax treatment of {subjectMatter} have been ignored.

4. STAY OF DEMAND: Pending review, we request that recovery proceedings be
   stayed as per CBDT's guidelines on high-pitched assessments.

We request that the matter be reviewed and the demand be reduced to a reasonable
level consistent with the facts on record.

Yours faithfully,
{assesseeName}
PAN: {pan}
Date: {responseDate}
''',
      requiredDocuments: [
        'Copy of assessment order',
        'Computation of income as per return',
        'Computation as per assessment order',
        'Evidence that demand > 3× returned income',
        'Judicial precedents supporting assessee\'s position',
        'CBDT circulars on high-pitched assessments',
      ],
      legalGrounds: [
        'CBDT F.No. 225/202/2018-ITA-II — Local Committees on Disputes',
        'High-pitched assessment guidelines — demand > 3× returned income',
        'Section 220(6) — stay of demand pending appeal',
        'CBDT Instruction No. 1914 — stay of demand guidelines',
      ],
      successRate: 0.60,
    );
  }

  static ResponseTemplate _templateSearchSeizure() {
    return const ResponseTemplate(
      templateId: 'TPL-SEARCH',
      noticeType: NoticeType.searchSeizure,
      title: 'Response in Search & Seizure Proceedings u/s 132',
      templateText: '''
To,
The Income Tax Officer / DDIT(Inv),
{issuedBy}

Sub: Statement / Response in search proceedings u/s 132 — PAN {pan}

Sir/Madam,

With reference to the search conducted on {searchDate} at {searchPremises} under
Section 132 / 132A of the Income Tax Act, 1961, we submit:

1. DECLARATION OF ASSETS: All assets found during search are accounted for as
   detailed in the statement recorded during search. No undisclosed income exists.

2. SEIZED DOCUMENTS: The documents seized belong to {documentsOwner} and relate
   to {documentNature}. These are already reflected in the books of accounts.

3. CASH FOUND: Cash of ₹{cashAmount} found during search represents {cashSource}
   and is fully explained.

4. BLOCK ASSESSMENT PERIOD: We reserve our right to challenge any additions
   proposed in the block assessment for years AY {blockPeriodStart} to
   AY {blockPeriodEnd} on merits.

We engage {counselName} as our authorized representative for all further
proceedings arising from the search.

Yours faithfully,
{assesseeName}
PAN: {pan}
Date: {responseDate}
''',
      requiredDocuments: [
        'Copy of panchnama / search warrant',
        'Books of accounts for the block period',
        'Bank statements for all accounts',
        'Asset valuation reports',
        'Explanation for cash and valuables found',
        'Proof of source of income for block period',
        'Previous assessment orders for block period years',
        'Power of attorney for authorized representative',
      ],
      legalGrounds: [
        'Section 132 — search and seizure conditions',
        'Section 132A — requisition of books',
        'Section 153A — assessment in search cases',
        'Section 153C — assessment of other persons',
        'Satisfaction note must be recorded before initiating search',
        'Seized material must be corroborated independently',
      ],
      successRate: 0.40,
    );
  }
}
