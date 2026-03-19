/// Pre-approved WhatsApp Business API template identifiers.
///
/// Each value maps to a Meta-approved template name registered for the
/// CA application's WhatsApp Business Account.
enum WhatsAppTemplate {
  deadlineReminder,
  documentShared,
  paymentDue,
  filingComplete,
  queryResponse,
}

/// Immutable result returned from a WhatsApp API send attempt.
class WhatsAppSendResult {
  const WhatsAppSendResult({
    required this.success,
    this.messageId,
    this.errorCode,
    this.errorMessage,
  });

  /// `true` when the message was accepted by the WhatsApp Business API.
  final bool success;

  /// Unique message ID assigned by the API on success; `null` on failure.
  final String? messageId;

  /// Provider error code on failure; `null` on success.
  final String? errorCode;

  /// Human-readable error description on failure; `null` on success.
  final String? errorMessage;

  /// Convenience constructor for a successful result.
  factory WhatsAppSendResult.sent(String messageId) =>
      WhatsAppSendResult(success: true, messageId: messageId);

  /// Convenience constructor for a failed result.
  factory WhatsAppSendResult.failed({
    required String errorCode,
    required String errorMessage,
  }) => WhatsAppSendResult(
    success: false,
    errorCode: errorCode,
    errorMessage: errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WhatsAppSendResult &&
        other.success == success &&
        other.messageId == messageId &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => Object.hash(success, messageId, errorCode);

  @override
  String toString() => success
      ? 'WhatsAppSendResult.sent(messageId: $messageId)'
      : 'WhatsAppSendResult.failed(errorCode: $errorCode, '
            'errorMessage: $errorMessage)';
}

/// Contract for sending WhatsApp Business API template messages.
///
/// Implementations must handle:
/// - Template message dispatch via the Meta Cloud API.
/// - Opt-in status checks before sending.
/// - Rate limiting and retry semantics.
///
/// The [MockWhatsAppNotificationService] is provided for testing and
/// development — it returns success for opted-in numbers and an error
/// for all others without making real API calls.
abstract class WhatsAppNotificationService {
  /// Sends a pre-approved [template] message to [phoneNumber].
  ///
  /// [phoneNumber] must include the country code without `+`,
  /// e.g. `"919876543210"` for an Indian mobile.
  ///
  /// [parameters] supplies values for the template's variable placeholders
  /// in order, keyed by their display names (e.g. `{'clientName': 'Rahul'}`).
  ///
  /// Returns a [WhatsAppSendResult] indicating success or failure.
  Future<WhatsAppSendResult> sendTemplate(
    String phoneNumber,
    WhatsAppTemplate template,
    Map<String, String> parameters,
  );

  /// Returns `true` when [phoneNumber] has opted in to receive WhatsApp
  /// notifications from this business account.
  ///
  /// A `false` result means the number is unknown or has opted out;
  /// calling [sendTemplate] for such a number will always fail with a
  /// provider-level error.
  Future<bool> isOptedIn(String phoneNumber);
}

/// Set of phone numbers pre-configured as opted in for the mock service.
const Set<String> _defaultOptedInNumbers = {
  '919876543210',
  '919123456789',
  '919000000001',
};

/// Mock implementation that returns pre-defined responses without real API calls.
///
/// - Numbers in [_optedInNumbers] are treated as opted in: [sendTemplate]
///   returns [WhatsAppSendResult.sent] with a synthetic message ID.
/// - All other numbers return [WhatsAppSendResult.failed] with error code
///   `"131047"` (the Meta API code for "recipient not opted in").
///
/// Inject a custom [optedInNumbers] set in tests to control which numbers
/// receive a success response.
class MockWhatsAppNotificationService implements WhatsAppNotificationService {
  MockWhatsAppNotificationService({Set<String>? optedInNumbers})
    : _optedInNumbers = optedInNumbers ?? _defaultOptedInNumbers;

  final Set<String> _optedInNumbers;

  int _messageCounter = 0;

  @override
  Future<bool> isOptedIn(String phoneNumber) async {
    return _optedInNumbers.contains(phoneNumber);
  }

  @override
  Future<WhatsAppSendResult> sendTemplate(
    String phoneNumber,
    WhatsAppTemplate template,
    Map<String, String> parameters,
  ) async {
    final optedIn = await isOptedIn(phoneNumber);

    if (!optedIn) {
      return WhatsAppSendResult.failed(
        errorCode: '131047',
        errorMessage:
            'Re-engagement message: recipient $phoneNumber is not opted in.',
      );
    }

    _messageCounter++;
    final messageId =
        'mock_msg_${template.name}_${_messageCounter.toString().padLeft(6, '0')}';

    return WhatsAppSendResult.sent(messageId);
  }
}
