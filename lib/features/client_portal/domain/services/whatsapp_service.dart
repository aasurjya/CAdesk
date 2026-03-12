import 'dart:math';

import 'package:ca_app/features/client_portal/domain/models/payment_link.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_client.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document.dart';
import 'package:ca_app/features/client_portal/domain/models/whatsapp_message.dart';

/// Domain service for sending WhatsApp Business API messages.
///
/// This is a mock implementation — all sends return a [WhatsAppMessage] with
/// [MessageStatus.sent] without making real API calls. The real implementation
/// would call Meta's Cloud API at:
/// `POST https://graph.facebook.com/v18.0/{phone-number-id}/messages`
///
/// Notes:
/// - Template messages require Meta pre-approval; non-template messages are
///   only allowed within the 24-hour customer service window.
/// - Phone numbers must include the country code without '+':
///   e.g. "919876543210" for an Indian number.
class WhatsAppService {
  WhatsAppService._();

  static final WhatsAppService instance = WhatsAppService._();

  final Random _random = Random();

  // ---------------------------------------------------------------------------
  // Core send methods
  // ---------------------------------------------------------------------------

  /// Sends a free-text message to [to].
  ///
  /// Returns a [WhatsAppMessage] with [MessageStatus.sent] and [sentAt] set
  /// to now.
  WhatsAppMessage sendTextMessage(
    String to,
    String message,
    String firmId,
  ) {
    return WhatsAppMessage(
      messageId: _generateMessageId(),
      to: to,
      messageType: MessageType.text,
      content: message,
      status: MessageStatus.sent,
      sentAt: DateTime.now(),
      caFirmId: firmId,
    );
  }

  /// Sends a pre-approved WhatsApp template message.
  ///
  /// [variables] are substituted into the template text using simple
  /// `{key}` replacement before storing as [WhatsAppMessage.content].
  WhatsAppMessage sendTemplateMessage(
    String to,
    String templateName,
    Map<String, String> variables,
    String firmId,
  ) {
    final content = _fillTemplate(
      _builtInTemplateText(templateName),
      variables,
    );
    return WhatsAppMessage(
      messageId: _generateMessageId(),
      to: to,
      templateName: templateName,
      messageType: MessageType.template,
      content: content,
      status: MessageStatus.sent,
      sentAt: DateTime.now(),
      caFirmId: firmId,
    );
  }

  // ---------------------------------------------------------------------------
  // High-level convenience methods
  // ---------------------------------------------------------------------------

  /// Sends a document-shared notification to [client] about [doc].
  WhatsAppMessage sendDocumentNotification(
    PortalClient client,
    SharedDocument doc,
  ) {
    return sendTemplateMessage(
      client.mobile,
      'document_shared',
      {
        'clientName': client.name,
        'caName': 'Your CA',
        'documentTitle': doc.title,
        'portalLink': 'https://portal.caapp.in',
      },
      client.caFirmId,
    );
  }

  /// Sends a deadline reminder to [client].
  WhatsAppMessage sendDeadlineReminder(
    PortalClient client,
    String deadline,
    String filingType,
  ) {
    return sendTemplateMessage(
      client.mobile,
      'deadline_reminder',
      {
        'filingType': filingType,
        'deadline': deadline,
        'requiredDocuments': 'relevant documents',
      },
      client.caFirmId,
    );
  }

  /// Sends a payment reminder to [client] for [link].
  ///
  /// [link.amount] (paise) is converted to rupees for display.
  WhatsAppMessage sendPaymentReminder(
    PortalClient client,
    PaymentLink link,
  ) {
    final amountRupees = (link.amount / 100).toStringAsFixed(0);
    return sendTemplateMessage(
      client.mobile,
      'payment_due',
      {
        'amount': amountRupees,
        'dueDate': _formatDate(link.expiresAt),
        'paymentLink': 'https://pay.caapp.in/${link.linkId}',
      },
      client.caFirmId,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _generateMessageId() {
    final buffer = StringBuffer('msg-');
    for (var i = 0; i < 12; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }

  /// Returns the built-in template text for [templateName].
  ///
  /// Falls back to an empty string for unknown templates — callers should
  /// use [NotificationTemplateService] for production template resolution.
  String _builtInTemplateText(String templateName) {
    switch (templateName) {
      case 'document_shared':
        return 'Dear {clientName}, {caName} has shared {documentTitle} for your review. Login: {portalLink}';
      case 'deadline_reminder':
        return 'Reminder: {filingType} deadline is {deadline}. Please share {requiredDocuments}.';
      case 'payment_due':
        return 'Invoice ₹{amount} is due by {dueDate}. Pay here: {paymentLink}';
      case 'filing_complete':
        return 'Your {filingType} for {period} has been filed successfully. ARN: {arn}';
      default:
        return '';
    }
  }

  String _fillTemplate(String template, Map<String, String> variables) {
    var result = template;
    for (final entry in variables.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}'
        '/${date.month.toString().padLeft(2, '0')}'
        '/${date.year}';
  }
}
