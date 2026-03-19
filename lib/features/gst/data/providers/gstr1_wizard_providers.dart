import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_at.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnr.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnur.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';

// ---------------------------------------------------------------------------
// Wizard step tracking
// ---------------------------------------------------------------------------

class _Gstr1WizardStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void reset() => state = 0;

  void goTo(int step) => state = step;
}

/// Zero-based index of the current GSTR-1 wizard step (0..7).
final gstr1WizardStepProvider = NotifierProvider<_Gstr1WizardStepNotifier, int>(
  _Gstr1WizardStepNotifier.new,
);

// ---------------------------------------------------------------------------
// Period & client selection
// ---------------------------------------------------------------------------

class _Gstr1PeriodNotifier extends Notifier<({int month, int year})> {
  @override
  ({int month, int year}) build() {
    final now = DateTime.now();
    // Default to previous month.
    final prev = DateTime(now.year, now.month - 1);
    return (month: prev.month, year: prev.year);
  }

  void update(({int month, int year}) value) => state = value;
}

/// Selected filing period for the GSTR-1 wizard.
final gstr1PeriodProvider =
    NotifierProvider<_Gstr1PeriodNotifier, ({int month, int year})>(
      _Gstr1PeriodNotifier.new,
    );

class _Gstr1SelectedClientNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? clientId) => state = clientId;
}

/// Currently selected client ID for the GSTR-1 wizard.
final gstr1SelectedClientProvider =
    NotifierProvider<_Gstr1SelectedClientNotifier, String?>(
      _Gstr1SelectedClientNotifier.new,
    );

// ---------------------------------------------------------------------------
// GSTR-1 form data notifier
// ---------------------------------------------------------------------------

class Gstr1FormDataNotifier extends Notifier<Gstr1FormData> {
  @override
  Gstr1FormData build() => const Gstr1FormData(
    gstin: '',
    periodMonth: 1,
    periodYear: 2026,
    b2bInvoices: [],
    b2cInvoices: [],
    creditDebitNotes: [],
    creditDebitNotesUnregistered: [],
    exports: [],
    advanceTax: [],
  );

  void reset() => state = build();

  void updateGstin(String gstin) {
    state = state.copyWith(gstin: gstin);
  }

  void updatePeriod({required int month, required int year}) {
    state = state.copyWith(periodMonth: month, periodYear: year);
  }

  // -- B2B invoices --

  void addB2bInvoice(Gstr1B2bInvoice invoice) {
    state = state.copyWith(b2bInvoices: [...state.b2bInvoices, invoice]);
  }

  void updateB2bInvoice(int index, Gstr1B2bInvoice invoice) {
    final updated = [
      for (var i = 0; i < state.b2bInvoices.length; i++)
        if (i == index) invoice else state.b2bInvoices[i],
    ];
    state = state.copyWith(b2bInvoices: updated);
  }

  void removeB2bInvoice(int index) {
    final updated = [
      for (var i = 0; i < state.b2bInvoices.length; i++)
        if (i != index) state.b2bInvoices[i],
    ];
    state = state.copyWith(b2bInvoices: updated);
  }

  // -- B2C invoices --

  void addB2cInvoice(Gstr1B2cInvoice invoice) {
    state = state.copyWith(b2cInvoices: [...state.b2cInvoices, invoice]);
  }

  void updateB2cInvoice(int index, Gstr1B2cInvoice invoice) {
    final updated = [
      for (var i = 0; i < state.b2cInvoices.length; i++)
        if (i == index) invoice else state.b2cInvoices[i],
    ];
    state = state.copyWith(b2cInvoices: updated);
  }

  void removeB2cInvoice(int index) {
    final updated = [
      for (var i = 0; i < state.b2cInvoices.length; i++)
        if (i != index) state.b2cInvoices[i],
    ];
    state = state.copyWith(b2cInvoices: updated);
  }

  // -- CDNR --

  void addCdnr(Gstr1Cdnr note) {
    state = state.copyWith(creditDebitNotes: [...state.creditDebitNotes, note]);
  }

  void removeCdnr(int index) {
    final updated = [
      for (var i = 0; i < state.creditDebitNotes.length; i++)
        if (i != index) state.creditDebitNotes[i],
    ];
    state = state.copyWith(creditDebitNotes: updated);
  }

  // -- CDNUR --

  void addCdnur(Gstr1Cdnur note) {
    state = state.copyWith(
      creditDebitNotesUnregistered: [
        ...state.creditDebitNotesUnregistered,
        note,
      ],
    );
  }

  void removeCdnur(int index) {
    final updated = [
      for (var i = 0; i < state.creditDebitNotesUnregistered.length; i++)
        if (i != index) state.creditDebitNotesUnregistered[i],
    ];
    state = state.copyWith(creditDebitNotesUnregistered: updated);
  }

  // -- Exports --

  void addExport(Gstr1Exp export) {
    state = state.copyWith(exports: [...state.exports, export]);
  }

  void removeExport(int index) {
    final updated = [
      for (var i = 0; i < state.exports.length; i++)
        if (i != index) state.exports[i],
    ];
    state = state.copyWith(exports: updated);
  }

  // -- Advance Tax --

  void addAdvanceTax(Gstr1At at) {
    state = state.copyWith(advanceTax: [...state.advanceTax, at]);
  }

  void removeAdvanceTax(int index) {
    final updated = [
      for (var i = 0; i < state.advanceTax.length; i++)
        if (i != index) state.advanceTax[i],
    ];
    state = state.copyWith(advanceTax: updated);
  }
}

/// Holds the in-progress GSTR-1 form data.
final gstr1FormDataProvider =
    NotifierProvider<Gstr1FormDataNotifier, Gstr1FormData>(
      Gstr1FormDataNotifier.new,
    );

// ---------------------------------------------------------------------------
// Derived: section-level validation flags
// ---------------------------------------------------------------------------

/// True when the period step has required fields filled.
final gstr1PeriodValidProvider = Provider<bool>((ref) {
  final data = ref.watch(gstr1FormDataProvider);
  return data.gstin.isNotEmpty && data.periodMonth >= 1;
});

/// True when at least one invoice exists across all tables.
final gstr1HasDataProvider = Provider<bool>((ref) {
  final data = ref.watch(gstr1FormDataProvider);
  return data.b2bInvoices.isNotEmpty ||
      data.b2cInvoices.isNotEmpty ||
      data.creditDebitNotes.isNotEmpty ||
      data.creditDebitNotesUnregistered.isNotEmpty ||
      data.exports.isNotEmpty ||
      data.advanceTax.isNotEmpty;
});
