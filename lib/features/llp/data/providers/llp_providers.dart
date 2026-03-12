import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/llp/domain/models/llp_form11.dart';
import 'package:ca_app/features/llp/domain/models/llp_penalty_computation.dart';
import 'package:ca_app/features/llp/domain/services/llp_form11_service.dart';
import 'package:ca_app/features/llp/domain/services/llp_form8_service.dart';

// ---------------------------------------------------------------------------
// LLP compliance status
// ---------------------------------------------------------------------------

/// Filing status for a specific form.
enum LlpFilingStatus {
  filed,
  overdue,
  pending,
  notDue,
}

/// Immutable presentation model for an LLP entity.
class LlpEntity {
  const LlpEntity({
    required this.id,
    required this.llpin,
    required this.name,
    required this.registeredOffice,
    required this.partners,
    required this.totalContributionPaise,
    required this.form8Status,
    required this.form11Status,
    required this.itr5Status,
    required this.form8FiledDate,
    required this.form11FiledDate,
    required this.financialYear,
  });

  final String id;
  final String llpin;
  final String name;
  final String registeredOffice;
  final List<LlpPartnerDetail> partners;
  final int totalContributionPaise;
  final LlpFilingStatus form8Status;
  final LlpFilingStatus form11Status;
  final LlpFilingStatus itr5Status;
  final DateTime? form8FiledDate;
  final DateTime? form11FiledDate;

  /// Financial year ending year (e.g., 2025 for FY 2024-25).
  final int financialYear;

  int get numberOfPartners => partners.length;

  List<LlpPartnerDetail> get designatedPartners =>
      partners.where((p) => p.isDesignatedPartner).toList();
}

// ---------------------------------------------------------------------------
// Mock data — 3 LLPs
// ---------------------------------------------------------------------------

final _mockLlps = List<LlpEntity>.unmodifiable([
  LlpEntity(
    id: 'llp-001',
    llpin: 'AAJ-8523',
    name: 'GreenLeaf Organics LLP',
    registeredOffice: '42 MG Road, Bengaluru 560001',
    partners: const [
      LlpPartnerDetail(
        dpin: '09876543',
        name: 'Ramesh Iyer',
        contributionPaise: 1000000 * 100,
        isDesignatedPartner: true,
      ),
      LlpPartnerDetail(
        dpin: '09876544',
        name: 'Suresh Patel',
        contributionPaise: 1000000 * 100,
        isDesignatedPartner: true,
      ),
      LlpPartnerDetail(
        dpin: '09876545',
        name: 'Anita Sharma',
        contributionPaise: 500000 * 100,
        isDesignatedPartner: false,
      ),
    ],
    totalContributionPaise: 2500000 * 100,
    form8Status: LlpFilingStatus.filed,
    form11Status: LlpFilingStatus.filed,
    itr5Status: LlpFilingStatus.filed,
    form8FiledDate: DateTime(2025, 10, 25),
    form11FiledDate: DateTime(2025, 5, 28),
    financialYear: 2025,
  ),
  LlpEntity(
    id: 'llp-002',
    llpin: 'AAK-4567',
    name: 'TechVista Solutions LLP',
    registeredOffice: '101 Park Street, Mumbai 400001',
    partners: const [
      LlpPartnerDetail(
        dpin: '01234567',
        name: 'Vikram Singh',
        contributionPaise: 2000000 * 100,
        isDesignatedPartner: true,
      ),
      LlpPartnerDetail(
        dpin: '01234568',
        name: 'Neha Kapoor',
        contributionPaise: 2000000 * 100,
        isDesignatedPartner: true,
      ),
    ],
    totalContributionPaise: 4000000 * 100,
    form8Status: LlpFilingStatus.overdue,
    form11Status: LlpFilingStatus.overdue,
    itr5Status: LlpFilingStatus.pending,
    form8FiledDate: null,
    form11FiledDate: null,
    financialYear: 2025,
  ),
  LlpEntity(
    id: 'llp-003',
    llpin: 'AAL-7890',
    name: 'UrbanServe Consultants LLP',
    registeredOffice: '22 Connaught Place, New Delhi 110001',
    partners: const [
      LlpPartnerDetail(
        dpin: '05678901',
        name: 'Amit Verma',
        contributionPaise: 500000 * 100,
        isDesignatedPartner: true,
      ),
      LlpPartnerDetail(
        dpin: '05678902',
        name: 'Priya Nair',
        contributionPaise: 500000 * 100,
        isDesignatedPartner: true,
      ),
      LlpPartnerDetail(
        dpin: '05678903',
        name: 'Deepak Gupta',
        contributionPaise: 300000 * 100,
        isDesignatedPartner: false,
      ),
      LlpPartnerDetail(
        dpin: '05678904',
        name: 'Kavita Joshi',
        contributionPaise: 200000 * 100,
        isDesignatedPartner: false,
      ),
    ],
    totalContributionPaise: 1500000 * 100,
    form8Status: LlpFilingStatus.filed,
    form11Status: LlpFilingStatus.filed,
    itr5Status: LlpFilingStatus.pending,
    form8FiledDate: DateTime(2025, 10, 15),
    form11FiledDate: DateTime(2025, 5, 20),
    financialYear: 2025,
  ),
]);

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All LLPs list.
final llpListProvider =
    NotifierProvider<LlpListNotifier, List<LlpEntity>>(LlpListNotifier.new);

class LlpListNotifier extends Notifier<List<LlpEntity>> {
  @override
  List<LlpEntity> build() => _mockLlps;
}

/// Selected LLP ID for detail screen.
final selectedLlpIdProvider =
    NotifierProvider<SelectedLlpIdNotifier, String>(
      SelectedLlpIdNotifier.new,
    );

class SelectedLlpIdNotifier extends Notifier<String> {
  @override
  String build() => _mockLlps.first.id;

  void select(String id) => state = id;
}

/// Current LLP entity derived from selected ID.
final selectedLlpProvider = Provider<LlpEntity>((ref) {
  final id = ref.watch(selectedLlpIdProvider);
  final list = ref.watch(llpListProvider);
  return list.firstWhere((l) => l.id == id, orElse: () => list.first);
});

/// Penalty computation for Form 11 of the selected LLP.
final llpForm11PenaltyProvider = Provider<LlpPenaltyComputation?>((ref) {
  final llp = ref.watch(selectedLlpProvider);
  if (llp.form11Status != LlpFilingStatus.overdue) return null;

  final dueDate = LlpForm11Service.instance.computeDeadline(llp.financialYear);
  final today = DateTime.now();
  final penalty = LlpForm11Service.instance.computePenalty(dueDate, today);

  return LlpPenaltyComputation(
    formType: 'Form-11',
    dueDate: dueDate,
    filedDate: today,
    daysBeyondDue: today.difference(dueDate).inDays,
    penaltyPaise: penalty,
  );
});

/// Penalty computation for Form 8 of the selected LLP.
final llpForm8PenaltyProvider = Provider<LlpPenaltyComputation?>((ref) {
  final llp = ref.watch(selectedLlpProvider);
  if (llp.form8Status != LlpFilingStatus.overdue) return null;

  final dueDate = LlpForm8Service.instance.computeDeadline(llp.financialYear);
  final today = DateTime.now();
  final diff = today.difference(dueDate).inDays;
  if (diff <= 0) return null;

  // Same penalty rate: 100/day = 10000 paise/day
  final penalty = diff * 10000;

  return LlpPenaltyComputation(
    formType: 'Form-8',
    dueDate: dueDate,
    filedDate: today,
    daysBeyondDue: diff,
    penaltyPaise: penalty,
  );
});

/// Total penalty for the selected LLP (Form 8 + Form 11).
final llpTotalPenaltyProvider = Provider<int>((ref) {
  final f11 = ref.watch(llpForm11PenaltyProvider);
  final f8 = ref.watch(llpForm8PenaltyProvider);
  return (f11?.penaltyPaise ?? 0) + (f8?.penaltyPaise ?? 0);
});

/// Count of overdue filings across all LLPs.
final llpOverdueCountProvider = Provider<int>((ref) {
  final list = ref.watch(llpListProvider);
  var count = 0;
  for (final llp in list) {
    if (llp.form8Status == LlpFilingStatus.overdue) count++;
    if (llp.form11Status == LlpFilingStatus.overdue) count++;
    if (llp.itr5Status == LlpFilingStatus.overdue) count++;
  }
  return count;
});
