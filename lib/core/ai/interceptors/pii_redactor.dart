import 'package:ca_app/core/ai/models/ai_request.dart';

/// Strips PAN and Aadhaar numbers from AI requests before they leave the device.
///
/// Reuses the same patterns as [LoggingInterceptor] in api_interceptors.dart.
class PiiRedactor {
  const PiiRedactor();

  // PAN: 5 uppercase letters, 4 digits, 1 uppercase letter.
  static final _panPattern = RegExp(r'[A-Z]{5}[0-9]{4}[A-Z]');

  // 12 consecutive digits (Aadhaar-like).
  static final _aadhaarPattern = RegExp(r'\b\d{12}\b');

  /// Returns a new [AiRequest] with PAN/Aadhaar redacted from all messages
  /// and the system prompt.
  AiRequest redact(AiRequest request) {
    final redactedMessages = request.messages.map((msg) {
      return msg.copyWith(content: _redactText(msg.content));
    }).toList();

    final redactedSystemPrompt = request.systemPrompt != null
        ? _redactText(request.systemPrompt!)
        : null;

    return request.copyWith(
      messages: redactedMessages,
      systemPrompt: redactedSystemPrompt,
    );
  }

  /// Redacts sensitive patterns from [text].
  String redactText(String text) => _redactText(text);

  String _redactText(String text) {
    return text
        .replaceAll(_panPattern, '[PAN-REDACTED]')
        .replaceAll(_aadhaarPattern, '[AADHAAR-REDACTED]');
  }
}
