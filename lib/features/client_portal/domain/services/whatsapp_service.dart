import 'dart:math';

import 'package:ca_app/features/client_portal/domain/models/payment_link.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_client.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document.dart';
import 'package:ca_app/features/client_portal/domain/models/whatsapp_message.dart';

/// Stateless singleton service for sending WhatsApp messages to clients.
///
/// In this domain layer the service is intentionally decoupled from the
/// WhatsApp Business API — actual HTTP calls belong in the data layer.
/// Here it produces immutable [WhatsAppMessage] records that represent
/// what was (logically) sent.
class WhatsAppService {
  WhatsAppService._();

  static final WhatsAppService instance = WhatsAppService._();

  static final Random _random = Random.secure();

  // ---------------------------------------------------------------------------
  // Core send helpers
  // ---------------------------------------------------------------------------

  /// Sends a plain text message and returns the resulting [WhatsAppMessage].
  WhatsAppMessage sendTextMessage(
    String to,
    String content,
    String caFirmId,
  ) {
    return WhatsAppMessage(
      messageId: _generateId(),
      to: to,
      messageType: MessageType.text,
      content: content,
      status: MessageStatus.sent,
      caFirmId: caFirmId,
      sentAt: DateTime.now(),
    );
  }

  /// Sends a named template message with [variables] and returns the result.
  WhatsAppMessage sendTemplateMessage(
    String to,
    String templateName,
    Map<String, String> variables,
    String caFirmId,
  ) {
    final content = variables.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return WhatsAppMessage(
      messageId: _generateId(),
      to: to,
      messageType: MessageType.template,
      content: content,
      status: MessageStatus.sent,
      caFirmId: caFirmId,
      templateName: templateName,
      sentAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Domain-specific senders
  // ---------------------------------------------------------------------------

  /// Notifies [client] that [doc] has been shared on the portal.
  WhatsAppMessage sendDocumentNotification(
    PortalClient client,
    SharedDocument doc,
  ) {
    final content =
        'Dear ${client.name}, a document has been shared with you: '
        '${doc.title}. Please log in to your portal to view it.';
    return WhatsAppMessage(
      messageId: _generateId(),
      to: client.mobile,
      messageType: MessageType.template,
      content: content,
      status: MessageStatus.sent,
      caFirmId: client.caFirmId,
      templateName: 'document_shared',
      sentAt: DateTime.now(),
    );
  }

  /// Reminds [client] about an upcoming filing deadline.
  ///
  /// [deadline] is a human-readable date string, e.g. "2025-07-31".
  WhatsAppMessage sendDeadlineReminder(
    PortalClient client,
    String deadline,
    String filingType,
  ) {
    final content =
        'Reminder: Your $filingType is due on $deadline. '
        'Please ensure all required documents are submitted.';
    return WhatsAppMessage(
      messageId: _generateId(),
      to: client.mobile,
      messageType: MessageType.template,
      content: content,
      status: MessageStatus.sent,
      caFirmId: client.caFirmId,
      templateName: 'deadline_reminder',
      sentAt: DateTime.now(),
    );
  }

  /// Reminds [client] about a pending payment for [link].
  ///
  /// Amount is displayed in rupees (converted from paise).
  WhatsAppMessage sendPaymentReminder(
    PortalClient client,
    PaymentLink link,
  ) {
    final amountRupees = (link.amount / 100).toStringAsFixed(0);
    final content =
        'Dear ${client.name}, your payment of ₹$amountRupees is pending. '
        'Invoice: ${link.description}. Please pay at your earliest convenience.';
    return WhatsAppMessage(
      messageId: _generateId(),
      to: client.mobile,
      messageType: MessageType.template,
      content: content,
      status: MessageStatus.sent,
      caFirmId: client.caFirmId,
      templateName: 'payment_due',
      sentAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _generateId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
