import 'dart:async';

/// A pause/resume gate for the automation flow.
///
/// When the automation reaches a review point (e.g., after filling the form
/// but before clicking Submit), it calls [waitForConfirmation] which suspends
/// the stream until the CA taps "Confirm & Submit" in the UI.
///
/// The UI calls [confirm] to resume or [reject] to abort.
///
/// Usage in a portal service:
/// ```dart
/// yield _log(jobId, SubmissionStep.reviewing, 'Please review...');
/// await confirmationGate.waitForConfirmation();
/// // Automation resumes here after CA confirms
/// ```
///
/// Usage in the UI (PortalWebViewScreen):
/// ```dart
/// ElevatedButton(
///   onPressed: () => confirmationGate.confirm(),
///   child: Text('Confirm & Submit'),
/// )
/// ```
class ConfirmationGate {
  Completer<bool>? _completer;

  /// Whether the gate is currently waiting for user confirmation.
  bool get isPending => _completer != null && !_completer!.isCompleted;

  /// Suspends execution until [confirm] or [reject] is called.
  ///
  /// Returns `true` if confirmed, throws [ConfirmationRejectedException]
  /// if rejected.
  ///
  /// Throws [StateError] if already waiting (only one pending gate at a time).
  Future<void> waitForConfirmation() async {
    if (isPending) {
      throw StateError('ConfirmationGate already has a pending request');
    }

    _completer = Completer<bool>();
    final confirmed = await _completer!.future;

    if (!confirmed) {
      throw const ConfirmationRejectedException();
    }
  }

  /// Resumes the automation — the CA has reviewed and approved.
  void confirm() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(true);
    }
  }

  /// Aborts the automation — the CA wants to cancel.
  void reject() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(false);
    }
  }

  /// Resets the gate for reuse.
  void dispose() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(false);
    }
    _completer = null;
  }
}

/// Thrown when the CA rejects/cancels during the review gate.
class ConfirmationRejectedException implements Exception {
  const ConfirmationRejectedException();

  @override
  String toString() =>
      'ConfirmationRejectedException: User cancelled submission during review';
}
