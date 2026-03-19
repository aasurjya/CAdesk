import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_form_data.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';

// ---------------------------------------------------------------------------
// Wizard step tracking
// ---------------------------------------------------------------------------

class _Gstr3bWizardStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void reset() => state = 0;

  void goTo(int step) => state = step;
}

/// Zero-based index of the current GSTR-3B wizard step (0..4).
final gstr3bWizardStepProvider =
    NotifierProvider<_Gstr3bWizardStepNotifier, int>(
      _Gstr3bWizardStepNotifier.new,
    );

// ---------------------------------------------------------------------------
// Period & client selection
// ---------------------------------------------------------------------------

class _Gstr3bPeriodNotifier extends Notifier<({int month, int year})> {
  @override
  ({int month, int year}) build() {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);
    return (month: prev.month, year: prev.year);
  }

  void update(({int month, int year}) value) => state = value;
}

/// Selected filing period for the GSTR-3B wizard.
final gstr3bPeriodProvider =
    NotifierProvider<_Gstr3bPeriodNotifier, ({int month, int year})>(
      _Gstr3bPeriodNotifier.new,
    );

class _Gstr3bSelectedClientNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? clientId) => state = clientId;
}

/// Currently selected client ID for the GSTR-3B wizard.
final gstr3bSelectedClientProvider =
    NotifierProvider<_Gstr3bSelectedClientNotifier, String?>(
      _Gstr3bSelectedClientNotifier.new,
    );

// ---------------------------------------------------------------------------
// GSTR-3B form data notifier
// ---------------------------------------------------------------------------

const _zeroTaxRow = Gstr3bTaxRow(igst: 0, cgst: 0, sgst: 0, cess: 0);
const _zeroItcRow = ItcRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

Gstr3bFormData _emptyGstr3b() => const Gstr3bFormData(
  gstin: '',
  periodMonth: 1,
  periodYear: 2026,
  taxLiability: Gstr3bTaxLiability(
    outwardTaxable: _zeroTaxRow,
    outwardZeroRated: _zeroTaxRow,
    otherOutward: _zeroTaxRow,
    inwardRcm: _zeroTaxRow,
    nonGstOutward: _zeroTaxRow,
  ),
  itcClaimed: Gstr3bItcClaimed(
    importGoods: _zeroItcRow,
    importServices: _zeroItcRow,
    inwardRcm: _zeroItcRow,
    isd: _zeroItcRow,
    otherItc: _zeroItcRow,
    reversedSection17_5: _zeroItcRow,
    reversedOthers: _zeroItcRow,
    netItcAvailable: _zeroItcRow,
    ineligibleRule38: _zeroItcRow,
    ineligibleOthers: _zeroItcRow,
  ),
  exemptSupplies: Gstr3bExemptSupplies(
    interStateExempt: 0,
    intraStateExempt: 0,
    interStateNilRated: 0,
    intraStateNilRated: 0,
    interStateNonGst: 0,
    intraStateNonGst: 0,
  ),
);

class Gstr3bFormDataNotifier extends Notifier<Gstr3bFormData> {
  @override
  Gstr3bFormData build() => _emptyGstr3b();

  void reset() => state = build();

  void updateGstin(String gstin) {
    state = state.copyWith(gstin: gstin);
  }

  void updatePeriod({required int month, required int year}) {
    state = state.copyWith(periodMonth: month, periodYear: year);
  }

  void updateTaxLiability(Gstr3bTaxLiability liability) {
    state = state.copyWith(taxLiability: liability);
  }

  void updateItcClaimed(Gstr3bItcClaimed itc) {
    state = state.copyWith(itcClaimed: itc);
  }

  void updateExemptSupplies(Gstr3bExemptSupplies exempt) {
    state = state.copyWith(exemptSupplies: exempt);
  }
}

/// Holds the in-progress GSTR-3B form data.
final gstr3bFormDataProvider =
    NotifierProvider<Gstr3bFormDataNotifier, Gstr3bFormData>(
      Gstr3bFormDataNotifier.new,
    );

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

/// True when the period step has required fields filled.
final gstr3bPeriodValidProvider = Provider<bool>((ref) {
  final data = ref.watch(gstr3bFormDataProvider);
  return data.gstin.isNotEmpty && data.periodMonth >= 1;
});

/// Net tax payable after ITC utilization.
final gstr3bNetTaxPayableProvider = Provider<double>((ref) {
  final data = ref.watch(gstr3bFormDataProvider);
  return data.netTaxPayable;
});

/// Interest on late payment (18% p.a.).
/// [daysLate] defaults to 0; caller should supply actual days.
final gstr3bInterestProvider = Provider.family<double, int>((ref, daysLate) {
  final netTax = ref.watch(gstr3bNetTaxPayableProvider);
  if (daysLate <= 0 || netTax <= 0) return 0;
  return netTax * 0.18 / 365 * daysLate;
});
