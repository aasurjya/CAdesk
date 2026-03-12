import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/personal_info.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/tax_regime_result.dart';
import 'package:ca_app/features/filing/domain/models/interest_result.dart';
import 'package:ca_app/features/filing/domain/services/tax_computation_engine.dart';
import 'package:ca_app/features/filing/domain/services/interest_computation_service.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

// ---------------------------------------------------------------------------
// Mock seed data
// ---------------------------------------------------------------------------

final _kNow = DateTime(2026, 3, 11);

final _mockJobs = <FilingJob>[
  FilingJob(
    id: 'job-001',
    clientId: 'client-101',
    clientName: 'Ramesh Kumar',
    pan: 'ABCPK1234F',
    assessmentYear: 'AY 2026-27',
    itrType: ItrType.itr1,
    status: FilingJobStatus.draft,
    createdAt: _kNow.subtract(const Duration(days: 5)),
    updatedAt: _kNow.subtract(const Duration(days: 1)),
  ),
  FilingJob(
    id: 'job-002',
    clientId: 'client-102',
    clientName: 'Priya Sharma',
    pan: 'BCDPS5678G',
    assessmentYear: 'AY 2026-27',
    itrType: ItrType.itr1,
    status: FilingJobStatus.review,
    createdAt: _kNow.subtract(const Duration(days: 10)),
    updatedAt: _kNow.subtract(const Duration(days: 2)),
  ),
  FilingJob(
    id: 'job-003',
    clientId: 'client-103',
    clientName: 'Anil Verma',
    pan: 'CDEAV9012H',
    assessmentYear: 'AY 2026-27',
    itrType: ItrType.itr2,
    status: FilingJobStatus.ready,
    createdAt: _kNow.subtract(const Duration(days: 15)),
    updatedAt: _kNow.subtract(const Duration(days: 3)),
  ),
  FilingJob(
    id: 'job-004',
    clientId: 'client-104',
    clientName: 'Sunita Mehta',
    pan: 'DEFSM3456I',
    assessmentYear: 'AY 2025-26',
    itrType: ItrType.itr1,
    status: FilingJobStatus.verified,
    createdAt: _kNow.subtract(const Duration(days: 90)),
    updatedAt: _kNow.subtract(const Duration(days: 30)),
    acknowledgementNumber: 'ACK123456789',
  ),
];

// ---------------------------------------------------------------------------
// Filing jobs notifier
// ---------------------------------------------------------------------------

class FilingJobsNotifier extends Notifier<List<FilingJob>> {
  @override
  List<FilingJob> build() => List.unmodifiable(_mockJobs);

  void add(FilingJob job) {
    state = [...state, job];
  }

  void update(FilingJob updated) {
    state = [
      for (final j in state)
        if (j.id == updated.id) updated else j,
    ];
  }

  void remove(String jobId) {
    state = [
      for (final j in state)
        if (j.id != jobId) j,
    ];
  }
}

final filingJobsProvider =
    NotifierProvider<FilingJobsNotifier, List<FilingJob>>(
      FilingJobsNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active filing job selection
// ---------------------------------------------------------------------------

class _ActiveJobIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void set(String? id) => state = id;
}

/// Currently active filing job ID (set when navigating into a wizard).
final activeFilingJobIdProvider =
    NotifierProvider<_ActiveJobIdNotifier, String?>(_ActiveJobIdNotifier.new);

/// Derived: active filing job resolved from the jobs list.
final activeFilingJobProvider = Provider<FilingJob?>((ref) {
  final id = ref.watch(activeFilingJobIdProvider);
  if (id == null) return null;
  final jobs = ref.watch(filingJobsProvider);
  try {
    return jobs.firstWhere((j) => j.id == id);
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------------------
// ITR-1 form data notifier
// ---------------------------------------------------------------------------

class Itr1FormDataNotifier extends Notifier<Itr1FormData> {
  @override
  Itr1FormData build() => Itr1FormData.empty();

  void reset() {
    state = Itr1FormData.empty();
  }

  void updatePersonalInfo(PersonalInfo info) {
    state = state.copyWith(personalInfo: info);
  }

  void updateSalaryIncome(SalaryIncome income) {
    state = state.copyWith(salaryIncome: income);
  }

  void updateHouseProperty(HousePropertyIncome hp) {
    state = state.copyWith(housePropertyIncome: hp);
  }

  void updateOtherSources(OtherSourceIncome os) {
    state = state.copyWith(otherSourceIncome: os);
  }

  void updateDeductions(ChapterViaDeductions d) {
    state = state.copyWith(deductions: d);
  }

  void updateRegime(TaxRegime regime) {
    state = state.copyWith(selectedRegime: regime);
  }
}

final itr1FormDataProvider =
    NotifierProvider<Itr1FormDataNotifier, Itr1FormData>(
      Itr1FormDataNotifier.new,
    );

// ---------------------------------------------------------------------------
// Derived: live tax computation
// ---------------------------------------------------------------------------

/// Recomputes whenever form data changes. Returns full old vs new comparison.
final liveTaxComputationProvider = Provider<TaxRegimeResult>((ref) {
  final formData = ref.watch(itr1FormDataProvider);
  return TaxComputationEngine.compare(formData);
});

// ---------------------------------------------------------------------------
// Derived: live interest computation
// ---------------------------------------------------------------------------

/// Computes Sections 234A/B/C interest based on the recommended regime tax.
final liveInterestProvider = Provider<InterestResult>((ref) {
  final taxResult = ref.watch(liveTaxComputationProvider);
  final taxPayable = taxResult.recommendedRegime == TaxRegime.newRegime
      ? taxResult.newRegimeTax
      : taxResult.oldRegimeTax;

  return InterestComputationService.compute(
    taxPayable: taxPayable,
    advanceTaxPaid: 0,
    advanceTaxByQuarter: [0, 0, 0, 0],
    filingDate: DateTime(2026, 7, 31),
    dueDate: DateTime(2026, 7, 31),
    assessmentYearStart: DateTime(2026, 4, 1),
  );
});

// ---------------------------------------------------------------------------
// Wizard step tracking
// ---------------------------------------------------------------------------

class _WizardStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void reset() => state = 0;

  void goTo(int step) => state = step;
}

/// Zero-based index of the currently visible wizard step (0..6).
final wizardStepProvider = NotifierProvider<_WizardStepNotifier, int>(
  _WizardStepNotifier.new,
);
