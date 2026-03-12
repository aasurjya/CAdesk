import '../models/gst_filing_status.dart';

/// Events that drive the GST return filing state machine.
enum GstFilingEvent {
  saveDraft,
  submit,
  file,
  gstinProcess,
  reject,
}

/// Stateless service that manages the GST return filing state machine
/// and computes late fees per CGST Act provisions.
///
/// All methods are pure functions — they return new [GstFilingStatus] instances
/// and never mutate the input.
///
/// Late fee rules (CGST Act, Section 47):
/// - GSTR-1 / GSTR-3B (with tax liability): ₹50/day (₹25 CGST + ₹25 SGST),
///   maximum ₹10,000 per return.
/// - GSTR-3B (nil return): ₹20/day, maximum ₹10,000 per return.
///
/// Note: COVID-era waivers (notification-based) waived late fees for nil-return
/// filers for specific periods (Mar 2020 – Sep 2020, etc.). These waivers are
/// notification-specific and should be applied by callers when relevant.
class GstStatusTracker {
  GstStatusTracker._();

  static final instance = GstStatusTracker._();

  // ---------------------------------------------------------------------------
  // Late fee constants (in paise)
  // ---------------------------------------------------------------------------

  /// ₹50/day × 100 paise = 5000 paise per day (standard — GSTR-1 or GSTR-3B
  /// with tax liability).
  static const int _lateFeePerDayStandard = 5000;

  /// ₹20/day × 100 paise = 2000 paise per day (nil return — GSTR-3B only).
  static const int _lateFeePerDayNil = 2000;

  /// Maximum late fee per return: ₹10,000 = 1,000,000 paise.
  static const int _maxLateFee = 1000000;

  // ---------------------------------------------------------------------------
  // Allowed transitions: Map<current state, Map<event, next state>>
  // ---------------------------------------------------------------------------
  static const _transitions =
      <GstFilingState, Map<GstFilingEvent, GstFilingState>>{
    GstFilingState.notFiled: {
      GstFilingEvent.saveDraft: GstFilingState.saved,
    },
    GstFilingState.saved: {
      GstFilingEvent.submit: GstFilingState.submitted,
    },
    GstFilingState.submitted: {
      GstFilingEvent.file: GstFilingState.filed,
      GstFilingEvent.reject: GstFilingState.rejected,
    },
    GstFilingState.filed: {
      GstFilingEvent.gstinProcess: GstFilingState.processed,
    },
  };

  /// Applies [event] to [current] and returns a new [GstFilingStatus].
  ///
  /// Optional [filedAt] and [arn] are set when the event is [GstFilingEvent.file].
  /// If the event is not valid for the current state, [current] is returned
  /// unchanged.
  static GstFilingStatus transitionGstState(
    GstFilingStatus current,
    GstFilingEvent event, {
    DateTime? filedAt,
    String? arn,
  }) {
    final allowed = _transitions[current.status];
    if (allowed == null) return current;

    final nextState = allowed[event];
    if (nextState == null) return current;

    return current.copyWith(
      status: nextState,
      filedAt: filedAt,
      arn: arn,
    );
  }

  /// Computes the late fee for [status] as of [today], given the [dueDate] for
  /// the return period.
  ///
  /// - [isNilReturn]: when `true`, applies the nil-return rate (₹20/day) for
  ///   GSTR-3B. Ignored for GSTR-1 (always ₹50/day).
  ///
  /// Returns 0 if today is on or before [dueDate].
  /// Returns 0 for GSTR-9 (annual return — late fee governed separately).
  static int computeLateFee(
    GstFilingStatus status,
    DateTime today, {
    required DateTime dueDate,
    bool isNilReturn = false,
  }) {
    if (status.returnType == GstReturnType.gstr9) return 0;

    final daysLate = today.difference(dueDate).inDays;
    if (daysLate <= 0) return 0;

    final dailyRate = _dailyRate(status.returnType, isNilReturn: isNilReturn);
    final fee = daysLate * dailyRate;
    return fee > _maxLateFee ? _maxLateFee : fee;
  }

  /// Returns `true` if the return is not yet filed and today is past [dueDate],
  /// OR if the return was filed after the [dueDate].
  static bool isLate(
    GstFilingStatus status, {
    required DateTime today,
    required DateTime dueDate,
  }) {
    final filedAt = status.filedAt;
    if (filedAt != null) {
      return filedAt.isAfter(dueDate);
    }
    return today.isAfter(dueDate);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static int _dailyRate(GstReturnType type, {required bool isNilReturn}) {
    if (type == GstReturnType.gstr3b && isNilReturn) {
      return _lateFeePerDayNil;
    }
    return _lateFeePerDayStandard;
  }
}
