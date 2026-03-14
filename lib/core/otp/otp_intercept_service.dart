import 'dart:async';

import 'package:ca_app/core/otp/otp_channel.dart';

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Thrown when the OTP wait times out before the user submits a code.
class OtpTimeoutException implements Exception {
  const OtpTimeoutException(this.portalName, this.channel);

  final String portalName;
  final OtpChannel channel;

  @override
  String toString() =>
      'OtpTimeoutException: OTP wait timed out for $portalName '
      '(channel: ${channel.label})';
}

/// Thrown when the user explicitly cancels the OTP dialog.
class OtpCancelledException implements Exception {
  const OtpCancelledException(this.portalName);

  final String portalName;

  @override
  String toString() =>
      'OtpCancelledException: OTP entry cancelled for $portalName';
}

/// Thrown when [OtpInterceptService.waitForOtp] is called while another
/// OTP request is already in flight.
class OtpAlreadyPendingException implements Exception {
  const OtpAlreadyPendingException();

  @override
  String toString() =>
      'OtpAlreadyPendingException: Another OTP is already waiting for input';
}

// ---------------------------------------------------------------------------
// Pending request descriptor
// ---------------------------------------------------------------------------

/// Immutable snapshot describing an in-flight OTP request.
class OtpPendingRequest {
  const OtpPendingRequest({
    required this.channel,
    required this.portalName,
    required this.maskedContact,
  });

  final OtpChannel channel;
  final String portalName;
  final String maskedContact;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Bridges an ongoing portal automation session with the Flutter UI.
///
/// Usage:
/// ```dart
/// // In a portal service (background):
/// final otp = await otpService.waitForOtp(
///   channel: OtpChannel.sms,
///   portalName: 'ITD Portal',
///   maskedContact: '+91-98xxx',
/// );
///
/// // In the OTP dialog (UI):
/// otpService.resolveOtp('123456');
/// // or
/// otpService.cancelOtp();
/// ```
///
/// Only one OTP request may be active at a time. Attempting to start a
/// second concurrent request throws [OtpAlreadyPendingException].
class OtpInterceptService {
  Completer<String>? _completer;
  OtpPendingRequest? _pendingRequest;
  Timer? _timeoutTimer;

  /// The currently pending OTP request, or `null` if no wait is active.
  OtpPendingRequest? get pendingRequest => _pendingRequest;

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------

  /// Suspends the calling coroutine until the user submits an OTP via the
  /// dialog, or until [timeout] elapses.
  ///
  /// Throws:
  /// - [OtpAlreadyPendingException] if a concurrent wait is already active.
  /// - [OtpTimeoutException] if [timeout] elapses without resolution.
  /// - [OtpCancelledException] if [cancelOtp] is called.
  Future<String> waitForOtp({
    required OtpChannel channel,
    required String portalName,
    required String maskedContact,
    Duration timeout = const Duration(minutes: 5),
  }) {
    if (_completer != null && !_completer!.isCompleted) {
      throw const OtpAlreadyPendingException();
    }

    _completer = Completer<String>();
    _pendingRequest = OtpPendingRequest(
      channel: channel,
      portalName: portalName,
      maskedContact: maskedContact,
    );

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(timeout, () {
      if (_completer != null && !_completer!.isCompleted) {
        _completer!.completeError(
          OtpTimeoutException(portalName, channel),
          StackTrace.current,
        );
        _clear();
      }
    });

    return _completer!.future;
  }

  /// Resolves the pending OTP future with the user-entered [otp].
  ///
  /// No-op if no OTP wait is currently active.
  void resolveOtp(String otp) {
    if (_completer != null && !_completer!.isCompleted) {
      _timeoutTimer?.cancel();
      _completer!.complete(otp);
      _clear();
    }
  }

  /// Cancels the pending OTP wait, causing the future to throw
  /// [OtpCancelledException].
  ///
  /// No-op if no OTP wait is currently active.
  void cancelOtp() {
    if (_completer != null && !_completer!.isCompleted) {
      _timeoutTimer?.cancel();
      final portal = _pendingRequest?.portalName ?? 'Unknown';
      _completer!.completeError(
        OtpCancelledException(portal),
        StackTrace.current,
      );
      _clear();
    }
  }

  /// Releases all resources. Call when the service is no longer needed.
  void dispose() {
    _timeoutTimer?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(
        const OtpCancelledException('disposed'),
        StackTrace.current,
      );
    }
    _clear();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  void _clear() {
    _completer = null;
    _pendingRequest = null;
    _timeoutTimer = null;
  }
}
