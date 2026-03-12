import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/audit/domain/models/form3cd.dart';
import 'package:ca_app/features/audit/domain/models/form3cd_clause.dart';

// ---------------------------------------------------------------------------
// Audit report status & form type enums
// ---------------------------------------------------------------------------

enum AuditReportStatus {
  draft(label: 'Draft'),
  review(label: 'Review'),
  finalized(label: 'Finalized'),
  filed(label: 'Filed');

  const AuditReportStatus({required this.label});

  final String label;
}

enum AuditFormType {
  form3cd(label: 'Form 3CD'),
  form29b(label: 'Form 29B');

  const AuditFormType({required this.label});

  final String label;
}

// ---------------------------------------------------------------------------
// Audit report summary model
// ---------------------------------------------------------------------------

class AuditReportSummary {
  const AuditReportSummary({
    required this.id,
    required this.clientName,
    required this.formType,
    required this.assessmentYear,
    required this.status,
    required this.completionPercent,
  });

  final String id;
  final String clientName;
  final AuditFormType formType;
  final String assessmentYear;
  final AuditReportStatus status;

  /// 0.0 to 1.0
  final double completionPercent;

  AuditReportSummary copyWith({
    String? id,
    String? clientName,
    AuditFormType? formType,
    String? assessmentYear,
    AuditReportStatus? status,
    double? completionPercent,
  }) {
    return AuditReportSummary(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      formType: formType ?? this.formType,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      status: status ?? this.status,
      completionPercent: completionPercent ?? this.completionPercent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditReportSummary &&
        other.id == id &&
        other.clientName == clientName &&
        other.formType == formType &&
        other.assessmentYear == assessmentYear &&
        other.status == status &&
        other.completionPercent == completionPercent;
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientName,
    formType,
    assessmentYear,
    status,
    completionPercent,
  );
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final auditReportListProvider =
    NotifierProvider<AuditReportListNotifier, List<AuditReportSummary>>(
      AuditReportListNotifier.new,
    );

class AuditReportListNotifier extends Notifier<List<AuditReportSummary>> {
  @override
  List<AuditReportSummary> build() =>
      List<AuditReportSummary>.unmodifiable(_mockReports);

  void updateStatus({
    required String reportId,
    required AuditReportStatus status,
    double? completionPercent,
  }) {
    state = List<AuditReportSummary>.unmodifiable(
      state.map((r) {
        if (r.id == reportId) {
          return r.copyWith(
            status: status,
            completionPercent: completionPercent,
          );
        }
        return r;
      }),
    );
  }
}

// Active / selected report
final activeAuditReportProvider =
    NotifierProvider<ActiveAuditReportNotifier, AuditReportSummary?>(
      ActiveAuditReportNotifier.new,
    );

class ActiveAuditReportNotifier extends Notifier<AuditReportSummary?> {
  @override
  AuditReportSummary? build() => null;

  void select(AuditReportSummary report) => state = report;

  void clear() => state = null;
}

// Filter
final auditFormFilterProvider =
    NotifierProvider<AuditFormFilterNotifier, AuditFormType?>(
      AuditFormFilterNotifier.new,
    );

class AuditFormFilterNotifier extends Notifier<AuditFormType?> {
  @override
  AuditFormType? build() => null;

  void setFilter(AuditFormType? type) => state = type;
}

// Filtered list
final filteredAuditReportsProvider = Provider<List<AuditReportSummary>>((ref) {
  final reports = ref.watch(auditReportListProvider);
  final filter = ref.watch(auditFormFilterProvider);
  if (filter == null) return reports;
  return reports.where((r) => r.formType == filter).toList();
});

// Active Form3CD provider for the clause editor
final activeForm3cdProvider = NotifierProvider<ActiveForm3cdNotifier, Form3CD>(
  ActiveForm3cdNotifier.new,
);

class ActiveForm3cdNotifier extends Notifier<Form3CD> {
  @override
  Form3CD build() => _defaultForm3cd;

  void updateClause(int clauseNumber, {String? response}) {
    final updatedClauses = state.clauses.map((c) {
      if (c.clauseNumber == clauseNumber) {
        return c.copyWith(response: response);
      }
      return c;
    }).toList();
    state = state.copyWith(clauses: updatedClauses);
  }

  void load(Form3CD form) => state = form;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

const _mockReports = <AuditReportSummary>[
  AuditReportSummary(
    id: 'ar-001',
    clientName: 'Mehta Trading Co.',
    formType: AuditFormType.form3cd,
    assessmentYear: '2025-26',
    status: AuditReportStatus.finalized,
    completionPercent: 1.0,
  ),
  AuditReportSummary(
    id: 'ar-002',
    clientName: 'Sharma Textiles Pvt Ltd',
    formType: AuditFormType.form3cd,
    assessmentYear: '2025-26',
    status: AuditReportStatus.review,
    completionPercent: 0.75,
  ),
  AuditReportSummary(
    id: 'ar-003',
    clientName: 'Patel Charitable Trust',
    formType: AuditFormType.form29b,
    assessmentYear: '2025-26',
    status: AuditReportStatus.filed,
    completionPercent: 1.0,
  ),
  AuditReportSummary(
    id: 'ar-004',
    clientName: 'Gupta Electronics',
    formType: AuditFormType.form3cd,
    assessmentYear: '2025-26',
    status: AuditReportStatus.draft,
    completionPercent: 0.2,
  ),
];

final _defaultForm3cd = Form3CD(
  clientName: '',
  pan: '',
  assessmentYear: '2025-26',
  financialYear: 2025,
  businessNature: '',
  clauses: List<Form3CDClause>.unmodifiable(
    List.generate(
      44,
      (i) => Form3CDClause(
        clauseNumber: i + 1,
        description: _clauseDescriptions[i],
        response: '',
        disclosures: const [],
      ),
    ),
  ),
);

const _clauseDescriptions = <String>[
  'Name of the assessee',
  'Address of the assessee',
  'Permanent Account Number (PAN)',
  'Whether liable to pay indirect tax',
  'Nature of business or profession',
  'Books of account and documents examined',
  'Whether P&L includes speculation profit/loss',
  'Relevant clause of Section 44AB',
  'Turnover / gross receipts',
  'Whether prescribed books maintained under Sec 44AA',
  'List of books and address where kept',
  'Whether same accounting method as preceding year',
  'Method of accounting employed',
  'Method of valuation of closing stock',
  'Capital asset converted into stock-in-trade',
  'Amounts not credited to P&L under Sec 28',
  'Land/building transfer — circle rate vs actual',
  'Depreciation allowable as per IT Act',
  'Depreciation — books vs IT Act',
  'Amounts admissible under Secs 33AB to 35E',
  'Interest inadmissible under MSME Act 2006',
  'Payments to persons under Sec 40A(2)(b)',
  'Deemed profits under Secs 32AC/33AB/33ABA',
  'Profit chargeable under Sec 41',
  'Amounts borrowed/repaid on hundi',
  'Payments to related parties — Sec 40A(2)',
  'Deemed income under Secs 32AC/33AB/33ABA',
  'Goods carriage given/taken on hire',
  'Deduction admissible under Sec 32AC',
  'Prior period income/expenditure',
  'Amounts borrowed in cash or demand drafts',
  'Brought forward losses or depreciation',
  'Section 80-IB / 80-IC deductions',
  'TDS compliance',
  'Quantitative details of principal goods',
  'MSME payments beyond 45 days — Sec 43B(h)',
  'Tax on distributed profits (domestic company)',
  'Statement under section 206C',
  'Details of shares bought back',
  'Cash loan receipts — Sec 269SS',
  'Cash loan repayments — Sec 269T',
  'Brought forward loss or depreciation allowance',
  'Deductions under section 80P',
  'GST expenditure breakup',
];
